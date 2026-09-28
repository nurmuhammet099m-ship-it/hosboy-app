# Hoşboy v1.1 — two-admin secure architecture

Bu sürüm, önceki Hoşboy başlangıç projesinin üzerine **yalnızca 2 yetkili admin** modelini ekler.

## Admin güvenliği

- Admin paneli iki kişiden fazlasına açılamaz.
- Giriş modeli telefon + OTP olacak.
- Yetki telefon numarasını Flutter koduna gömmek yerine Supabase `admins` tablosunda tutulur.
- PostgreSQL trigger aktif admin sayısını 2 ile sınırlar.
- RLS sayesinde müşteri uygulaması `isAdmin=true` gibi sahte bir değer göndererek admin olamaz.
- Adminler uygulamaya kayıt olan kullanıcıları görebilir.

## Admin panelinde

- Uygulama kullanıcıları
- Siparişler
- Ürün/stok/fiyat yönetimi
- Müşteri soruları
- Yorumlar
- Sonraki aşamada gerçek zamanlı bildirimler

## Kurulum

1. Flutter SDK kurulu bir bilgisayarda:
   `flutter create .`
2. Bağımlılıkları:
   `flutter pub get`
3. Supabase projesi açın.
4. `supabase/schema.sql` dosyasını Supabase SQL Editor'da çalıştırın.
5. İki admin kullanıcısının telefon OTP ile hesaplarını oluşturun.
6. Güvenilir SQL/admin ortamından `public.admins` tablosuna yalnızca bu iki kullanıcıyı ekleyin.
7. Çalıştırın:
   `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

### Önemli

Bu zip içinde gerçek Supabase URL/key veya admin telefon numarası yoktur. Bunları kaynak koda koymak güvenli değildir.

Android/iOS mağaza paketleri için `flutter create .` ile platform klasörlerini oluşturup uygulama kimlikleri, imzalama ve mağaza hesapları ayrıca ayarlanmalıdır.
