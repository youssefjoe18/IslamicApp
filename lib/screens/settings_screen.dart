import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/theme/theme_cubit.dart';
import '../blocs/locale/locale_cubit.dart';
import '../core/services/notification_service.dart';
import '../core/services/location_service.dart';
import '../core/services/prayer_service.dart';
import '../core/services/preferences_service.dart';
import '../core/i18n/strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifEnabled = false;
  final _notif = NotificationService();
  final _loc = LocationService();
  final _prayer = PrayerService();
  PreferencesService? _prefs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _prefs = context.read<PreferencesService?>();
    if (_prefs != null) {
      setState(() { _notifEnabled = _prefs!.getNotificationsEnabled(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('settings')),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              final isDark = mode == ThemeMode.dark;
              return SwitchListTile(
                value: isDark,
                onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                secondary: const Icon(Icons.palette),
                title: Text(s.t('dark_theme')),
                subtitle: const Text('Light / Dark'),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(s.t('language')),
            subtitle: const Text('Arabic / English'),
            trailing: DropdownButton<Locale>(
              value: context.watch<LocaleCubit>().state,
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
              ],
              onChanged: (loc) {
                if (loc != null) context.read<LocaleCubit>().setLocale(loc);
              },
            ),
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: Text(s.t('prayer_notifications')),
            subtitle: Text(_notifEnabled ? 'Prayer notifications enabled' : 'Prayer notifications disabled'),
            value: _notifEnabled,
            onChanged: (v) async {
              setState(() { _notifEnabled = v; });
              if (_prefs != null) await _prefs!.setNotificationsEnabled(v);
              if (v) {
                try {
                  await _notif.scheduleForTodayUsing(locationService: _loc, prayerService: _prayer);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Prayer notifications scheduled successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Failed to schedule notifications: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                await _notif.cancelAll();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔕 Prayer notifications cancelled'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
