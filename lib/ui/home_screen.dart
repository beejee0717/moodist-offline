import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sound_catalog.dart';
import '../models/sound_category.dart';
import '../state/mixer_provider.dart';
import 'about_screen.dart';
import 'widgets/now_playing_bar.dart';
import 'widgets/presets_sheet.dart';
import 'widgets/sound_card.dart';

final class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

final class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _sectionKeys = {
    for (final category in SoundCatalog.categories) category.id: GlobalKey(),
  };

  String _query = '';
  bool _favoritesOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<SoundCategory> get _visibleCategories {
    final favorites = ref.read(mixerProvider).favorites;
    final query = _query.trim().toLowerCase();
    return [
      for (final category in SoundCatalog.categories)
        if (_matches(category, query, favorites))
          _filtered(category, query, favorites),
    ];
  }

  bool _matches(SoundCategory category, String query, Set<String> favorites) =>
      _filtered(category, query, favorites).sounds.isNotEmpty;

  SoundCategory _filtered(
    SoundCategory category,
    String query,
    Set<String> favorites,
  ) => SoundCategory(
    id: category.id,
    title: category.title,
    icon: category.icon,
    sounds: [
      for (final sound in category.sounds)
        if ((!_favoritesOnly || favorites.contains(sound.id)) &&
            (query.isEmpty || sound.label.toLowerCase().contains(query)))
          sound,
    ],
  );

  void _jumpTo(String categoryId) {
    FocusScope.of(context).unfocus();
    final sectionContext = _sectionKeys[categoryId]?.currentContext;
    if (sectionContext == null) return;
    Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.08,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(mixerProvider.select((state) => state.favorites));
    final categories = _visibleCategories;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moodist'),
        actions: [
          IconButton(
            tooltip: 'Presets',
            icon: const Icon(Icons.library_music),
            onPressed: () => showPresetsSheet(context),
          ),
          IconButton(
            tooltip: 'About',
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ambient sounds for focus and calm',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                SearchBar(
                  controller: _searchController,
                  hintText: 'Search sounds',
                  leading: const Icon(Icons.search),
                  trailing: [
                    if (_query.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                  ],
                  onChanged: (value) => setState(() => _query = value),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                FilterChip(
                  label: const Text('Favorites'),
                  avatar: const Icon(Icons.star, size: 16),
                  selected: _favoritesOnly,
                  onSelected: (selected) =>
                      setState(() => _favoritesOnly = selected),
                ),
                const SizedBox(width: 8),
                for (final category in SoundCatalog.categories) ...[
                  ActionChip(
                    avatar: Icon(category.icon, size: 16),
                    label: Text(category.title),
                    onPressed: () => _jumpTo(category.id),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Expanded(
            child: categories.isEmpty
                ? const Center(child: Text('No sounds match your search.'))
                : SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    // All sections are built eagerly (84 cards total) so
                    // every category key has a context and the jump chips
                    // can scroll to any section, even below the fold.
                    child: Column(
                      children: [
                        for (final category in categories)
                          Padding(
                            key: _sectionKeys[category.id],
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(category.icon, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      category.title,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 190,
                                        mainAxisExtent: 128,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                  itemCount: category.sounds.length,
                                  itemBuilder: (context, soundIndex) =>
                                      SoundCard(
                                        sound: category.sounds[soundIndex],
                                      ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          const NowPlayingBar(),
        ],
      ),
    );
  }
}
