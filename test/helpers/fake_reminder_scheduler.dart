import 'package:denge/data/reminders.dart';

/// Records what AppState asked the OS notification layer to do.
class FakeReminderScheduler implements ReminderScheduler {
  bool grant = true;
  int permissionRequests = 0;
  final List<NotificationSettings> applied = [];

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grant;
  }

  @override
  Future<void> apply(NotificationSettings settings) async {
    applied.add(settings);
  }
}
