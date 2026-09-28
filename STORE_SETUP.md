# Store hazırlığı

Flutter'ın `flutter create .` komutu Android ve iOS platform klasörlerini oluşturur.

Android:
- package/applicationId daha sonra benzersiz bir kimliğe çevrilecek (ör. `tm.hosboy.app`)
- release keystore oluşturulacak
- Google Play App Bundle (.aab) üretilecek

iOS:
- Bundle Identifier benzersiz yapılacak
- Apple Developer hesabında App ID oluşturulacak
- Signing/Team ayarlanacak
- App Store Connect kaydı oluşturulacak
- Xcode üzerinden archive/upload yapılacak

Bu proje şu an mağazaya gönderilmeye hazır bir MVP kaynak başlangıcıdır; gerçek backend ve mağaza kimlikleri eklenmeden yayınlanmamalıdır.
