import 'package:flutter/material.dart';

import '../notifications/notification_level.dart';
import '../notifications/notification_request.dart';
import '../notifications/nova_alert_dispatcher.dart';
import '../notifications/nova_duplicate_alert_guard.dart';

class NovaTestCenterPage extends StatefulWidget {
  const NovaTestCenterPage({
    super.key,
    required this.dispatcher,
    required this.duplicateAlertGuard,
  });

  final NovaAlertDispatcher dispatcher;
  final NovaDuplicateAlertGuard duplicateAlertGuard;

  @override
  State<NovaTestCenterPage> createState() => _NovaTestCenterPageState();
}

class _NovaTestCenterPageState extends State<NovaTestCenterPage> {
  bool _isRunning = false;
  String _statusMessage = 'Bereit für einen NOVA-Systemtest.';
  NotificationRequest? _lastRequest;

  Future<void> _runTest({
    required NotificationRequest request,
    required String testLocation,
  }) async {
    if (_isRunning) {
      return;
    }

    setState(() {
      _isRunning = true;
      _lastRequest = request;
      _statusMessage = 'Test wird vorbereitet …';
    });

    try {
      final shouldDispatch = await widget.duplicateAlertGuard.shouldDispatch(
        request: request,
        locationName: testLocation,
      );

      if (!shouldDispatch) {
        if (!mounted) {
          return;
        }

        setState(() {
          _statusMessage =
              'Testwarnung wurde vom Duplicate Guard blockiert. '
              'Setzen Sie den Guard zurück und wiederholen Sie den Test.';
        });
        return;
      }

      final dispatched = await widget.dispatcher.dispatch(request);

      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = dispatched
            ? '${request.title} wurde erfolgreich an die NOVA-Pipeline übergeben.'
            : 'Die NOVA-Pipeline hat den Test nicht ausgeführt.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = 'Der NOVA-Systemtest ist fehlgeschlagen: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  Future<void> _resetDuplicateGuard() async {
    if (_isRunning) {
      return;
    }

    setState(() {
      _isRunning = true;
      _statusMessage = 'Duplicate Guard wird zurückgesetzt …';
    });

    try {
      await widget.duplicateAlertGuard.reset();

      if (!mounted) {
        return;
      }

      setState(() {
        _lastRequest = null;
        _statusMessage =
            'Duplicate Guard wurde zurückgesetzt. '
            'Alle Testwarnungen können erneut ausgeführt werden.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage =
            'Der Duplicate Guard konnte nicht zurückgesetzt werden: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'NOVA Test Center Ω',
            key: const Key('nova-test-center-title'),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Entwicklerwerkzeug zur kontrollierten Prüfung der '
            'NOVA-Alarm-, Benachrichtigungs- und Sprachpipeline.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          _StatusCard(
            statusMessage: _statusMessage,
            lastRequest: _lastRequest,
            isRunning: _isRunning,
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Alarmgenerator',
            subtitle:
                'Jeder Test verwendet echte NotificationRequest-Objekte '
                'und den produktiven NOVA Alert Dispatcher.',
            child: Column(
              children: [
                _TestTile(
                  key: const Key('nova-test-information'),
                  icon: Icons.info_outline,
                  title: 'Information testen',
                  subtitle: 'Push-Hinweis ohne automatische Sprachausgabe',
                  enabled: !_isRunning,
                  onPressed: () => _runTest(
                    testLocation: 'NOVA Test Center',
                    request: const NotificationRequest(
                      level: NotificationLevel.information,
                      title: 'NOVA Testinformation',
                      message:
                          'Dies ist ein kontrollierter NOVA Informationstest.',
                    ),
                  ),
                ),
                const Divider(height: 1),
                _TestTile(
                  key: const Key('nova-test-warning'),
                  icon: Icons.warning_amber_rounded,
                  title: 'Wetterwarnung testen',
                  subtitle: 'Warnmeldung mit akustischem Signal',
                  enabled: !_isRunning,
                  onPressed: () => _runTest(
                    testLocation: 'NOVA Test Center',
                    request: const NotificationRequest(
                      level: NotificationLevel.warning,
                      title: 'NOVA Testwarnung',
                      message:
                          'Dies ist eine kontrollierte NOVA Wetterwarnung.',
                      playSound: true,
                    ),
                  ),
                ),
                const Divider(height: 1),
                _TestTile(
                  key: const Key('nova-test-emergency'),
                  icon: Icons.crisis_alert,
                  title: 'Akutwarnung testen',
                  subtitle:
                      'Notfallstufe mit Ton; Sprache gemäß NOVA-Einstellung',
                  enabled: !_isRunning,
                  onPressed: () => _runTest(
                    testLocation: 'NOVA Test Center',
                    request: const NotificationRequest(
                      level: NotificationLevel.emergency,
                      title: 'NOVA Test-Akutwarnung',
                      message:
                          'Achtung. Dies ist eine kontrollierte '
                          'NOVA Akutwarnung.',
                      playSound: true,
                      speakMessage: true,
                    ),
                  ),
                ),
                const Divider(height: 1),
                _TestTile(
                  key: const Key('nova-test-extreme'),
                  icon: Icons.emergency,
                  title: 'Extremwarnung testen',
                  subtitle:
                      'Vollständiger Alarmtest mit Ton und Sprachanforderung',
                  enabled: !_isRunning,
                  onPressed: () => _runTest(
                    testLocation: 'NOVA Test Center Extrem',
                    request: const NotificationRequest(
                      level: NotificationLevel.emergency,
                      title: 'NOVA Test-Extremwarnung',
                      message:
                          'Achtung. NOVA Extremwarnung. '
                          'Dies ist ausschließlich ein kontrollierter Test.',
                      playSound: true,
                      speakMessage: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Entwicklerwerkzeuge',
            subtitle:
                'Testhistorie kontrollieren und wiederholte Warnungen '
                'erneut freigeben.',
            child: ListTile(
              key: const Key('nova-reset-duplicate-guard'),
              leading: const Icon(Icons.restart_alt),
              title: const Text('Duplicate Guard zurücksetzen'),
              subtitle: const Text(
                'Löscht den zuletzt gespeicherten Warnungs-Fingerprint.',
              ),
              enabled: !_isRunning,
              trailing: const Icon(Icons.chevron_right),
              onTap: _isRunning ? null : _resetDuplicateGuard,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hinweis: Die tatsächliche Signalausgabe richtet sich nach den '
            'gespeicherten NOVA-Einstellungen und der festgelegten '
            'Mindestwarnstufe.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.statusMessage,
    required this.lastRequest,
    required this.isRunning,
  });

  final String statusMessage;
  final NotificationRequest? lastRequest;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isRunning)
                  const SizedBox(
                    key: Key('nova-test-progress'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                else
                  const Icon(Icons.monitor_heart_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Systemstatus',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(statusMessage, key: const Key('nova-test-status')),
            if (lastRequest != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 4),
              Text('Letzter Request', style: theme.textTheme.labelLarge),
              const SizedBox(height: 6),
              Text('Titel: ${lastRequest!.title}'),
              Text('Stufe: ${lastRequest!.level.name}'),
              Text(
                'Ton angefordert: ${lastRequest!.playSound ? 'Ja' : 'Nein'}',
              ),
              Text(
                'Sprache angefordert: '
                '${lastRequest!.speakMessage ? 'Ja' : 'Nein'}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _TestTile extends StatelessWidget {
  const _TestTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      enabled: enabled,
      trailing: const Icon(Icons.play_arrow_rounded),
      onTap: enabled ? onPressed : null,
    );
  }
}
