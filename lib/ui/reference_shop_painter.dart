import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/shop_flow_controller.dart';

/// Native scene composition and wizard geometry from the v6 HTML reference.
class ReferenceShopPainter extends CustomPainter {
  const ReferenceShopPainter({
    required this.outfit,
    required this.mood,
    required this.completed,
    this.time = 0,
    this.seed = 0,
    this.ambientEvent,
  });
  final ShopOutfit outfit;
  final int mood;
  final List<bool> completed;

  /// Seconds since the scene appeared. Everything that moves is a function of
  /// this and a per-object phase, so the shop never pulses in unison.
  final double time;

  /// Varies the stock between visits: which curiosity sits where, its colour,
  /// its size, and which slots are left bare.
  final int seed;

  /// The one thing the shop is doing right now, spoken by the ambient line.
  final ShopAmbientEvent? ambientEvent;

  Color hex(String value) =>
      Color(int.parse(value.replaceFirst('#', 'FF'), radix: 16));

  /// A stable pseudo-random unit value for a given object and channel.
  double _noise(int object, int channel) {
    var x = (object * 73856093) ^ (channel * 19349663) ^ (seed * 83492791);
    x = x & 0x7fffffff;
    x = (x ^ (x >> 13)) * 1274126177;
    return ((x & 0x7fffffff) % 10000) / 10000;
  }

  bool _event(String id) => ambientEvent?.id == id;
  @override
  void paint(Canvas canvas, Size size) {
    const ink = Color(0xFF1A1622);
    const gold = Color(0xFFFFE46B);
    const wood = Color(0xFFA56F52);
    const teal = Color(0xFF55D7C0);
    const purple = Color(0xFFA77AF0);
    void rect(double x, double y, double w, double h, Color c) =>
        canvas.drawRect(
          Rect.fromLTWH(x, y, w, h),
          Paint()
            ..color = c
            ..isAntiAlias = false,
        );
    final w = size.width;
    final h = size.height;
    final walls = [
      0xFF4B3262,
      0xFF4B3262,
      0xFF304B72,
      0xFF275255,
      0xFF63523A,
      0xFF4B3262,
      0xFF613342,
      0xFF2A2036,
    ];
    rect(0, 0, w, h, Color(walls[mood % walls.length]));
    for (var y = 0.0; y < h * .8; y += 48) {
      rect(0, y, w, 2, const Color(0x22000000));
      for (var x = (y ~/ 48).isEven ? 0.0 : 32.0; x < w; x += 64) {
        rect(x, y, 2, 48, const Color(0x15FFFFFF));
      }
    }
    rect(0, 0, w, 15, ink);
    rect(w * .07, 0, 12, h * .82, ink);
    rect(w * .91, 0, 12, h * .82, ink);
    final archW = math.min(250.0, w * .35);
    final arch = Path()
      ..moveTo(w / 2 - archW / 2, h * .7)
      ..lineTo(w / 2 - archW / 2, h * .27)
      ..lineTo(w / 2 - archW * .35, h * .19)
      ..lineTo(w / 2 + archW * .35, h * .19)
      ..lineTo(w / 2 + archW / 2, h * .27)
      ..lineTo(w / 2 + archW / 2, h * .7)
      ..close();
    canvas.drawPath(arch, Paint()..color = ink);
    rect(w / 2 - archW * .38, h * .29, 5, h * .39, const Color(0xFF714BB5));
    rect(w / 2 + archW * .36, h * .29, 5, h * .39, const Color(0xFF714BB5));
    // Four crowded shelves on each side, each with distinct curiosities.
    final sw = w * .30;
    final ps = (w / 800).clamp(.58, 1.15);
    for (var side = 0; side < 2; side++) {
      final sx = side == 0 ? w * .025 : w * .675;
      for (var row = 0; row < 4; row++) {
        final y = h * .31 + row * h * .14;
        // The top shelf is the one that "quietly changes its mind".
        final rattle = _event('shelf-rattle') && row == 0
            ? math.sin(time * 17 + side) * 1.6
            : 0.0;
        rect(sx - 3 + rattle, y, sw + 6, 13, ink);
        rect(sx + rattle, y + 3, sw, 6, wood);
        for (var col = 0; col < 7; col++) {
          final slot = side * 28 + row * 7 + col;
          // A few slots stand empty so the shelves stop reading as a lattice.
          if (_noise(slot, 4) < .12) continue;
          final n = (_noise(slot, 0) * 11).floor().clamp(0, 10);
          final itemScale = ps * (.82 + _noise(slot, 1) * .42);
          final phase = _noise(slot, 2) * math.pi * 2;
          final speed = .5 + _noise(slot, 3) * 1.1;
          // Each curiosity keeps its own time: a slow bob, a slight lean.
          final bob = math.sin(time * speed + phase) * 1.5;
          final lean = math.sin(time * speed * .6 + phase) * .035;
          canvas.save();
          canvas.translate(
            sx + col * sw / 7 + 3 + rattle,
            y - 30 * itemScale + bob,
          );
          canvas.rotate(lean);
          canvas.scale(itemScale);
          final c = [
            teal,
            gold,
            purple,
            const Color(0xFFF26E57),
            const Color(0xFF7DD9FF),
          ][(_noise(slot, 5) * 5).floor().clamp(0, 4)];
          void box(double x, double y, double bw, double bh, Color c) {
            rect(x - 2, y - 2, bw + 4, bh + 4, ink);
            rect(x, y, bw, bh, c);
          }

          switch (n) {
            case 0:
              box(3, 7, 15, 23, c);
              box(7, 0, 7, 8, c);
              rect(6, 13, 3, 7, const Color(0x99FFFFFF));
            case 1:
              box(0, 7, 22, 23, teal);
              box(1, 3, 20, 5, wood);
              box(5, 14, 13, 8, gold);
              rect(11, 15, 4, 7, ink);
            case 2:
              box(0, 9, 23, 19, const Color(0xFFF6E5B5));
              rect(4, 14, 5, 6, ink);
              rect(15, 14, 5, 6, ink);
              rect(6, 27, 12, 4, const Color(0xFFF6E5B5));
            case 3:
              box(2, 0, 21, 30, c);
              rect(6, 4, 3, 23, gold);
              rect(12, 5, 8, 3, const Color(0xFFEDEAE2));
            case 4:
              box(6, 1, 12, 12, gold);
              rect(10, 5, 4, 4, ink);
              rect(10, 13, 4, 18, gold);
              rect(14, 25, 8, 4, gold);
            case 5:
              canvas.drawPath(
                Path()
                  ..moveTo(12, 0)
                  ..lineTo(24, 12)
                  ..lineTo(18, 30)
                  ..lineTo(5, 30)
                  ..lineTo(0, 12)
                  ..close(),
                Paint()..color = c,
              );
              rect(9, 7, 4, 15, const Color(0x99FFFFFF));
            case 6:
              box(3, 20, 19, 10, wood);
              rect(10, 0, 5, 20, teal);
              rect(1, 5, 12, 6, teal);
              rect(14, 1, 11, 7, const Color(0xFF76D590));
            case 7:
              box(2, 2, 23, 28, wood);
              rect(6, 7, 15, 18, ink);
              rect(11, 12, 6, 7, gold);
              rect(8, 4, 3, 24, wood);
              rect(18, 4, 3, 24, wood);
            case 8:
              box(9, 14, 7, 16, const Color(0xFFF3D39A));
              box(0, 4, 25, 12, c);
              rect(5, 6, 4, 4, gold);
              rect(18, 10, 4, 4, gold);
            case 9:
              box(0, 5, 25, 22, const Color(0xFFF4DFAD));
              rect(11, 8, 3, 11, ink);
              rect(12, 16, 8, 3, ink);
            case 10:
              box(0, 9, 26, 19, c);
              rect(4, 13, 6, 6, gold);
              rect(16, 13, 6, 6, teal);
              rect(7, 24, 12, 2, ink);
          }
          canvas.restore();
        }
      }
    }
    // Hanging lamps, stepped light, and suspended charms.
    for (final x in [w * .13, w * .87]) {
      rect(x, 0, 4, 70, ink);
      rect(x - 15, 66, 34, 8, ink);
      rect(x - 10, 74, 24, 22, gold);
      rect(x - 15, 96, 34, 6, ink);
      canvas.drawCircle(
        Offset(x + 2, 86),
        46,
        Paint()
          ..shader =
              const RadialGradient(
                colors: [Color(0x44FFE46B), Color(0x00FFE46B)],
              ).createShader(
                Rect.fromCircle(center: Offset(x + 2, 86), radius: 46),
              ),
      );
    }
    for (var i = 0; i < 3; i++) {
      final x = w * (.39 + i * .11);
      final y = 90.0 + (i % 2) * 17;
      rect(x, 0, 3, y, ink);
      rect(x - 5, y, 13, 13, [purple, teal, gold][i]);
    }
    rect(0, h * .81, w, h * .19, const Color(0xFF36283F));
    for (var x = 0.0; x < w; x += 60) {
      rect(x, h * .83, 2, h * .17, const Color(0xFF211B2B));
    }
    rect(w * .21, h * .87, w * .58, h * .09, const Color(0xFF614477));
    // Preserve the reference's exact wizard silhouette and outfit regions.
    canvas.save();
    final scale = math.min(h * .70 / 330, w * .55 / 260);
    canvas.translate(w / 2 - 130 * scale, h * .83 - 330 * scale);
    canvas.scale(scale);
    rect(220, 58, 10, 252, hex("#8A6B49"));
    rect(216, 52, 18, 14, hex("#4E463A"));
    rect(214, 34, 22, 22, hex("#4E463A"));
    // The lantern is never quite still; on its own event it stutters.
    final flicker = _event('lantern-flicker')
        ? (math.sin(time * 21) * math.sin(time * 7.3)).abs()
        : .35 + math.sin(time * 1.7) * .12;
    rect(
      219,
      39,
      12,
      13,
      Color.lerp(hex(outfit.lanternHex), Colors.white, flicker * .45)!,
    );
    canvas.drawRect(
      Rect.fromLTWH(213, 33, 24, 25),
      Paint()
        ..color = hex(outfit.lanternHex).withValues(alpha: .10 + flicker * .22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    // Wick himself: breathing under everything, leaning into the question he
    // just asked, and rummaging while he searches the shelves.
    final breath = math.sin(time * 1.3) * 1.4;
    final searching = mood == ShopFlowStage.search.index;
    final asking =
        mood > ShopFlowStage.entry.index && mood < ShopFlowStage.search.index;
    final rummage = searching ? math.sin(time * 6.2) * 3.5 : 0.0;
    canvas.save();
    canvas.translate(120 + rummage, 200 + breath + (searching ? -2 : 0));
    canvas.rotate(asking ? .018 : (searching ? math.sin(time * 3.1) * .02 : 0));
    canvas.translate(-120, -200);
    canvas.drawPath(
      Path()
        ..moveTo(42, 70)
        ..lineTo(60, 54)
        ..lineTo(86, 50)
        ..lineTo(102, 30)
        ..lineTo(126, 24)
        ..lineTo(146, 34)
        ..lineTo(170, 38)
        ..lineTo(184, 54)
        ..lineTo(204, 58)
        ..lineTo(194, 78)
        ..lineTo(164, 78)
        ..lineTo(150, 88)
        ..lineTo(106, 82)
        ..lineTo(82, 88)
        ..lineTo(54, 84)
        ..close(),
      Paint()
        ..color = hex(outfit.hatHex)
        ..isAntiAlias = false,
    );
    rect(72, 49, 18, 14, hex(outfit.robeHex));
    rect(102, 36, 16, 15, hex(outfit.robeHex));
    rect(145, 47, 18, 15, hex(outfit.robeHex));
    rect(32, 78, 170, 16, hex(outfit.robeHex));
    rect(96, 92, 58, 18, hex("#CFA66C"));
    rect(86, 106, 70, 22, hex("#DBB274"));
    rect(76, 116, 20, 15, hex("#DBB274"));
    rect(64, 121, 20, 10, hex("#DBB274"));
    // A blink every few seconds, and a longer one when he is thinking.
    final blinkCycle = time % (searching ? 2.6 : 4.3);
    final blinking = blinkCycle < .13;
    rect(
      130,
      blinking ? 111 : 107,
      14,
      blinking ? 2 : 9,
      hex(outfit.lanternHex),
    );
    rect(92, 126, 72, 25, hex("#E9E6DB"));
    rect(82, 145, 90, 25, hex("#E9E6DB"));
    rect(86, 166, 88, 26, hex("#D8D6CB"));
    rect(96, 187, 78, 25, hex("#C9C8BE"));
    rect(108, 208, 63, 22, hex("#BDBCB2"));
    rect(120, 228, 48, 19, hex("#AAA99F"));
    rect(52, 156, 38, 42, hex(outfit.hatHex));
    rect(36, 190, 58, 84, hex(outfit.robeHex));
    rect(82, 176, 100, 122, hex(outfit.robeHex));
    rect(170, 190, 42, 84, hex(outfit.hatHex));
    rect(92, 270, 98, 44, hex(outfit.robeHex));
    rect(91, 180, 12, 116, hex(outfit.trimHex));
    rect(150, 207, 11, 89, hex(outfit.trimHex));
    rect(52, 220, 14, 70, hex(outfit.trimHex));
    rect(117, 268, 12, 39, hex(outfit.hatHex));
    rect(173, 239, 12, 58, hex(outfit.hatHex));
    rect(83, 232, 96, 12, hex(outfit.trimHex));
    rect(122, 229, 18, 18, hex("#5A503F"));
    rect(47, 259, 27, 19, hex("#DDB675"));
    rect(199, 194, 22, 20, hex("#DDB675"));
    rect(25, 244, 31, 41, hex("#F5E3B5"));
    rect(31, 251, 19, 7, hex(outfit.lanternHex));
    rect(31, 265, 14, 5, hex(outfit.hatHex));
    rect(75, 305, 44, 13, hex("#4D463A"));
    rect(156, 305, 44, 13, hex("#4D463A"));
    canvas.restore();
    canvas.restore();
    final cw = math.min(640.0, w * .76);
    final cx = (w - cw) / 2;
    rect(cx - 5, h * .77 - 5, cw + 10, h * .19 + 10, ink);
    rect(cx, h * .77, cw, h * .19, const Color(0xFF68453D));
    rect(cx - 10, h * .77, cw + 20, 17, ink);
    rect(cx - 6, h * .77 + 4, cw + 12, 9, wood);
    rect(cx + 12, h * .82, cw - 24, 4, const Color(0xFFBB835A));
    for (var i = 0; i < 3; i++) {
      rect(cx + cw * (i + 1) / 4, h * .83, 5, h * .12, ink);
    }
    for (var i = 0; i < completed.length; i++) {
      final x = w / 2 - 63 + i * 22;
      rect(x, h * .77 - 12, 15, 11, ink);
      rect(
        x + 3,
        h * .77 - 10,
        9,
        6,
        completed[i] ? teal : const Color(0xFF795E67),
      );
    }
    // The ledger on the counter turns a page, impatiently.
    if (_event('ledger-page')) {
      final turn = (time * .9) % 1;
      final lx = w / 2 + 96, ly = h * .755;
      rect(lx - 2, ly - 2, 46, 30, ink);
      rect(lx, ly, 42, 26, const Color(0xFFEDE6D2));
      rect(lx + 20, ly, 2, 26, const Color(0xFFBCB29A));
      final page = 20 * math.cos(turn * math.pi).abs();
      rect(
        turn < .5 ? lx + 21 : lx + 21 - page,
        ly + 1,
        page.clamp(1, 20),
        24,
        const Color(0xFFF8F3E4),
      );
    }
    // A small bell over the door approves of the selection.
    if (_event('bell-chime')) {
      final swing = math.sin(time * 12) * math.exp(-(time % 2.4) * 1.1);
      final bx = w * .16, by = 18.0;
      canvas.save();
      canvas.translate(bx, by);
      canvas.rotate(swing * .5);
      rect(-9, 0, 18, 15, gold);
      rect(-4, 15, 8, 5, gold);
      rect(-11, -3, 22, 4, ink);
      canvas.restore();
    }
    // Dust turning slowly through the light from the arch.
    if (_event('dust-orbit')) {
      for (var i = 0; i < 22; i++) {
        final a =
            time * (.25 + _noise(i, 7) * .35) + _noise(i, 8) * math.pi * 2;
        final r = 26 + _noise(i, 9) * 92;
        rect(
          w / 2 + math.cos(a) * r * 1.5,
          h * .42 + math.sin(a) * r * .55,
          2,
          2,
          Colors.white.withValues(alpha: .10 + _noise(i, 10) * .30),
        );
      }
    }
    final vignette = RadialGradient(
      radius: .8,
      colors: const [Color(0x00000000), Color(0x550D0712)],
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = vignette.createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(ReferenceShopPainter old) =>
      old.outfit != outfit ||
      old.mood != mood ||
      old.completed != completed ||
      old.time != time ||
      old.seed != seed ||
      old.ambientEvent != ambientEvent;
}
