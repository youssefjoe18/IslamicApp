import 'package:flutter/material.dart';

class S {
  final Locale locale;
  S(this.locale);

  static S of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return S(locale);
  }

  String t(String key) {
    final lang = locale.languageCode;
    return (_translations[lang] ?? _translations['en']!)[key] ?? key;
  }
}

const Map<String, Map<String, String>> _translations = {
  'en': {
    // Navigation
    'home': 'Home',
    'prayer': 'Prayer',
    'quran': 'Quran',
    'qibla': 'Qibla',
    'tasbih': 'Tasbih',
    'duas': 'Azkar',
    'settings': 'Settings',
    
    // Home Screen
    'assalamu': 'Assalamu Alaikum',
    'welcome': 'Welcome to your daily companion.',
    'prayer_times': 'Prayer Times',
    'next_prayer': 'Next Prayer',
    
    // Settings
    'dark_theme': 'Dark Theme',
    'language': 'Language',
    'prayer_notifications': 'Prayer Notifications',
    'english': 'English',
    'arabic': 'العربية',
    
    // Prayer Times
    'fajr': 'Fajr',
    'sunrise': 'Sunrise',
    'dhuhr': 'Dhuhr',
    'asr': 'Asr',
    'maghrib': 'Maghrib',
    'isha': 'Isha',
    'enable_later': 'Enable prayer times later',
    'prayer_desc': 'We\'ll re-enable location and notifications after dependencies are stable.',
    'notify': 'Notify',
    'notification_scheduled': 'Notification scheduled',
    
    // Qibla
    'qibla_direction': 'Qibla Direction',
    'no_sensor': 'No sensor data',
    
    // Tasbih
    'preset': 'Preset',
    'reset': 'Reset',
    'completed': 'Completed',
    'no_limit': 'No Limit',
    'rounds': 'Rounds',
    
    // Quran
    'surahs': 'Surahs',
    'verses': 'verses',
    'meccan': 'Meccan',
    'medinan': 'Medinan',
    
    // Duas
    'morning': 'Morning',
    'evening': 'Evening',
    'before_eating': 'Before Eating',
    'after_eating': 'After Eating',
    'travel': 'Travel',
    'seeking_forgiveness': 'Seeking Forgiveness',
    'entering_home': 'Entering Home',
    'leaving_home': 'Leaving Home',
    'reference': 'Reference',
  },
  'ar': {
    // Navigation
    'home': 'الرئيسية',
    'prayer': 'الصلاة',
    'quran': 'القرآن',
    'qibla': 'القبلة',
    'tasbih': 'تسبيح',
    'duas': 'الأذكار',
    'settings': 'الإعدادات',
    
    // Home Screen
    'assalamu': 'السلام عليكم',
    'welcome': 'مرحبًا بك في رفيقك اليومي.',
    'prayer_times': 'مواقيت الصلاة',
    'next_prayer': 'الصلاة التالية',
    
    // Settings
    'dark_theme': 'الوضع الداكن',
    'language': 'اللغة',
    'prayer_notifications': 'إشعارات الصلاة',
    'english': 'English',
    'arabic': 'العربية',
    
    // Prayer Times
    'fajr': 'الفجر',
    'sunrise': 'الشروق',
    'dhuhr': 'الظهر',
    'asr': 'العصر',
    'maghrib': 'المغرب',
    'isha': 'العشاء',
    'enable_later': 'تفعيل مواقيت الصلاة لاحقًا',
    'prayer_desc': 'سنعيد تفعيل الموقع والإشعارات بعد استقرار التبعيات.',
    'notify': 'إشعار',
    'notification_scheduled': 'تم جدولة الإشعار',
    
    // Qibla
    'qibla_direction': 'اتجاه القبلة',
    'no_sensor': 'لا توجد بيانات من المستشعر',
    
    // Tasbih
    'preset': 'العدد المحدد',
    'reset': 'إعادة تعيين',
    'completed': 'مكتمل',
    'no_limit': 'بدون حد',
    'rounds': 'الجولات',
    
    // Quran
    'surahs': 'السور',
    'verses': 'آية',
    'meccan': 'مكية',
    'medinan': 'مدنية',
    
    // Duas
    'morning': 'الصباح',
    'evening': 'المساء',
    'before_eating': 'قبل الأكل',
    'after_eating': 'بعد الأكل',
    'travel': 'السفر',
    'seeking_forgiveness': 'طلب المغفرة',
    'entering_home': 'الدخول إلى البيت',
    'leaving_home': 'الخروج من البيت',
    'reference': 'المرجع',
  }
};
