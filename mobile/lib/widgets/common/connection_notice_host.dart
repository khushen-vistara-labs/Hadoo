import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:flick/widgets/common/offline_notice.dart';

class ConnectionNoticeHost extends StatelessWidget {
  const ConnectionNoticeHost({
    super.key,
    required this.child,
    this.showNotice = true,
  });

  final Widget child;
  final bool showNotice;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return LayoutBuilder(
      builder: (context, hostConstraints) => Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, contentConstraints) {
                final noticeHeight =
                    hostConstraints.maxHeight - contentConstraints.maxHeight;
                double remaining(double inset) =>
                    math.max(0, inset - noticeHeight);

                return MediaQuery(
                  data: mediaQuery.copyWith(
                    size: contentConstraints.biggest,
                    padding: mediaQuery.padding.copyWith(
                      bottom: remaining(mediaQuery.padding.bottom),
                    ),
                    viewPadding: mediaQuery.viewPadding.copyWith(
                      bottom: remaining(mediaQuery.viewPadding.bottom),
                    ),
                    viewInsets: mediaQuery.viewInsets.copyWith(
                      bottom: remaining(mediaQuery.viewInsets.bottom),
                    ),
                  ),
                  child: child,
                );
              },
            ),
          ),
          if (showNotice) const OfflineNotice(),
        ],
      ),
    );
  }
}
