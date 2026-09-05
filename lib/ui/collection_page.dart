import 'package:flutter/material.dart';

import '../services/idea_client.dart';
import 'excuse_card.dart';
import 'shop_theme.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key, required this.cards});
  final List<GeneratedIdea> cards;
  @override
  Widget build(BuildContext context) => Theme(
    data: ShopTheme.theme,
    child: Scaffold(
      backgroundColor: const Color(0xFF241B30),
      appBar: AppBar(title: Text('Collection · ${cards.length}')),
      body: cards.isEmpty
          ? const Center(
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
                      style: TextStyle(
                        fontSize: 24,
                        color: ShopTheme.paperBody,
                      ),
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
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = (constraints.maxWidth / 360).floor().clamp(
                  1,
                  4,
                );
                return ListView.builder(
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
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: Center(
                                      child: ExcuseCard(
                                        idea: cards[row * columns + column],
                                      ),
                                    ),
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
}
