import 'package:flutter/material.dart';
import '../core/widgets/primary_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/nav/nav_cubit.dart';
import '../core/i18n/strings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final s = S.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        title: Text(s.t('home')),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Top green card like the reference design
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00A876), // Darker emerald green
                    Color(0xFF1BB896), // Darker teal
                    Color(0xFF2DB087), // Darker secondary green
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.6, 1.0],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00A876).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.t('assalamu'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color.onPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.t('welcome'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color.onPrimary.withOpacity(0.95)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '2:44', // placeholder time view only
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: color.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Icon(Icons.wb_sunny_outlined, color: color.onPrimary),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => context.read<NavCubit>().setIndex(1),
                    child: Text(
                      'اضغط لعرض المزيد من مواعيد الصلاه',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.onPrimary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick actions row (removed المساجد as requested)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _QuickActionTile(icon: Icons.menu_book, label: s.t('quran'), onTap: () => context.read<NavCubit>().setIndex(2)),
                _QuickActionTile(icon: Icons.menu_book_outlined, label: s.t('duas'), onTap: () => Navigator.of(context).pushNamed('/duas')),
                _QuickActionTile(icon: Icons.explore, label: s.t('qibla'), onTap: () => Navigator.of(context).pushNamed('/qibla')),
                _QuickActionTile(icon: Icons.fingerprint, label: s.t('tasbih'), onTap: () => Navigator.of(context).pushNamed('/tasbih')),
              ],
            ),

            const SizedBox(height: 16),

            // Two feature tiles row (Qibla finder, prayer log etc.) – keep navigation intact
            Row(
              children: [
                Expanded(
                  child: _FeatureTile(
                    title: 'محدد القبلة',
                    icon: Icons.explore,
                    onTap: () => context.read<NavCubit>().setIndex(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FeatureTile(
                    title: 'عدّاد التسبيح',
                    icon: Icons.fingerprint,
                    onTap: () => context.read<NavCubit>().setIndex(4),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _FeatureTile(
                    title: 'التقويم',
                    icon: Icons.calendar_month,
                    onTap: () => Navigator.of(context).pushNamed('/calendar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FeatureTile(
                    title: s.t('prayer_times'),
                    icon: Icons.access_time,
                    onTap: () => context.read<NavCubit>().setIndex(1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const _QuickActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
            ),
            child: Icon(icon, color: color.primary),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String title; final IconData icon; final VoidCallback onTap;
  const _FeatureTile({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color.primary),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

