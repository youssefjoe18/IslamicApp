import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/preferences_service.dart';

class LocaleCubit extends Cubit<Locale> {
  final PreferencesService preferencesService;

  LocaleCubit({required this.preferencesService}) : super(_initialLocale(preferencesService));

  static Locale _initialLocale(PreferencesService prefs) {
    final code = prefs.prefs.getString('locale_code') ?? 'en';
    return Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    await preferencesService.prefs.setString('locale_code', locale.languageCode);
  }
}


