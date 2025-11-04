import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/preferences_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final PreferencesService preferencesService;

  ThemeCubit({required this.preferencesService})
      : super(preferencesService.getThemeIsDark() ? ThemeMode.dark : ThemeMode.light);

  Future<void> toggleTheme() async {
    final isDarkNow = state == ThemeMode.dark;
    final nextMode = isDarkNow ? ThemeMode.light : ThemeMode.dark;
    emit(nextMode);
    await preferencesService.setThemeIsDark(nextMode == ThemeMode.dark);
  }
}


