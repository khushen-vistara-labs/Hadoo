import 'package:flutter/material.dart';
import 'package:flick/core/utils/artist_credits.dart';

/// Separate, scrollable targets keep long collaboration credits readable and
/// let every performer open their own artist page.
class ArtistCreditLinks extends StatelessWidget {
  const ArtistCreditLinks({
    super.key,
    required this.credit,
    required this.style,
    required this.onArtistTap,
  });
  final String credit;
  final TextStyle style;
  final ValueChanged<String> onArtistTap;

  @override
  Widget build(BuildContext context) {
    final artists = splitArtistCredits(credit);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < artists.length; i++) ...[
            if (i > 0) Text(', ', style: style),
            Semantics(
              button: true,
              label: 'Open artist ${artists[i]}',
              excludeSemantics: true,
              child: InkWell(
                onTap: () => onArtistTap(artists[i]),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(artists[i], style: style, maxLines: 1),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
