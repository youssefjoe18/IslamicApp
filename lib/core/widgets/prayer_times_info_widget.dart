import 'package:flutter/material.dart';
import '../services/prayer_calculation_service.dart';

class PrayerTimesInfoWidget extends StatelessWidget {
  const PrayerTimesInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final service = PrayerCalculationService();
    final today = DateTime.now();
    final todayTimes = service.calculatePrayerTimes(today);
    
    // Calculate seasonal comparison
    final winter = DateTime(today.year, 12, 21);
    final summer = DateTime(today.year, 6, 21);
    final winterTimes = service.calculatePrayerTimes(winter);
    final summerTimes = service.calculatePrayerTimes(summer);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Prayer Times Information',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            'Calculation Method',
            'Offline approximation with seasonal adjustments',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            'Daily Updates',
            'Times adjust automatically each day',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            'Seasonal Variation',
            '±3-4 minutes throughout the year',
          ),
          const SizedBox(height: 12),
          Text(
            'Seasonal Comparison:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSeasonalColumn(
                  context,
                  'Winter (Dec 21)',
                  winterTimes,
                  service,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSeasonalColumn(
                  context,
                  'Summer (Jun 21)',
                  summerTimes,
                  service,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonalColumn(
    BuildContext context,
    String season,
    Map<String, DateTime> times,
    PrayerCalculationService service,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          season,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        ...['Fajr', 'Maghrib', 'Isha'].map((prayer) {
          final time = times[prayer];
          if (time == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '$prayer: ${service.formatPrayerTime(time)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          );
        }),
      ],
    );
  }
}
