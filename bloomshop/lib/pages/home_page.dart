import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/constants/app_strings.dart';
import 'package:bloomshop/core/utils/page_routes.dart';
import 'package:bloomshop/models/product.dart';
import 'package:bloomshop/models/user_profile.dart';
import 'package:bloomshop/pages/cart_page.dart';
import 'package:bloomshop/pages/favorite_page.dart';
import 'package:bloomshop/pages/product_list_page.dart';
import 'package:bloomshop/pages/profile_page.dart';
import 'package:bloomshop/providers/cart_provider.dart';
import 'package:bloomshop/providers/nav_provider.dart';
import 'package:bloomshop/providers/profile_provider.dart';
import 'package:bloomshop/providers/settings_provider.dart';
import 'package:bloomshop/repositories/product_repository.dart';
import 'package:bloomshop/widgets/category_item.dart';
import 'package:bloomshop/widgets/horizontal_product_section.dart';
import 'package:bloomshop/widgets/product_card.dart';
import 'package:bloomshop/widgets/profile_avatar.dart';
import 'package:bloomshop/widgets/search_bar_widget.dart';

/// Main shell: bottom navigation with Home, Favorite and Cart tabs.
/// (Profile is opened from the icon at the top right of Home.)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final index = context.select<NavProvider, int>((n) => n.index);
    final cartCount = context.select<CartProvider, int>((c) => c.totalItems);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [HomeTab(), FavoritePage(), CartPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.read<NavProvider>().setIndex(i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.mutedRose),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite, color: AppColors.mutedRose),
            label: 'Favorite',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_bag, color: AppColors.mutedRose),
            ),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _catalogKey = GlobalKey();

  String _query = '';
  String? _category;
  SortOption _sort = SortOption.featured;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToCatalog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catalogContext = _catalogKey.currentContext;
      if (catalogContext != null) {
        Scrollable.ensureVisible(
          catalogContext,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _selectCategory(String? category) {
    setState(() => _category = category);
    _scrollToCatalog();
  }

  void _openList(String title, List<Product> products) {
    Navigator.of(context).push(
      fadeSlideRoute<void>(ProductListPage(title: title, products: products)),
    );
  }

  void _showNotifications() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.local_offer_outlined, color: AppColors.mutedRose),
              title: Text('Glow Up Sale'),
              subtitle: Text('Use code ${AppStrings.promoCode} for 10% off at checkout.'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.new_releases_outlined, color: AppColors.mutedRose),
              title: Text('New arrivals are here'),
              subtitle: Text('Discover fresh skincare and makeup picks.'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<ProductRepository>();
    final profile =
        context.select<ProfileProvider, UserProfile?>((p) => p.profile);
    final showBell =
        context.select<SettingsProvider, bool>((s) => s.promoNotifications);

    final searching = _query.trim().isNotEmpty;
    final products =
        repository.search(query: _query, category: _category, sort: _sort);
    final showSections = !searching && _category == null;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, Beauty!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Find your everyday essentials',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showBell)
                        IconButton(
                          tooltip: 'Notifications',
                          onPressed: _showNotifications,
                          icon: const Badge(
                            smallSize: 8,
                            child: Icon(Icons.notifications_none_rounded),
                          ),
                        ),
                      InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => Navigator.of(context)
                            .push(fadeSlideRoute<void>(const ProfilePage())),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: ProfileAvatar(profile: profile, radius: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SearchBarWidget(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ],
              ),
            ),
          ),
          if (!searching)
            SliverToBoxAdapter(
              child: _PromoBanner(
                onShopNow: () => _selectCategory(AppStrings.skincare),
              ),
            ),
          if (!searching)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: SizedBox(
                  height: 96,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: AppStrings.categories.length,
                    itemBuilder: (context, index) {
                      final name = AppStrings.categories[index];
                      return CategoryItem(
                        name: name,
                        selected: _category == name,
                        onTap: () =>
                            _selectCategory(_category == name ? null : name),
                      );
                    },
                  ),
                ),
              ),
            ),
          if (showSections)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  HorizontalProductSection(
                    title: 'Best Sellers',
                    products: repository.bestSellers,
                    onSeeAll: () =>
                        _openList('Best Sellers', repository.bestSellers),
                  ),
                  const SizedBox(height: 8),
                  HorizontalProductSection(
                    title: 'New Arrivals',
                    products: repository.newArrivals,
                    style: HorizontalCardStyle.row,
                    onSeeAll: () =>
                        _openList('New Arrivals', repository.newArrivals),
                  ),
                ],
              ),
            ),
          SliverToBoxAdapter(
            child: KeyedSubtree(
              key: _catalogKey,
              child: _CatalogHeader(
                title: searching
                    ? 'Results for "${_query.trim()}"'
                    : (_category ?? 'All Products'),
                count: products.length,
                category: _category,
                sort: _sort,
                onCategory: _selectCategory,
                onSort: (value) => setState(() => _sort = value),
              ),
            ),
          ),
          if (products.isEmpty)
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 240,
                child: _NoResults(),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisExtent: 262,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ProductCard(product: products[index]),
                  childCount: products.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: AppColors.blushPink),
          SizedBox(height: 10),
          Text(
            'No products found',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            'Try a different keyword or category.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.onShopNow});

  final VoidCallback onShopNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.softPink, AppColors.blushPink],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33B76E79),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 190,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Glow Up Your Routine',
                      style: TextStyle(
                        fontSize: 19,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Up to 20% off selected skincare essentials this week.',
                      maxLines: 2,
                      style: TextStyle(fontSize: 12, height: 1.3),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: onShopNow,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.darkBrown,
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                      child: const Text('Shop Now'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Image.asset(
              'assets/images/banner.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.local_florist,
                size: 64,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({
    required this.title,
    required this.count,
    required this.category,
    required this.sort,
    required this.onCategory,
    required this.onSort,
  });

  final String title;
  final int count;
  final String? category;
  final SortOption sort;
  final ValueChanged<String?> onCategory;
  final ValueChanged<SortOption> onSort;

  @override
  Widget build(BuildContext context) {
    final filters = <String?>[null, ...AppStrings.categories];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PopupMenuButton<SortOption>(
                tooltip: 'Sort',
                initialValue: sort,
                onSelected: onSort,
                itemBuilder: (context) => [
                  for (final option in SortOption.values)
                    PopupMenuItem<SortOption>(
                      value: option,
                      child: Text(option.label),
                    ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort_rounded,
                          size: 20, color: AppColors.mutedRose),
                      const SizedBox(width: 4),
                      Text(
                        sort.label,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedRose,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final value = filters[index];
              final selected = value == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(value ?? 'All'),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: AppColors.mutedRose,
                  backgroundColor: AppColors.white,
                  side: BorderSide(
                    color: selected ? AppColors.mutedRose : AppColors.border,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.white : AppColors.darkBrown,
                  ),
                  onSelected: (_) => onCategory(value),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: Text(
            '$count product${count == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
