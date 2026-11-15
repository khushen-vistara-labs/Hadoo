import '../../data/entities/song_entity.dart';

/// Remote IDs survive copying and organization. Catalogue metadata must never
/// replace the location or audio details of an original already on this phone.
/// Do not test File.exists here: scoped storage may require its persisted URI.
bool isDownloadedDesktopOriginal(SongEntity row) =>
    row.sourceType == null &&
    row.filePath.isNotEmpty &&
    !row.filePath.startsWith('lokal://') &&
    !row.filePath.startsWith('ghost://');
