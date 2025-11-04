import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../core/i18n/strings.dart';

class DuasScreen extends StatelessWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final s = S.of(context);
    final categoryMap = {
      'Morning': s.t('morning'),
      'Evening': s.t('evening'),
      'Before Eating': s.t('before_eating'),
      'After Eating': s.t('after_eating'),
      'Travel': s.t('travel'),
      'Seeking Forgiveness': s.t('seeking_forgiveness'),
      'Entering Home': s.t('entering_home'),
      'Leaving Home': s.t('leaving_home'),
    };
    
    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('duas')),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/duas/duas.json'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final Map<String, dynamic> data = json.decode(snapshot.data!);
          final categories = data.keys.toList();
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final cat = categories[i];
              final List<dynamic> items = data[cat];
              return ExpansionTile(
                title: Text(categoryMap[cat] ?? cat),
                children: items.map((e) {
                  return ListTile(
                    title: Text(e['title'] as String),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          e['arabic'] as String,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(e['translation'] as String),
                        if (e['reference'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${s.t('reference')}: ${e['reference']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
