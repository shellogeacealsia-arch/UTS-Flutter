/// Text constants used across the app.
class AppStrings {
  AppStrings._();

  static const String appName = 'BloomShop';
  static const String tagline = 'Bloom Beautifully, Every Day';

  static const String skincare = 'Skincare';
  static const String makeUp = 'Make Up';
  static const String bodyCare = 'Body Care';
  static const String hairCare = 'Hair Care';

  static const List<String> categories = [skincare, makeUp, bodyCare, hairCare];

  static const String payBank = 'Bank Transfer (Simulated)';
  static const String payWallet = 'E-Wallet (Simulated)';
  static const String payCod = 'Cash on Delivery';
  static const List<String> paymentMethods = [payBank, payWallet, payCod];

  static const String demoAuthNotice =
      'Demo only: accounts are stored locally on this device and passwords '
      'are salted & hashed. This is NOT production-grade authentication.';

  static const String demoPaymentNotice =
      'Demo checkout: no real payment is processed and no real order is sent.';

  static const String promoCode = 'BLOOM10';
  static const int promoPercent = 10;
}
