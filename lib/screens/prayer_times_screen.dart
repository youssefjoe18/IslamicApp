import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/prayer/prayer_cubit.dart';
import '../core/services/location_service.dart';
import '../core/services/prayer_service.dart';
import '../core/services/notification_service.dart';
import '../core/i18n/strings.dart';
import '../core/widgets/prayer_countdown_widget.dart';
import '../core/widgets/prayer_times_info_widget.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final s = S.of(context);
    return BlocProvider(
      create: (_) => PrayerCubit(
        locationService: LocationService(),
        prayerService: PrayerService(),
        notificationService: NotificationService(),
      )..loadToday(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.t('prayer_times')),
          backgroundColor: color.primary,
          foregroundColor: color.onPrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<PrayerCubit>().loadToday();
              },
            ),
          ],
        ),
        body: BlocBuilder<PrayerCubit, PrayerState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.error}'),
                    ElevatedButton(
                      onPressed: () => context.read<PrayerCubit>().loadToday(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final prayerOrder = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
            final prayerNames = {
              'Fajr': 'Fajr',
              'Sunrise': 'Sunrise',
              'Dhuhr': 'Dhuhr',
              'Asr': 'Asr',
              'Maghrib': 'Maghrib',
              'Isha': 'Isha',
            };
            
            final today = DateTime.now();
            final dateStr = DateFormat('EEE, d MMM yyyy').format(today);

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 300,
                  backgroundColor: const Color(0xFF00A876),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF00A876), // Darker emerald green
                            Color(0xFF1BB896), // Darker teal
                            Color(0xFF2DB087), // Darker secondary green
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.7, 1.0],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.nextPrayer != null ? prayerNames[state.nextPrayer] ?? state.nextPrayer! : s.t('next_prayer'),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color.onPrimary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.nextPrayerTime != null ? DateFormat('hh:mm').format(state.nextPrayerTime!) : '--:--',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      color: color.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.nextPrayerTime != null ? DateFormat('a').format(state.nextPrayerTime!) : '',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color.onPrimary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dateStr,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color.onPrimary.withOpacity(0.9)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                      ),
                      child: Column(
                        children: [
                          for (final name in prayerOrder) ...[
                            Builder(
                              builder: (context) {
                                final time = state.times[name];
                                if (time == null) return const SizedBox.shrink();
                                return _PrayerRow(
                                  label: prayerNames[name] ?? name,
                                  time: time,
                                  assetName: _assetFor(name),
                                  highlight: state.nextPrayer == name,
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (state.nextPrayer != null && state.nextPrayerTime != null)
                  SliverToBoxAdapter(
                    child: PrayerCountdownWidget(
                      nextPrayerTime: state.nextPrayerTime!,
                      nextPrayerName: state.nextPrayer!,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 8,
                      children: [
                        _QuickAction(icon: 'assets/icons/qibla.png', fallback: Icons.explore, label: 'القبلة', onTap: () => Navigator.of(context).pushNamed('/qibla')),
                        _QuickAction(icon: 'assets/icons/tasbih.png', fallback: Icons.fingerprint, label: 'التسبيح', onTap: () => Navigator.of(context).pushNamed('/tasbih')),
                        _QuickAction(icon: 'assets/icons/adhkar.png', fallback: Icons.menu_book, label: 'الأذكار', onTap: () => Navigator.of(context).pushNamed('/duas')),
                        _QuickAction(icon: 'assets/icons/quran.png', fallback: Icons.menu_book, label: 'القرآن', onTap: () => Navigator.of(context).pushNamed('/quran')),
                        _QuickAction(icon: 'assets/icons/names.png', fallback: Icons.star, label: 'أسماء الله الحسنى', onTap: () => Navigator.of(context).pushNamed('/names')),
                        _QuickAction(icon: 'assets/icons/calendar.png', fallback: Icons.calendar_month, label: 'التقويم', onTap: () => Navigator.of(context).pushNamed('/calendar')),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: PrayerTimesInfoWidget(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Sunrise':
        return Icons.wb_sunny;
      case 'Dhuhr':
        return Icons.light_mode;
      case 'Asr':
        return Icons.wb_twilight_outlined;
      case 'Maghrib':
        return Icons.brightness_3;
      case 'Isha':
        return Icons.nightlight;
      default:
        return Icons.access_time;
    }
  }
}

// Helpers for redesigned UI
String _assetFor(String name) {
  switch (name) {
    case 'Fajr':
      return 'assets/icons/fajr.png';
    case 'Sunrise':
      return 'assets/icons/sunrise.png';
    case 'Dhuhr':
      return 'assets/icons/dhuhr.png';
    case 'Asr':
      return 'assets/icons/asr.png';
    case 'Maghrib':
      return 'assets/icons/maghrib.png';
    case 'Isha':
      return 'assets/icons/isha.png';
    default:
      return 'assets/icons/prayer.png';
  }
}

IconData _iconForLabel(String label) {
  switch (label) {
    case 'الفجر':
    case 'Fajr':
      return Icons.wb_twilight;
    case 'الشروق':
    case 'Sunrise':
      return Icons.wb_sunny;
    case 'الظهر':
    case 'Dhuhr':
      return Icons.light_mode;
    case 'العصر':
    case 'Asr':
      return Icons.wb_twilight_outlined;
    case 'المغرب':
    case 'Maghrib':
      return Icons.brightness_3;
    case 'العشاء':
    case 'Isha':
      return Icons.nightlight;
    default:
      return Icons.access_time;
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: color.error),
            const SizedBox(height: 16),
            Text(message, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final String label;
  final DateTime time;
  final String assetName;
  final bool highlight;
  const _PrayerRow({required this.label, required this.time, required this.assetName, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final t = TimeOfDay.fromDateTime(time);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlight ? color.secondaryContainer.withOpacity(0.4) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Checkbox(value: highlight, onChanged: (_) {}),
          Expanded(
            child: Row(
              children: [
                _AssetIcon(assetName: assetName, fallback: _iconForLabel(label)),
                const SizedBox(width: 8),
                Text(label, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          Text('${t.hourOfPeriod.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} ${t.period == DayPeriod.am ? 'ص' : 'م'}'),
        ],
      ),
    );
  }
}

class _AssetIcon extends StatelessWidget {
  final String assetName;
  final IconData fallback;
  const _AssetIcon({required this.assetName, required this.fallback});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetName,
      width: 24,
      height: 24,
      errorBuilder: (_, __, ___) => Icon(fallback),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String icon;
  final IconData fallback;
  final String label;
  final VoidCallback? onTap;
  const _QuickAction({required this.icon, required this.fallback, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
            ),
            child: Center(child: _AssetIcon(assetName: icon, fallback: fallback)),
          ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// (duplicates removed)
