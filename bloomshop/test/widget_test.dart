import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloomshop/providers/favorite_provider.dart';
import 'package:bloomshop/repositories/product_repository.dart';
import 'package:bloomshop/services/favorite_service.dart';
import 'package:bloomshop/widgets/product_card.dart';

void main() {
  testWidgets('ProductCard shows name, brand and price', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = ProductRepository();
    final favorites = FavoriteProvider(FavoriteService(prefs), repository);
    await favorites.load();
    final product = repository.findById('p01')!;

    await tester.pumpWidget(
      ChangeNotifierProvider<FavoriteProvider>.value(
        value: favorites,
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 170,
                height: 262,
                child: ProductCard(product: product),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Hydrating Facial Cleanser'), findsOneWidget);
    expect(find.text('Lumi Skin'), findsOneWidget);
    expect(find.text('Rp 78.000'), findsOneWidget);
  });
}
