import 'package:flutter/material.dart';

import '../analytics/analytics_client.dart';
import '../domain/user_profile.dart';
import '../services/card_collection.dart';
import '../services/card_share_service.dart';
import '../services/idea_client.dart';
import '../services/user_profile_repository.dart';
import 'card_viewer.dart';
import 'collection_page.dart';
import 'excuse_shop_page.dart';
import 'profile_page.dart';
import 'shop_theme.dart';

class ExcuseMeShell extends StatefulWidget {
  const ExcuseMeShell({
    super.key,
    required this.client,
    required this.analytics,
    required this.disableAnimations,
    this.collection,
    this.profileRepository,
  });

  final IdeaClient client;
  final AnalyticsClient analytics;
  final bool disableAnimations;
  final CardCollection? collection;
  final UserProfileRepository? profileRepository;

  @override
  State<ExcuseMeShell> createState() => _ExcuseMeShellState();
}

class _ExcuseMeShellState extends State<ExcuseMeShell> {
  late final CardCollection _collection;
  late final UserProfileRepository _profileRepository;
  final CardShareService _shareService = const CardShareService();
  final GlobalKey<ExcuseShopPageState> _shopKey =
      GlobalKey<ExcuseShopPageState>();
  UserProfile _profile = const UserProfile.empty();
  int _selectedIndex = 0;
  int _navigationVersion = 0;
  Object? _collectionError;

  @override
  void initState() {
    super.initState();
    _collection = widget.collection ?? CardCollection();
    _profileRepository = widget.profileRepository ?? UserProfileRepository();
    _loadSharedState();
  }

  Future<void> _loadSharedState() async {
    try {
      await _collection.load();
      if (mounted) setState(() => _collectionError = null);
    } catch (error) {
      if (mounted) setState(() => _collectionError = error);
    }

    try {
      final profile = await _profileRepository.load();
      if (mounted) setState(() => _profile = profile);
    } catch (_) {
      // ProfilePage loads the same repository and shows its own retry state.
    }
  }

  void _refreshCollection() {
    if (mounted) setState(() {});
  }

  void _onProfileSaved(UserProfile profile) {
    if (mounted) setState(() => _profile = profile);
  }

  void _selectIndex(int index) {
    if (index == _selectedIndex) return;
    if (_selectedIndex == 0) {
      _shopKey.currentState?.cancelPendingGeneration();
    }
    setState(() {
      _selectedIndex = index;
      _navigationVersion += 1;
    });
  }

  void _openCollection() {
    _selectIndex(1);
  }

  Future<void> _shareCard(
    BuildContext context,
    GeneratedIdea idea,
    GlobalKey repaintBoundaryKey,
    Rect sharePositionOrigin,
  ) async {
    await _shareService.shareCard(
      context,
      repaintBoundaryKey,
      sharePositionOrigin: sharePositionOrigin,
    );
    widget.analytics.record(AnalyticsEvent.share);
  }

  Future<void> _openSavedCard(GeneratedIdea card) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CardViewerPage(
          idea: card,
          mode: CardViewerMode.saved,
          disableAnimations:
              widget.disableAnimations ||
              MediaQuery.of(context).disableAnimations,
          onShare: _shareCard,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ShopTheme.theme,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            TickerMode(
              enabled: _selectedIndex == 0,
              child: ExcuseShopPage(
                key: _shopKey,
                client: widget.client,
                analytics: widget.analytics,
                disableAnimations: widget.disableAnimations,
                collection: _collection,
                profile: _profile,
                onCollectionChanged: _refreshCollection,
                onShareCard: _shareCard,
                navigationVersion: _navigationVersion,
              ),
            ),
            TickerMode(
              enabled: _selectedIndex == 1,
              child: CollectionPage(
                cards: _collection.cards,
                error: _collectionError,
                onRetry: _loadSharedState,
                onCardTap: _openSavedCard,
              ),
            ),
            TickerMode(
              enabled: _selectedIndex == 2,
              child: ProfilePage(
                repository: _profileRepository,
                cards: _collection.cards,
                onSaved: _onProfileSaved,
                onViewCollection: _openCollection,
              ),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectIndex,
          destinations: const [
            NavigationDestination(
              key: ValueKey('nav-shop'),
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'Shop',
            ),
            NavigationDestination(
              key: ValueKey('nav-collection'),
              icon: Icon(Icons.collections_bookmark_outlined),
              selectedIcon: Icon(Icons.collections_bookmark),
              label: 'Collection',
            ),
            NavigationDestination(
              key: ValueKey('nav-profile'),
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
