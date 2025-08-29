import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/public_mix.dart';
import '../models/ad_banner.dart';
import '../providers/mixes_provider.dart';
import '../providers/ads_provider.dart';
import '../utils/theme.dart';
import '../widgets/mix_card.dart';
import '../widgets/mix_detail_dialog.dart';
import '../widgets/banner_carousel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final popularMixes = ref.watch(popularMixesProvider);
    final banners = ref.watch(bannersProvider);
    final searchResults = ref.watch(searchResultsProvider(_searchQuery));

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Заголовок и поиск
            _buildHeader(),
            
            // Основной контент
            Expanded(
              child: _searchQuery.isNotEmpty
                  ? _buildSearchResults(searchResults)
                  : _buildMainContent(popularMixes, banners),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          const Text(
            'Миксы для кальяна',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          
          // Поисковая строка
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: AppTheme.primaryText,
                fontSize: 18,
              ),
              decoration: const InputDecoration(
                hintText: 'Поиск микса...',
                hintStyle: TextStyle(color: AppTheme.secondaryText),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.secondaryText,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<PublicMix>> searchResults) {
    return searchResults.when(
      data: (mixes) => mixes.isEmpty
          ? const Center(
              child: Text(
                'Миксы не найдены',
                style: TextStyle(color: AppTheme.secondaryText),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
              itemCount: mixes.length,
              itemBuilder: (context, index) {
                return MixCard(
                  mix: mixes[index],
                  onTap: () => _showMixDetail(mixes[index]),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Ошибка поиска: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    AsyncValue<List<PublicMix>> popularMixes,
    AsyncValue<List<AdBanner>> banners,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Категории фруктов (горизонтальный скролл)
          _buildCategoriesRow(),
          
          const SizedBox(height: AppTheme.paddingMedium),
          
          // Популярные миксы недели
          _buildPopularMixes(popularMixes),
          
          // Карусель баннеров
          _buildBannersSection(banners),
          
          const SizedBox(height: AppTheme.paddingLarge),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow() {
    final categories = PublicMix.categories;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppTheme.paddingMedium),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: AppTheme.paddingMedium),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                margin: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => _navigateToCategory(category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPink.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.accentPink),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: AppTheme.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularMixes(AsyncValue<List<PublicMix>> popularMixes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
          child: Text(
            'Популярные миксы недели',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        
        popularMixes.when(
          data: (mixes) => mixes.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(AppTheme.paddingMedium),
                  child: Text(
                    'Популярных миксов пока нет.',
                    style: TextStyle(color: AppTheme.secondaryText),
                  ),
                )
              : Column(
                  children: mixes.map((mix) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingMedium,
                        vertical: 7,
                      ),
                      child: MixCard(
                        mix: mix,
                        onTap: () => _showMixDetail(mix),
                        showLikes: true,
                      ),
                    );
                  }).toList(),
                ),
          loading: () => const Padding(
            padding: EdgeInsets.all(AppTheme.paddingMedium),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Text(
              'Ошибка загрузки: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannersSection(AsyncValue<List<AdBanner>> banners) {
    return banners.when(
      data: (bannerList) => bannerList.isEmpty
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.paddingSmall),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
                  child: Text(
                    'Реклама',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.paddingSmall),
                
                BannerCarousel(
                  banners: bannerList,
                  onBannerTap: (banner) => _showBannerDetail(banner),
                ),
              ],
            ),
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  void _showMixDetail(PublicMix mix) {
    showDialog(
      context: context,
      builder: (context) => MixDetailDialog(
        mix: mix,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showBannerDetail(AdBanner banner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: Text(
          banner.title ?? 'Реклама',
          style: const TextStyle(color: AppTheme.primaryText),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (banner.description?.isNotEmpty == true) ...[
                Text(
                  banner.description!,
                  style: const TextStyle(color: AppTheme.primaryText),
                ),
                const SizedBox(height: 12),
              ],
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.cardBackground,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.cardBackground,
                      child: const Icon(
                        Icons.error,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (banner.clickUrl?.isNotEmpty == true)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _openBannerUrl(banner.clickUrl!);
              },
              child: const Text(
                'Открыть ссылку',
                style: TextStyle(color: AppTheme.accentPink),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Закрыть',
              style: TextStyle(color: AppTheme.accentPink),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCategory(String category) {
    // Навигация к детальному экрану категории
    // Можно реализовать позже или использовать существующую навигацию
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Переход к категории: $category'),
        backgroundColor: AppTheme.cardBackground,
      ),
    );
  }

  void _openBannerUrl(String url) async {
    // Открытие URL баннера
    // url_launcher уже добавлен в зависимости
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Открытие ссылки: $url'),
        backgroundColor: AppTheme.cardBackground,
      ),
    );
  }
}