import 'package:flutter/material.dart';

import '../services/idea_client.dart';
import 'excuse_card.dart';
import 'shop_theme.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({
    super.key,
    required this.cards,
    this.error,
    this.onRetry,
    this.onCardTap,
  });

  final List<GeneratedIdea> cards;
  final Object? error;
  final Future<void> Function()? onRetry;
  final ValueChanged<GeneratedIdea>? onCardTap;

  @override
  Widget build(BuildContext context) => Theme(
    data: ShopTheme.theme,
    child: Scaffold(
      backgroundColor: const Color(0xFF241B30),
      appBar: AppBar(title: Text('Collection · ${cards.length}')),
      body: error != null
          ? _buildError()
          : cards.isEmpty
          ? _buildEmpty()
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = (constraints.maxWidth / 360).floor().clamp(
                  1,
                  4,
                );
                return ListView.builder(
                  key: const ValueKey('collection-shelf'),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  itemCount: (cards.length / columns).ceil(),
                  itemBuilder: (context, row) => Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var column = 0; column < columns; column++)
                          Expanded(
                            child: row * columns + column < cards.length
                                ? _buildShelfItem(
                                    cards[row * columns + column],
                                    row * columns + column,
                                  )
                                : const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    ),
  );

  Widget _buildShelfItem(GeneratedIdea card, int index) {
    final name = card.playfulName ?? 'Your card';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Semantics(
        button: onCardTap != null,
        label: '$name collection card',
        child: InkWell(
          key: ValueKey('collection-card-$index'),
          onTap: onCardTap == null ? null : () => onCardTap!(card),
          borderRadius: BorderRadius.circular(8),
          child: Center(child: ExcuseCard(idea: card)),
        ),
      ),
    );
  }

  Widget _buildEmpty() => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.collections_bookmark_outlined,
            size: 44,
            color: ShopTheme.pixelGlow,
          ),
          SizedBox(height: 20),
          Text(
            'Your shelf is waiting.',
            style: TextStyle(fontSize: 24, color: ShopTheme.paperBody),
          ),
          SizedBox(height: 10),
          Text(
            'Choose “Keep card” when you find one you like.\nYour cards will stay here on this device.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: ShopTheme.paperBody,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 44, color: ShopTheme.pixelGlow),
          const SizedBox(height: 20),
          const Text(
            'Could not load your collection.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: ShopTheme.paperBody),
          ),
          const SizedBox(height: 14),
          FilledButton(
            key: const ValueKey('collection-retry'),
            onPressed: onRetry,
            child: const Text('RETRY'),
          ),
        ],
      ),
    ),
  );
}
