import 'dart:io';
import 'dart:typed_data';

/// The ISO BMFF EC3SpecificBox (dec3) has a separate JOC extension flag.
/// MediaExtractor and ffprobe can both report only "eac3", even when this
/// flag is present. Parse only the ec-3 sample entry inside moov/trak/.../stsd
/// rather than scanning arbitrary file bytes for "dec3" (which can occur in
/// album artwork, payloads or metadata). Never modify the source bitstream.
class AtmosBoxProbe {
  const AtmosBoxProbe({
    required this.verified,
    required this.reason,
    this.ec3SampleEntry = false,
    this.dec3Present = false,
  });

  final bool verified;
  /// Fixed diagnostic tokens, not filenames, URIs or raw file data.
  final String reason;
  final bool ec3SampleEntry;
  final bool dec3Present;
}

class _Box {
  const _Box(this.type, this.start, this.end, this.header);
  final String type;
  final int start;
  final int end;
  final int header;
  int get payload => start + header;
}

int _u32(Uint8List data, [int offset = 0]) =>
    ByteData.sublistView(data).getUint32(offset, Endian.big);

int _u64(Uint8List data, int offset) =>
    ByteData.sublistView(data).getUint64(offset, Endian.big);

String _fourcc(Uint8List data, int offset) =>
    String.fromCharCodes(data.sublist(offset, offset + 4));

Future<Uint8List> _read(RandomAccessFile file, int offset, int count) async {
  await file.setPosition(offset);
  return Uint8List.fromList(await file.read(count));
}

Future<_Box?> _box(RandomAccessFile file, int offset, int end) async {
  if (end - offset < 8) return null;
  final header = await _read(file, offset, 8);
  if (header.length < 8) return null;
  var length = _u32(header);
  var headerSize = 8;
  if (length == 1) {
    if (end - offset < 16) return null;
    final extended = await _read(file, offset + 8, 8);
    if (extended.length != 8) return null;
    length = _u64(extended, 0);
    headerSize = 16;
  } else if (length == 0) {
    length = end - offset;
  }
  if (length < headerSize || length > end - offset) return null;
  return _Box(_fourcc(header, 4), offset, offset + length, headerSize);
}

/// Inspect the exact bit layout specified for EC3SpecificBox:
/// data_rate (13), num_ind_sub (3); one or more independent descriptors;
/// flag_ec3_extension_type_reserved (7), flag_ec3_extension_type_a (1),
/// complexity_index_type_a (8). Do not interpret any random nonzero byte
/// as JOC, and reject truncated/invalid complexity information.
bool ec3SpecificBoxHasJoc(Uint8List data) {
  if (data.length < 7) return false;
  final numIndSub = data[1] & 0x07;
  var bit = 16;
  int readBits(int count) {
    if (bit + count > data.length * 8) throw const FormatException('truncated');
    var value = 0;
    for (var n = 0; n < count; n++) {
      value = (value << 1) | ((data[bit ~/ 8] >> (7 - (bit % 8))) & 1);
      bit++;
    }
    return value;
  }

  try {
    for (var i = 0; i <= numIndSub; i++) {
      readBits(2);  // fscod
      readBits(5);  // bsid
      readBits(1);  // reserved
      readBits(1);  // asvc
      readBits(3);  // bsmod
      readBits(3);  // acmod
      readBits(1);  // lfeon
      readBits(3);  // reserved
      final dependent = readBits(4);
      readBits(dependent > 0 ? 9 : 1); // chan_loc or reserved
    }
    if (bit + 16 > data.length * 8) return false;
    readBits(7); // reserved, ignore per Dolby
    final flag = readBits(1);
    final complexity = readBits(8);
    return flag == 1 && complexity >= 1 && complexity <= 16;
  } on FormatException {
    return false;
  }
}

/// RandomAccessFile navigation avoids loading huge MP4/mdat regions.
Future<AtmosBoxProbe> inspectAtmosDec3(String path) async {
  RandomAccessFile? file;
  try {
    file = await File(path).open(mode: FileMode.read);
    final size = await file.length();
    if (size < 16) return const AtmosBoxProbe(verified: false, reason: 'invalid_container');
    var foundEc3 = false;
    var foundDec3 = false;
    var verified = false;
    var corrupt = false;
    var boxesRead = 0;

    Future<void> visit(int start, int end, int depth) async {
      if (depth > 8 || verified) return;
      var offset = start;
      while (offset + 8 <= end && !verified) {
        // Malformed metadata with zero-sized boxes cannot loop forever.
        if (++boxesRead > 20000) {
          corrupt = true;
          return;
        }
        final box = await _box(file!, offset, end);
        if (box == null) {
          corrupt = true;
          return;
        }
        if (const {'moov', 'trak', 'mdia', 'minf', 'stbl'}.contains(box.type)) {
          await visit(box.payload, box.end, depth + 1);
        } else if (box.type == 'stsd' && box.end - box.payload >= 8) {
          final fixed = await _read(file!, box.payload, 8);
          if (fixed.length < 8) {
            corrupt = true;
          } else {
            final count = _u32(fixed, 4);
            var entryPos = box.payload + 8;
            for (var i = 0; i < count && i < 256 && !verified; i++) {
              final entry = await _box(file!, entryPos, box.end);
              if (entry == null) {
                corrupt = true;
                break;
              }
              // AudioSampleEntry has a 28-byte payload before child boxes.
              // Only the unencrypted ec-3 sample entry can attest JOC.
              if (entry.type == 'ec-3') {
                foundEc3 = true;
                var childPos = entry.payload + 28;
                if (childPos > entry.end) {
                  corrupt = true;
                } else {
                  while (childPos + 8 <= entry.end && !verified) {
                    final child = await _box(file!, childPos, entry.end);
                    if (child == null) {
                      corrupt = true;
                      break;
                    }
                    if (child.type == 'dec3') {
                      foundDec3 = true;
                      final dataLen = child.end - child.payload;
                      // dec3 is a small codec descriptor, never scan mdat.
                      if (dataLen >= 5 && dataLen <= 256) {
                        final descriptor = await _read(file!, child.payload, dataLen);
                        verified = ec3SpecificBoxHasJoc(descriptor);
                      }
                    }
                    childPos = child.end;
                  }
                }
              }
              entryPos = entry.end;
            }
          }
        }
        offset = box.end;
      }
    }

    await visit(0, size, 0);
    return AtmosBoxProbe(
      verified: verified,
      ec3SampleEntry: foundEc3,
      dec3Present: foundDec3,
      reason: verified
          ? 'dec3_joc_confirmed'
          : corrupt
              ? 'malformed_container'
              : foundDec3
                  ? 'dec3_joc_not_signalled'
                  : foundEc3
                      ? 'dec3_missing'
                      : 'no_ec3_sample_entry',
    );
  } on FileSystemException {
    return const AtmosBoxProbe(verified: false, reason: 'file_unreadable');
  } on FormatException {
    return const AtmosBoxProbe(verified: false, reason: 'invalid_container');
  } finally {
    await file?.close();
  }
}
