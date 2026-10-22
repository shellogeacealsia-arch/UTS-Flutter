import 'package:bloomshop/core/constants/app_strings.dart';
import 'package:bloomshop/models/product.dart';

/// Dummy catalog: exactly 24 products (6 per category).
/// Every image path points to a real file in assets/images/products/.
class ProductData {
  ProductData._();

  static String _img(String file) => 'assets/images/products/$file.png';

  /// Builds a fresh list each time (products are mutable: favorite flag).
  static List<Product> buildProducts() {
    return [
      // ------------------------------ Skincare ------------------------------
      Product(
        id: 'p01',
        name: 'Gentle Cleanser',
        brand: 'Cetaphil',
        category: AppStrings.skincare,
        price: 78000,
        description:
            'A creamy, pH-balanced cleanser that lifts away makeup and daily '
            'impurities without stripping moisture. Enriched with glycerin and '
            'panthenol for soft, comfortable skin after every wash.',
        imagePath: _img('gentle_cleanser'),
        rating: 4.8,
        reviewCount: 1243,
        isBestSeller: true,
        stock: 48,
      ),
      Product(
        id: 'p02',
        name: 'Brightening Toner',
        brand: 'Skin1004',
        category: AppStrings.skincare,
        price: Product.applyDiscount(65000, 15),
        originalPrice: 65000,
        description:
            'Gentle brightening toner with niacinamide and rice extract. Helps '
            'improve dull-looking skin, even out skin tone, and leave skin feeling '
            'smooth, fresh, and hydrated.',
        imagePath: _img('brightening_toner'),
        rating: 4.6,
        reviewCount: 862,
        stock: 62,
      ),
      Product(
        id: 'p03',
        name: 'Glow Serum',
        brand: 'Beauty of Joseon',
        category: AppStrings.skincare,
        price: Product.applyDiscount(145000, 20),
        originalPrice: 145000,
        description:
            'Brightening serum with 10% stabilised vitamin C and niacinamide '
            'to help fade dull tone and uneven texture. Lightweight and '
            'fast-absorbing, perfect for your morning routine.',
        imagePath: _img('glow_serum'),
        rating: 4.9,
        reviewCount: 2310,
        isBestSeller: true,
        stock: 35,
      ),
      Product(
        id: 'p04',
        name: 'Moisture Essence',
        brand: 'Laneige',
        category: AppStrings.skincare,
        price: 129000,
        description:
            'Multi-weight hyaluronic acid serum that delivers deep, lasting '
            'hydration. Leaves skin plump, smooth and dewy all day long.',
        imagePath: _img('moisture_essence'),
        rating: 4.7,
        reviewCount: 534,
        isNewArrival: true,
        stock: 40,
      ),
      Product(
        id: 'p05',
        name: 'Hydra Cream',
        brand: 'EMBRIYOLISSE',
        category: AppStrings.skincare,
        price: 98000,
        description:
            'Oil-free gel-cream moisturizer with ceramides and squalane. '
            'Strengthens the skin barrier and keeps skin balanced for 24 '
            'hours of hydration.',
        imagePath: _img('hydra_cream'),
        rating: 4.5,
        reviewCount: 701,
        stock: 55,
      ),
      Product(
        id: 'p06',
        name: 'Sunscreen',
        brand: 'ANESSA',
        category: AppStrings.skincare,
        price: 89000,
        description:
            'Invisible, lightweight sunscreen with SPF 50 PA++++. No white '
            'cast, no sticky feel, and a smooth base for makeup.',
        imagePath: _img('sunscreen'),
        rating: 4.8,
        reviewCount: 1876,
        isBestSeller: true,
        stock: 70,
      ),
      // ------------------------------- Make Up -------------------------------
      Product(
        id: 'p07',
        name: 'Lip Tint',
        brand: 'DIOR',
        category: AppStrings.makeUp,
        price: 69000,
        description:
            'Soft-focus lip tint with a velvety finish and buildable colour. '
            'Comfortable, lightweight and long-wearing from morning to night.',
        imagePath: _img('lip_tint'),
        rating: 4.7,
        reviewCount: 1492,
        isBestSeller: true,
        stock: 80,
      ),
      Product(
        id: 'p08',
        name: 'Lipstick',
        brand: 'YSL',
        category: AppStrings.makeUp,
        price: Product.applyDiscount(85000, 10),
        originalPrice: 85000,
        description:
            'Highly pigmented matte lipstick that glides on smoothly and '
            'does not feel dry. Enriched with vitamin E and jojoba oil.',
        imagePath: _img('lipstick'),
        rating: 4.6,
        reviewCount: 988,
        isNewArrival: true,
        stock: 45,
      ),
      Product(
        id: 'p09',
        name: 'Cushion',
        brand: 'YSL',
        category: AppStrings.makeUp,
        price: 159000,
        description:
            'Buoyant cushion foundation with medium, buildable coverage and '
            'a natural skin-like glow. SPF 35 with a refillable compact.',
        imagePath: _img('cushion'),
        rating: 4.8,
        reviewCount: 1105,
        isBestSeller: true,
        stock: 30,
      ),
      Product(
        id: 'p10',
        name: 'Rare Beaty',
        brand: 'Velour',
        category: AppStrings.makeUp,
        price: 75000,
        description:
            'Silky liquid blush that melts into skin for a natural flush of '
            'colour. Blend with fingertips or a sponge.',
        imagePath: _img('blush'),
        rating: 4.7,
        reviewCount: 456,
        isNewArrival: true,
        stock: 38,
      ),
      Product(
        id: 'p11',
        name: 'Brow Pencil',
        brand: 'Maybelline',
        category: AppStrings.makeUp,
        price: 49000,
        description:
            'Ultra-fine brow pencil with a spoolie brush for natural, '
            'hair-like strokes. Smudge-resistant and easy to build.',
        imagePath: _img('brow_pencil'),
        rating: 4.4,
        reviewCount: 612,
        stock: 90,
      ),
      Product(
        id: 'p12',
        name: 'Highlighter',
        brand: 'Make Over',
        category: AppStrings.makeUp,
        price: 72000,
        description:
            'Lightweight illuminating highlighter that adds a radiant '
            'glow to the skin. Blends effortlessly for a smooth, luminous '
            'finish that enhances your natural features.',
        imagePath: _img('highlighter'),
        rating: 4.5,
        reviewCount: 389,
        isNewArrival: true,
        stock: 4,
      ),
      // ------------------------------ Body Care ------------------------------
      Product(
        id: 'p13',
        name: 'Body Lotion',
        brand: 'Careso',
        category: AppStrings.bodyCare,
        price: 82000,
        description:
            'Rich yet fast-absorbing body lotion with shea butter and '
            'almond oil. Delivers 48-hour moisture with a soft, light scent.',
        imagePath: _img('body_lotion'),
        rating: 4.7,
        reviewCount: 1320,
        isBestSeller: true,
        stock: 66,
      ),
      Product(
        id: 'p14',
        name: 'Body Scrub',
        brand: 'CLARINS',
        category: AppStrings.bodyCare,
        price: Product.applyDiscount(79000, 10),
        originalPrice: 79000,
        description:
            'Exfoliating sugar and coffee body scrub that polishes away '
            'dull skin, leaving it smooth and glowing.',
        imagePath: _img('body_scrub'),
        rating: 4.5,
        reviewCount: 540,
        stock: 44,
      ),
      Product(
        id: 'p15',
        name: 'Shower Gel',
        brand: 'SLAVINA',
        category: AppStrings.bodyCare,
        price: 59000,
        description:
            'Creamy body wash with a fresh floral fragrance. Cleanses '
            'gently while keeping skin soft and hydrated.',
        imagePath: _img('shower_gel'),
        rating: 4.4,
        reviewCount: 428,
        isNewArrival: true,
        stock: 75,
      ),
      Product(
        id: 'p16',
        name: 'Hand Cream',
        brand: 'Vaseline',
        category: AppStrings.bodyCare,
        price: 39000,
        description:
            'Compact hand cream that absorbs quickly and nourishes dry '
            'hands. Non-greasy and perfect to carry in your bag.',
        imagePath: _img('hand_cream'),
        rating: 4.6,
        reviewCount: 905,
        stock: 120,
      ),
      Product(
        id: 'p17',
        name: 'Body Butter',
        brand: 'The Body Shop',
        category: AppStrings.bodyCare,
        price: 115000,
        description:
            'Whipped body butter with cocoa butter and vitamin E for '
            'intense, long-lasting nourishment of very dry skin.',
        imagePath: _img('body_butter'),
        rating: 4.8,
        reviewCount: 764,
        isBestSeller: true,
        stock: 28,
      ),
      Product(
        id: 'p18',
        name: 'Body Mist',
        brand: 'Bath & Body Works',
        category: AppStrings.bodyCare,
        price: 69000,
        description:
            'Light and airy body mist with notes of peony, vanilla and '
            'musk. A soft fragrance to refresh you all day.',
        imagePath: _img('body_mist'),
        rating: 4.3,
        reviewCount: 317,
        isNewArrival: true,
        stock: 52,
      ),
      // ------------------------------ Hair Care ------------------------------
      Product(
        id: 'p19',
        name: 'Shampoo',
        brand: 'TRESemmé',
        category: AppStrings.hairCare,
        price: 74000,
        description:
            'Sulfate-free shampoo with argan oil and keratin that cleanses '
            'gently while leaving hair soft, shiny and manageable.',
        imagePath: _img('shampoo'),
        rating: 4.6,
        reviewCount: 1020,
        isBestSeller: true,
        stock: 58,
      ),
      Product(
        id: 'p20',
        name: 'Conditioner',
        brand: 'MAKARIZO',
        category: AppStrings.hairCare,
        price: 76000,
        description:
            'Deep-conditioning formula that repairs split ends and tames '
            'frizz. Detangles instantly for silky smooth hair.',
        imagePath: _img('conditioner'),
        rating: 4.5,
        reviewCount: 684,
        stock: 50,
      ),
      Product(
        id: 'p21',
        name: 'Hair Serum',
        brand: 'L\'Oréal Paris',
        category: AppStrings.hairCare,
        price: Product.applyDiscount(99000, 15),
        originalPrice: 99000,
        description:
            'Lightweight leave-in serum with camellia oil that adds '
            'shine and protects from daily damage, with no greasy feel.',
        imagePath: _img('hair_serum1'),
        rating: 4.7,
        reviewCount: 1198,
        isBestSeller: true,
        stock: 41,
      ),
      Product(
        id: 'p22',
        name: 'Hair Mask',
        brand: 'CBD Hair',
        category: AppStrings.hairCare,
        price: 112000,
        description:
            'Intensive weekly hair mask with shea butter and avocado oil '
            'to revive dry, damaged hair in just five minutes.',
        imagePath: _img('hair_mask'),
        rating: 4.8,
        reviewCount: 472,
        isNewArrival: true,
        stock: 33,
      ),
      Product(
        id: 'p23',
        name: 'Hair Tonic',
        brand: 'NR',
        category: AppStrings.hairCare,
        price: 85000,
        description:
            'Scalp tonic with ginseng and caffeine that refreshes the '
            'scalp and supports strong, healthy-looking hair.',
        imagePath: _img('hair_tonic'),
        rating: 4.4,
        reviewCount: 298,
        stock: 3,
      ),
      Product(
        id: 'p24',
        name: 'Heat Protection',
        brand: 'TRESemmé',
        category: AppStrings.hairCare,
        price: 68000,
        description:
            'Protective spray that shields hair from styling heat up to '
            '230°C while adding a smooth, glossy finish.',
        imagePath: _img('heat_protection'),
        rating: 4.5,
        reviewCount: 351,
        isNewArrival: true,
        stock: 60,
      ),
    ];
  }
}
