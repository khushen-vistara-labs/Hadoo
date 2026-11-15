import 'dart:math' as math;

import 'package:flick/data/repositories/song_repository.dart';
import 'package:flutter/material.dart';

import 'classipod_data.dart';

class ClassipodRowData {
  const ClassipodRowData(this.title, [this.subtitle]);
  final String title;
  final String? subtitle;
}

/// Fixed, text-scaled rows keep the wheel cursor visible even in a large library.
class ClassipodList extends StatefulWidget {
  const ClassipodList({
    super.key,
    required this.rows,
    required this.selected,
    required this.onSelect,
    required this.reduceMotion,
  });

  final List<ClassipodRowData> rows;
  final int selected;
  final ValueChanged<int>? onSelect;
  final bool reduceMotion;

  @override
  State<ClassipodList> createState() => _ClassipodListState();
}

class _ClassipodListState extends State<ClassipodList> {
  final _scroll = ScrollController();
  int? _lastSelected;
  double? _lastExtent;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extent =
        80.0 * math.max(1.0, MediaQuery.textScalerOf(context).scale(14) / 14);
    if (_lastSelected != widget.selected || _lastExtent != extent) {
      _lastSelected = widget.selected;
      _lastExtent = extent;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scroll.hasClients) return;
        final top = widget.selected * extent;
        final bottom = top + extent;
        final position = _scroll.position;
        final target = top < position.pixels
            ? top
            : bottom > position.pixels + position.viewportDimension
            ? bottom - position.viewportDimension
            : position.pixels;
        final bounded = target.clamp(0.0, position.maxScrollExtent);
        if ((bounded - position.pixels).abs() < 1) return;
        if (widget.reduceMotion) {
          _scroll.jumpTo(bounded);
        } else {
          _scroll.animateTo(
            bounded,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
          );
        }
      });
    }
    return ListView.builder(
      controller: _scroll,
      itemExtent: extent,
      itemCount: widget.rows.length,
      itemBuilder: (context, index) {
        final row = widget.rows[index];
        final selected = index == widget.selected;
        return Semantics(
          selected: selected,
          button: true,
          child: Material(
            color: selected ? const Color(0xff174b8c) : Colors.transparent,
            child: InkWell(
              onTap: widget.onSelect == null
                  ? null
                  : () => widget.onSelect!(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xff15253a),
                            ),
                          ),
                          if (row.subtitle != null)
                            Text(
                              row.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xff485364),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: selected ? Colors.white : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The facing album and two angled neighbours use only existing library art.
/// Buttons, swipe and wheel all address the same bounded selection.
class ClassipodCoverFlow extends StatelessWidget {
  const ClassipodCoverFlow({
    super.key,
    required this.albums,
    required this.selected,
    required this.onMove,
    required this.onOpen,
    required this.artwork,
    required this.reduceMotion,
  });

  final List<AlbumGroup> albums;
  final int selected;
  final ValueChanged<int> onMove;
  final VoidCallback onOpen;
  final ClassipodArtworkBuilder artwork;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final album = albums[selected];
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(180.0, constraints.maxWidth * .48);
        return SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity.abs() > 40) onMove(velocity < 0 ? 1 : -1);
                },
                child: SizedBox(
                  height: size + 32,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      for (final offset in [-1, 1, 0])
                        if (selected + offset >= 0 &&
                            selected + offset < albums.length)
                          Transform.translate(
                            offset: Offset(offset * size * .64, 0),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, .001)
                                ..rotateY(reduceMotion ? 0 : offset * -.65)
                                ..scaleByDouble(
                                  offset == 0 ? 1 : .72,
                                  offset == 0 ? 1 : .72,
                                  1,
                                  1,
                                ),
                              child: SizedBox.square(
                                dimension: size,
                                child: Semantics(
                                  button: true,
                                  label: offset == 0
                                      ? 'Open album ${album.albumName}'
                                      : '${offset < 0 ? 'Previous' : 'Next'} album ${albums[selected + offset].albumName}',
                                  child: Material(
                                    elevation: offset == 0 ? 6 : 1,
                                    clipBehavior: Clip.antiAlias,
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      onTap: offset == 0
                                          ? onOpen
                                          : () => onMove(offset),
                                      child: ExcludeSemantics(
                                        child: IgnorePointer(
                                          child: AnimatedSwitcher(
                                            duration: reduceMotion
                                                ? Duration.zero
                                                : const Duration(
                                                    milliseconds: 160,
                                                  ),
                                            child: SizedBox.expand(
                                              key: ValueKey(
                                                albums[selected + offset].key,
                                              ),
                                              child: artwork(
                                                classipodAlbumArtwork(
                                                  albums[selected + offset],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      album.albumName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(album.albumArtist, textAlign: TextAlign.center),
                    Text('${selected + 1} of ${albums.length} albums'),
                    TextButton(
                      onPressed: onOpen,
                      child: const Text('Open album'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
