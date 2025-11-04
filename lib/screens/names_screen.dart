import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NamesScreen extends StatefulWidget {
  const NamesScreen({super.key});

  @override
  State<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends State<NamesScreen> {
  List<Map<String, dynamic>> _names = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  Future<void> _loadNames() async {
    try {
      setState(() { _loading = true; _error = null; });
      final String data = await rootBundle.loadString('assets/names/names_of_allah.json');
      final List<dynamic> jsonData = json.decode(data);
      setState(() {
        _names = jsonData.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'خطأ في تحميل أسماء الله الحسنى';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('أسماء الله الحسنى'),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل أسماء الله الحسنى...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: color.error),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadNames,
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: color.primaryContainer,
                      child: Row(
                        children: [
                          Icon(Icons.star, color: color.primary),
                          const SizedBox(width: 8),
                          Text(
                            'الأسماء الحسنى التسعة والتسعون',
                            style: TextStyle(
                              color: color.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: _names.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final name = _names[index];
                          return _NameCard(
                            number: name['number'],
                            arabic: name['arabic'],
                            transliteration: name['transliteration'],
                            meaning: name['meaning'],
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadNames,
        tooltip: 'تحديث',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _NameCard extends StatelessWidget {
  final int number;
  final String arabic;
  final String transliteration;
  final String meaning;

  const _NameCard({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Number circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    color: color.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Name details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arabic name
                  Text(
                    arabic,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color.primary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 4),
                  // Transliteration
                  Text(
                    transliteration,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Meaning
                  Text(
                    meaning,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
