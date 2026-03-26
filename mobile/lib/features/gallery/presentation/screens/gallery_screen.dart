import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';
import '../widgets/all_pictures.dart';
import '../widgets/event_pictures.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> allPictures = [
    'assets/images/gallery_img8.png',
    'assets/images/gallery_img1.png',
    'assets/images/gallery_img2.png',
    'assets/images/gallery_img3.png',
    'assets/images/gallery_img4.png',
    'assets/images/gallery_img5.png',
    'assets/images/gallery_img6.png',
    'assets/images/gallery_img7.png',
  ];

  final List<String> eventPictures = [
    'assets/images/gallery_img1.png',
    'assets/images/gallery_img2.png',
    'assets/images/gallery_img3.png',
    'assets/images/gallery_img4.png',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTabContent(String title, int count, bool isSelected) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: isSelected
                ? textTheme.titleLarge
                : textTheme.titleLarge?.copyWith(
                    color: AppTheme.tabUnselectedTextColor,
                  ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            count.toString(),
            style: isSelected
                ? textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryTextColor,
                  )
                : textTheme.bodyMedium?.copyWith(
                    color: AppTheme.tabUnselectedTextColor,
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Gallery",
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 24,
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.search, size: 18, color: AppTheme.primaryColor),
              onPressed: () {},
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: ImageIcon(
                const AssetImage("assets/images/Icon.png"),
                size: 18,
                color: AppTheme.primaryColor,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppTheme.primaryColor,
              dividerColor: AppTheme.tabDividerColor,
              indicatorSize: TabBarIndicatorSize.label,
              labelPadding: const EdgeInsets.symmetric(
                vertical: AppTheme.spacingSm,
              ),
              tabs: [
                Tab(
                  child: AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      final isSelected = _tabController.index == 0;
                      return _buildTabContent('All', allPictures.length, isSelected);
                    },
                  ),
                ),
                Tab(
                  child: AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      final isSelected = _tabController.index == 1;
                      return _buildTabContent('Events', eventPictures.length, isSelected);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                AllPictures(pictures: allPictures),
                EventPictures(pictures: eventPictures),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
