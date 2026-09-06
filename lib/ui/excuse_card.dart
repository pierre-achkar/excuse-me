import 'package:flutter/material.dart';

import '../domain/excuse_request.dart';
import '../services/idea_client.dart';
import 'shop_theme.dart';

enum CardIllustration {
  battery,
  shield,
  calendars,
  transit,
  wallet,
  hourglass,
  home,
  goblin,
  sunrise,
  stop,
  umbrella,
  door,
  bridge,
}

/// Versioned, deterministic presentation. No randomness enters excuse selection.
class CardDesign {
  const CardDesign({
    required this.seed,
    required this.illustration,
    required this.color,
    required this.paper,
    required this.rarity,
    required this.pattern,
  });
  final int seed;
  final CardIllustration illustration;
  final Color color;
  final Color paper;
  final String rarity;
  final int pattern;
  String get edition => seed.toRadixString(36).toUpperCase().padLeft(7, '0');
  String get signature =>
      '$seed/${illustration.name}/${color.toARGB32()}/$pattern';
  static CardDesign forIdea(GeneratedIdea idea) => CardDesignGenerator.generate(
    id: idea.kernelId ?? idea.playfulName ?? 'local-card',
    family: idea.family,
  );
}

class CardDesignGenerator {
  const CardDesignGenerator._();
  static const version = 1;
  // Optional art direction is data: new cards do not need an entry here.
  static const artworkOverrides = <String, CardIllustration>{
    'en_capacity_reset': CardIllustration.battery,
    'en_existing_commitment': CardIllustration.shield,
    'en_schedule_collision': CardIllustration.calendars,
    'en_logistics_delay': CardIllustration.transit,
    'en_budget_boundary': CardIllustration.wallet,
    'en_work_overrun': CardIllustration.hourglass,
    'en_household_responsibility': CardIllustration.home,
    'en_planning_mistake': CardIllustration.goblin,
    'en_early_start': CardIllustration.sunrise,
    'en_honest_decline': CardIllustration.stop,
    'en_alternative_timing': CardIllustration.umbrella,
    'en_honest_boundary_fallback': CardIllustration.door,
    'en_repair_path_fallback': CardIllustration.bridge,
  };
  static const palettes = [
    0xFF9E8BCB,
    0xFF80B7A2,
    0xFFC99380,
    0xFF86A9C9,
    0xFFC2AC70,
    0xFFA092C8,
    0xFF89B391,
    0xFFB8A0D9,
    0xFFD3A56D,
    0xFFBD8EAB,
    0xFF7AB9BE,
    0xFFCAA373,
  ];
  static int stableSeed(String value) {
    // Bounded arithmetic is identical on Dart VM and JavaScript runtimes.
    var hash = 5381;
    for (final unit in value.codeUnits) {
      hash = (hash * 33 + unit) & 0xffffffff;
    }
    hash = (hash * 33) & 0xffffffff;
    return (hash ^ (hash >>> 16)) & 0xffffffff;
  }

  static CardDesign generate({
    required String id,
    ExcuseFamily? family,
    CardIllustration? illustration,
    Color? color,
    String? rarity,
  }) {
    final seed = stableSeed('card-v$version:$id');
    final motifs = switch (family) {
      ExcuseFamily.capacityWellbeing => [
        CardIllustration.battery,
        CardIllustration.sunrise,
      ],
      ExcuseFamily.careFamily => [
        CardIllustration.home,
        CardIllustration.bridge,
      ],
      ExcuseFamily.workStudy => [
        CardIllustration.hourglass,
        CardIllustration.calendars,
      ],
      ExcuseFamily.moneyLogistics => [
        CardIllustration.transit,
        CardIllustration.wallet,
      ],
      ExcuseFamily.planningFailure => [
        CardIllustration.calendars,
        CardIllustration.goblin,
      ],
      ExcuseFamily.boundaryPreference => [
        CardIllustration.door,
        CardIllustration.shield,
        CardIllustration.umbrella,
        CardIllustration.stop,
      ],
      _ => CardIllustration.values,
    };
    return CardDesign(
      seed: seed,
      illustration:
          illustration ?? artworkOverrides[id] ?? motifs[seed % motifs.length],
      color: color ?? Color(palettes[(seed >>> 5) % palettes.length]),
      paper: const [
        Color(0xFFEDEAE2),
        Color(0xFFE7E8DE),
        Color(0xFFE9E3EB),
        Color(0xFFE4E9ED),
      ][(seed >>> 9) % 4],
      rarity:
          rarity ??
          ((seed % 20 == 0)
              ? 'rare'
              : (seed % 5 == 0)
              ? 'uncommon'
              : 'common'),
      pattern: (seed >>> 13) % 4,
    );
  }
}

String cardFamilyLabel(ExcuseFamily? family) => switch (family) {
  ExcuseFamily.capacityWellbeing => 'capacity',
  ExcuseFamily.careFamily => 'care & family',
  ExcuseFamily.workStudy => 'work & study',
  ExcuseFamily.moneyLogistics => 'daily logistics',
  ExcuseFamily.planningFailure => 'planning failure',
  ExcuseFamily.boundaryPreference => 'boundaries',
  ExcuseFamily.absurdDramatic => 'a little absurd',
  null => 'from the shop',
};

class ExcuseCard extends StatelessWidget {
  const ExcuseCard({super.key, required this.idea, this.maxWidth = 320});
  final GeneratedIdea idea;
  final double maxWidth;
  @override
  Widget build(BuildContext context) {
    final design = CardDesign.forIdea(idea);
    const pixel = TextStyle(
      fontFamily: 'PressStart2P',
      fontSize: 8,
      height: 1.6,
      color: ShopTheme.pixelOutline,
    );
    return Semantics(
      container: true,
      label: '${idea.playfulName ?? "Your card"}. ${idea.idea}',
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: ShopTheme.pixelOutline,
          border: Border.all(color: ShopTheme.pixelOutline, width: 6),
          boxShadow: const [
            BoxShadow(color: Color(0x55332642), offset: Offset(6, 7)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: design.color,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      idea.playfulName ?? 'A small escape',
                      style: pixel.copyWith(fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    color: ShopTheme.pixelOutline,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 5,
                    ),
                    child: Text(
                      design.rarity,
                      style: pixel.copyWith(
                        fontSize: 7,
                        color: ShopTheme.pixelGlow,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              key: const ValueKey('pixel-card-art'),
              height: 150,
              child: CustomPaint(painter: CardIllustrationPainter(design)),
            ),
            Container(
              color: ShopTheme.paperBody,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'THE IDEA',
                    style: pixel.copyWith(color: ShopTheme.paperMeta),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    idea.idea,
                    key: const ValueKey('card-idea-body'),
                    style: const TextStyle(
                      fontFamily: 'InterTight',
                      fontSize: 17,
                      height: 1.45,
                      color: ShopTheme.pixelOutline,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(
                    height: 3,
                    thickness: 3,
                    color: ShopTheme.paperDivider,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            color: ShopTheme.pixelTeal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 5,
                            ),
                            child: Text(
                              cardFamilyLabel(idea.family),
                              style: pixel.copyWith(fontSize: 7),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        design.edition,
                        style: pixel.copyWith(
                          fontSize: 7,
                          color: ShopTheme.paperMeta,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A separate, hand-drawn pixel object for every curated excuse.
class CardIllustrationPainter extends CustomPainter {
  const CardIllustrationPainter(this.design);
  final CardDesign design;
  @override
  void paint(Canvas canvas, Size size) {
    const ink = ShopTheme.pixelOutline,
        paper = ShopTheme.paperBody,
        gold = ShopTheme.pixelGlow,
        teal = ShopTheme.pixelTeal,
        ember = ShopTheme.pixelEmber;
    final accent = design.color;
    void r(double x, double y, double w, double h, Color color) =>
        canvas.drawRect(
          Rect.fromLTWH(x, y, w, h),
          Paint()
            ..color = color
            ..isAntiAlias = false,
        );
    r(0, 0, size.width, size.height, design.paper);
    final quiet = design.color.withValues(alpha: .17);
    for (var i = 0; i < 12; i++) {
      final x =
          12.0 +
          ((design.seed >>> (i % 16)) + i * 37) % (size.width.toInt() - 24);
      final y =
          10.0 +
          ((design.seed >>> (i % 12)) + i * 19) % (size.height.toInt() - 20);
      if (design.pattern == 0) {
        r(x, y, 3, 3, quiet);
      }
      if (design.pattern == 1) {
        r(x, y, 3, 9, quiet);
        r(x - 3, y + 3, 9, 3, quiet);
      }
      if (design.pattern == 2) {
        r(x, y, 12, 2, quiet);
      }
      if (design.pattern == 3) {
        r(x, y, 6, 6, quiet);
        r(x + 2, y + 2, 2, 2, design.paper);
      }
    }
    // A compact 32-bit maker's mark gives each ID its own ornament.
    for (var bit = 0; bit < 32; bit++) {
      if ((design.seed >>> bit) & 1 == 1) {
        r(
          8.0 + (bit % 8) * 4,
          size.height - 20 + (bit ~/ 8) * 4,
          3,
          3,
          design.color,
        );
      }
    }
    canvas.save();
    canvas.translate((size.width - 120) / 2, (size.height - 120) / 2);
    void box(double x, double y, double w, double h, Color color) {
      r(x - 4, y - 4, w + 8, h + 8, ink);
      r(x, y, w, h, color);
    }

    r(24, 108, 76, 4, ShopTheme.paperDivider);
    r(12, 26, 5, 5, gold);
    r(103, 71, 5, 5, gold);
    switch (design.illustration) {
      case CardIllustration.battery:
        box(32, 28, 56, 64, teal);
        r(48, 18, 24, 6, ink);
        r(39, 36, 42, 46, paper);
        r(43, 60, 34, 18, teal);
        r(53, 40, 13, 10, gold);
        r(48, 50, 14, 9, gold);
      case CardIllustration.shield:
        r(24, 22, 72, 52, ink);
        r(32, 30, 56, 44, accent);
        r(32, 74, 56, 10, ink);
        r(40, 84, 40, 10, ink);
        r(48, 94, 24, 8, ink);
        r(40, 72, 40, 10, accent);
        r(48, 82, 24, 10, accent);
        r(54, 37, 12, 38, gold);
        r(43, 48, 34, 12, gold);
      case CardIllustration.calendars:
        box(19, 22, 47, 58, paper);
        r(19, 22, 47, 13, accent);
        box(53, 47, 46, 53, paper);
        r(53, 47, 46, 12, ember);
        for (var i = 0; i < 3; i++) {
          r(27 + i * 11, 45, 6, 6, accent);
          r(61 + i * 11, 69, 6, 6, ember);
        }
        r(30, 15, 6, 15, ink);
        r(52, 15, 6, 15, ink);
        r(76, 78, 10, 10, gold);
      case CardIllustration.transit:
        box(25, 31, 70, 58, accent);
        r(31, 39, 58, 23, paper);
        r(58, 39, 5, 23, ink);
        r(33, 70, 12, 7, gold);
        r(76, 70, 12, 7, gold);
        r(33, 92, 12, 10, ink);
        r(77, 92, 12, 10, ink);
        r(40, 20, 40, 7, ink);
        r(44, 23, 32, 4, teal);
      case CardIllustration.wallet:
        box(20, 43, 80, 47, accent);
        box(32, 24, 47, 20, teal);
        r(43, 29, 24, 10, paper);
        box(70, 57, 30, 19, accent);
        r(79, 63, 7, 7, gold);
        r(28, 51, 32, 4, paper);
      case CardIllustration.hourglass:
        box(31, 17, 58, 9, accent);
        box(31, 94, 58, 9, accent);
        r(35, 30, 6, 17, ink);
        r(79, 30, 6, 17, ink);
        r(43, 47, 8, 10, ink);
        r(69, 47, 8, 10, ink);
        r(51, 56, 18, 12, ink);
        r(43, 68, 8, 10, ink);
        r(69, 68, 8, 10, ink);
        r(35, 78, 6, 14, ink);
        r(79, 78, 6, 14, ink);
        r(43, 33, 34, 10, gold);
        r(51, 43, 18, 10, gold);
        r(57, 69, 6, 15, gold);
        r(44, 84, 32, 8, gold);
      case CardIllustration.home:
        r(49, 19, 22, 8, ink);
        r(37, 27, 46, 8, ink);
        r(25, 35, 70, 8, ink);
        r(17, 43, 86, 8, ink);
        box(30, 51, 60, 47, accent);
        box(55, 70, 19, 28, paper);
        r(38, 59, 10, 13, gold);
        r(73, 59, 10, 13, gold);
        r(70, 22, 10, 15, ember);
      case CardIllustration.goblin:
        r(18, 30, 22, 24, ink);
        r(80, 30, 22, 24, ink);
        box(35, 30, 50, 51, teal);
        r(23, 34, 12, 12, teal);
        r(85, 34, 12, 12, teal);
        r(42, 45, 10, 12, gold);
        r(68, 45, 10, 12, gold);
        r(47, 68, 27, 6, ink);
        box(40, 87, 44, 15, accent);
        r(49, 80, 7, 10, ink);
        r(70, 80, 7, 10, ink);
      case CardIllustration.sunrise:
        r(20, 82, 82, 6, ink);
        r(32, 67, 58, 15, gold);
        r(39, 54, 44, 13, gold);
        r(48, 47, 25, 7, gold);
        r(57, 21, 7, 16, accent);
        r(23, 40, 9, 9, accent);
        r(89, 40, 9, 9, accent);
        r(18, 66, 10, 5, accent);
        r(95, 66, 10, 5, accent);
        r(31, 94, 61, 4, accent);
        r(43, 102, 38, 4, accent);
      case CardIllustration.stop:
        r(43, 20, 34, 7, ink);
        r(30, 27, 60, 12, ink);
        r(23, 39, 74, 40, ink);
        r(30, 79, 60, 12, ink);
        r(43, 91, 34, 7, ink);
        r(43, 28, 34, 62, accent);
        r(31, 40, 58, 37, accent);
        r(40, 54, 40, 11, paper);
      case CardIllustration.umbrella:
        r(53, 22, 14, 7, ink);
        r(33, 29, 54, 7, ink);
        r(23, 36, 74, 9, ink);
        r(15, 45, 90, 12, ink);
        r(23, 45, 74, 8, teal);
        r(33, 36, 54, 9, accent);
        r(44, 30, 32, 6, accent);
        r(58, 57, 6, 38, ink);
        r(42, 95, 22, 6, ink);
        r(37, 86, 6, 10, ink);
        r(23, 70, 4, 9, accent);
        r(90, 76, 4, 9, accent);
      case CardIllustration.door:
        box(33, 18, 54, 84, accent);
        r(42, 25, 36, 77, ink);
        r(43, 29, 27, 70, teal);
        r(62, 63, 5, 5, gold);
        r(22, 104, 77, 5, ink);
        r(89, 46, 16, 5, gold);
        r(97, 38, 5, 20, gold);
      case CardIllustration.bridge:
        r(15, 84, 90, 6, teal);
        r(21, 96, 78, 5, teal);
        r(18, 59, 84, 10, accent);
        r(26, 44, 8, 46, ink);
        r(87, 44, 8, 46, ink);
        r(35, 49, 52, 5, ink);
        r(44, 53, 5, 17, ink);
        r(59, 53, 5, 17, ink);
        r(74, 53, 5, 17, ink);
        r(53, 23, 16, 7, ember);
        r(58, 18, 6, 17, ember);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CardIllustrationPainter old) =>
      old.design.signature != design.signature;
}
