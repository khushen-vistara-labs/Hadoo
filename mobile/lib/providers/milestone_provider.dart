import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/milestone_service.dart';

final milestoneServiceProvider = Provider<MilestoneService>((ref) {
  return MilestoneService();
});

final milestoneRevisionProvider = StreamProvider<int>((ref) async* {
  var revision = 0;
  yield revision;
  await for (final _ in MilestoneService.changes.stream) yield ++revision;
});
