import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/tasbih/tasbih_cubit.dart';
import '../core/i18n/strings.dart';

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('tasbih')),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
      ),
      body: BlocBuilder<TasbihCubit, TasbihState>(
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Large count display
                  Text(
                    '${state.count}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: color.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Preset text
                  Text(
                    '${s.t('preset')}: ${state.preset}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Action buttons: -, +, Reset
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minus button
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: color.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.remove, size: 32),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.read<TasbihCubit>().decrement();
                          },
                          color: color.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Plus button
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: color.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, size: 32),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.read<TasbihCubit>().increment();
                          },
                          color: color.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Reset button
                      OutlinedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          context.read<TasbihCubit>().reset();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          side: BorderSide(color: color.primary, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          s.t('reset'),
                          style: TextStyle(
                            color: color.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  
                  // Preset chips
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _PresetChip(
                        value: 33,
                        label: '33',
                        selected: state.preset == 33,
                        onSelected: () {
                          context.read<TasbihCubit>().setPreset(33);
                        },
                      ),
                      _PresetChip(
                        value: 100,
                        label: '100',
                        selected: state.preset == 100,
                        onSelected: () {
                          context.read<TasbihCubit>().setPreset(100);
                        },
                      ),
                      _PresetChip(
                        value: 0,
                        label: '0',
                        selected: state.preset == 0,
                        onSelected: () {
                          context.read<TasbihCubit>().setPreset(0);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final int value;
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _PresetChip({
    required this.value,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: color.primaryContainer,
      checkmarkColor: color.onPrimaryContainer,
      side: BorderSide(
        color: selected ? color.primaryContainer : Colors.grey[300]!,
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
