import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/ad_banner.dart';
import '../utils/theme.dart';

class BannerCarousel extends StatefulWidget {
  final List<AdBanner> banners;
  final Function(AdBanner)? onBannerTap;
  final Duration autoScrollDuration;

  const BannerCarousel({
    super.key,
    required this.banners,
    this.onBannerTap,
    this.autoScrollDuration = const Duration(seconds: 10), // Как в Android версии
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Перезапускаем автопрокрутку если изменился список баннеров
    if (oldWidget.banners.length != widget.banners.length) {
      _restartAutoScroll();
    }
  }

  void _startAutoScroll() {
    if (widget.banners.length <= 1) return;
    
    _autoScrollTimer = Timer.periodic(widget.autoScrollDuration, (timer) {
      if (mounted && _pageController.hasClients) {
        _currentIndex = (_currentIndex + 1) % widget.banners.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _restartAutoScroll() {
    _autoScrollTimer?.cancel();
    _currentIndex = 0;
    _startAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: AdBanner.bannerHeight, // 158dp как в спецификации Android версии
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.banners.length,
        itemBuilder: (context, index) {
          final banner = widget.banners[index];
          return _buildBannerItem(banner);
        },
      ),
    );
  }

  Widget _buildBannerItem(AdBanner banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
      child: GestureDetector(
        onTap: () {
          // Останавливаем автопрокрутку при тапе
          _autoScrollTimer?.cancel();
          widget.onBannerTap?.call(banner);
          // Возобновляем автопрокрутку через 5 секунд
          Timer(const Duration(seconds: 5), _startAutoScroll);
        },
        child: Container(
          width: AdBanner.bannerWidth, // 280dp как в спецификации
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: Stack(
              children: [
                // Изображение баннера
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    fit: BoxFit.cover, // ContentScale.Crop как в Android версии
                    placeholder: (context, url) => Container(
                      color: AppTheme.cardBackground,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.cardBackground,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppTheme.secondaryText,
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Ошибка загрузки',
                            style: TextStyle(
                              color: AppTheme.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Градиент для читаемости текста
                if (banner.title != null || banner.description != null)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                
                // Текст баннера
                if (banner.title != null || banner.description != null)
                  Positioned(
                    left: AppTheme.paddingMedium,
                    right: AppTheme.paddingMedium,
                    bottom: AppTheme.paddingMedium,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (banner.title != null)
                          Text(
                            banner.title!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (banner.title != null && banner.description != null)
                          const SizedBox(height: 4),
                        if (banner.description != null)
                          Text(
                            banner.description!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Упрощенная версия карусели баннеров без автопрокрутки
class SimpleBannerCarousel extends StatelessWidget {
  final List<AdBanner> banners;
  final Function(AdBanner)? onBannerTap;

  const SimpleBannerCarousel({
    super.key,
    required this.banners,
    this.onBannerTap,
  });

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: AdBanner.bannerHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: AppTheme.paddingMedium),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Container(
            width: AdBanner.bannerWidth,
            margin: const EdgeInsets.only(right: AppTheme.paddingMedium),
            child: GestureDetector(
              onTap: () => onBannerTap?.call(banner),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  child: CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(
                      color: AppTheme.cardBackground,
                      child: const Center(child: CircularProgressIndicator()),
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
            ),
          );
        },
      ),
    );
  }
}