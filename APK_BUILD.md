# Hoşboy APK

Bu proje Android APK üretimi için Android klasörü eklenmiş Flutter projesidir.

## Gerekenler
- Flutter SDK
- Android Studio / Android SDK
- JDK 17+

## Debug APK
```bash
flutter pub get
flutter run
```

## Release APK
```bash
flutter pub get
flutter build apk --release
```

Çıktı:
`build/app/outputs/flutter-apk/app-release.apk`

## Backend
Gerçek kullanıcı, sipariş ve iki-admin yetkisi için Supabase bağlantısını şu şekilde verin:

```bash
flutter run --dart-define=SUPABASE_URL=YOUR_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Release:
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=YOUR_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

`supabase/schema.sql` dosyası iki aktif admin sınırını ve RLS güvenlik politikalarını içerir.

## Not
Bu ortamda Flutter SDK kurulu olmadığı için burada binary `.apk` derlemesi yapılamadı. Proje APK build için hazırlanmıştır.
