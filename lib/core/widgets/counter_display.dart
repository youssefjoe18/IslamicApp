import 'package:flutter/material.dart';
import '../i18n/strings.dart';

class CounterDisplay extends StatelessWidget {
  final int count;
  final int preset;

  const CounterDisplay({super.key, required this.count, required this.preset});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final progress = (preset == 0) ? 0.0 : (count % preset) / preset;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 10,
              ),
              Text(
                '$count',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: color.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text('${S.of(context).t('preset')}: $preset')
      ],
    );
  }
}


