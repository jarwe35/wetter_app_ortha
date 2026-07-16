import 'notification_request.dart';

class NovaAlertFingerprint {
  const NovaAlertFingerprint();

  String create({required NotificationRequest request, String? locationName}) {
    final normalizedLocation = _normalize(locationName ?? '');
    final normalizedTitle = _normalize(request.title);
    final normalizedMessage = _normalize(request.message);

    return [
      request.level.name,
      normalizedLocation,
      normalizedTitle,
      normalizedMessage,
      request.playSound ? 'sound' : 'silent',
      request.speakMessage ? 'speech' : 'no-speech',
    ].join('|');
  }

  String _normalize(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }
}
