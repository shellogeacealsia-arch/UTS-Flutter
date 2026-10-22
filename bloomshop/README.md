# BloomShop – Beauty Marketplace (Flutter, Material 3)

Aplikasi marketplace kosmetik demo: Splash → Welcome → Login/Register → Home (Home / Favorite / Cart),
Product Detail, Checkout, Order Success, My Orders, Order Detail, Profile, Edit Profile, Settings.

> **Status verifikasi:** kode ditulis tanpa Flutter SDK di lingkungan pembuatnya, jadi
> `flutter analyze` dan `flutter test` **belum pernah dijalankan** pada paket ini.
> Jalankan keduanya di komputer Anda (langkah di bawah) dan perbaiki bila ada pesan error/warning.

## Instalasi dari nol
1. Pasang Flutter SDK (stable) dan Android Studio (SDK + emulator), lalu cek: `flutter doctor`
2. Ekstrak ZIP, buka folder `bloomshop` di VS Code (ekstensi Flutter & Dart).
3. Di terminal, dalam folder proyek:
```bash
flutter create --platforms=android,web --project-name bloomshop .   # membuat folder android/ & web/
flutter pub get
dart format .
flutter analyze
flutter test
```
Jika `flutter create` menambahkan `test/widget_test.dart` bawaan yang error, hapus/ganti dengan file dari paket ini.

## Menjalankan
- Android (emulator/HP USB debugging): `flutter run`
- Web: `flutter run -d chrome`

## Error umum
| Masalah | Solusi |
|---|---|
| `Target of URI doesn't exist 'package:bloomshop/...'` | Pastikan `name: bloomshop` di pubspec.yaml dan jalankan `flutter pub get` |
| Gambar tidak muncul | Cek `assets:` di pubspec.yaml (indentasi), lalu `flutter clean && flutter pub get` |
| Versi SDK tidak cocok | Jalankan `flutter upgrade` (butuh Dart >= 3.3) |
| Gagal build Android (Gradle/JDK) | Gunakan JDK yang diminta `flutter doctor`, lalu `flutter clean` |
| Foto profil tidak bisa dipilih di iOS | Tambahkan `NSPhotoLibraryUsageDescription` di Info.plist (Android/Web tidak perlu) |

## Catatan penting
- **Autentikasi lokal hanya demo.** Akun disimpan di SharedPreferences, password di-hash (SHA-256 + salt acak),
  tidak pernah disimpan sebagai teks biasa, tetapi ini **tidak aman untuk produksi**. `AuthService` adalah
  interface; buat `FirebaseAuthService implements AuthService` lalu ganti `LocalAuthService` di `lib/app.dart`.
- **Pembayaran & pengiriman hanya simulasi.** Tidak ada transaksi nyata.
- Keranjang, favorit, dan pesanan disimpan per perangkat (bukan per akun); profil disimpan per email.
- Foto profil disimpan sebagai base64 (bukan path file) agar tetap valid di Flutter Web setelah reload.
- Font: memakai font bawaan Material agar jalan offline. Untuk Poppins, ikuti komentar di `pubspec.yaml`
  dan set `AppTheme.fontFamily = 'Poppins'`.
- Tema gelap tidak diterapkan, jadi tidak ada pengaturannya di Settings. Switch notifikasi yang ada
  benar-benar berfungsi (ikon lonceng di Home dan snackbar saat status pesanan berubah).
- Kode promo demo: `BLOOM10` (diskon 10% di Checkout).
- Gambar produk/logo/banner adalah ilustrasi lokal buatan `tool_generate_assets.py` (Pillow); ganti dengan foto asli dengan nama file yang sama.

## Penerapan OOP (untuk laporan)
- **Encapsulation:** `Product` menyimpan `_price`, `_rating`, `_stock`, `_isFavorite` secara private; diakses lewat getter.
  `CartItem._quantity` private, hanya bisa diubah lewat setter/method yang menjaga batas 1..stok. `Order._status` private.
- **Getter:** `Product.hasDiscount`, `discountPercent`, `inStock`; `CartItem.subtotal`, `canIncrease`; `Order.subtotal`, `total`, `itemCount`; `CartProvider.totalItems`, `totalPrice`.
- **Setter (benar-benar dipakai):** `Product.isFavorite=` dipanggil `FavoriteProvider.toggle/load`;
  `CartItem.quantity=` dipanggil konstruktor `CartItem` dan `CartProvider.add`; `Order.status=` dipanggil `OrderProvider.advanceStatus/cancel`;
  setter `Product.stock/price/rating` memvalidasi input (diuji di `test/models_test.dart`).
- **Constructor:** named/required parameter + initializer list (`Product`, `CartItem`, `Order`, `AuthResult.success/failure`).
- **Method/function:** `Product.applyDiscount`, `CartItem.increase/decrease`, `CartProvider.add/remove/clear`,
  `OrderProvider.placeOrder`, `Validators.*`, `Formatters.rupiah`.
- **Pemisahan tanggung jawab:** models → services (penyimpanan) → repository (katalog) → providers (state) → pages/widgets (UI).
  Abstraksi/polimorfisme: `AuthService` (interface) dengan `LocalAuthService`.
- **ListView.builder / GridView.builder:** Best Sellers & New Arrivals (horizontal `ListView.builder`), kategori & chip filter,
  katalog (`SliverGrid` dengan `SliverChildBuilderDelegate`, setara GridView.builder), `ProductListPage` (`GridView.builder`),
  Favorite, Cart, My Orders. Tidak ada 24 kartu yang ditulis manual – semuanya dibangun dari `ProductData.buildProducts()`.

## Pengujian
File: `test/models_test.dart`, `providers_test.dart`, `validators_test.dart`, `widget_test.dart` mencakup subtotal, total keranjang,
diskon, tambah/kurang kuantitas, batas stok, tambah/hapus favorit (+persistensi), pembuatan Order dari checkout,
status pesanan, validasi email & form checkout, formatter Rupiah, dan 24 produk (6 per kategori).
Hasil: **belum dijalankan** (lihat catatan status di atas).
