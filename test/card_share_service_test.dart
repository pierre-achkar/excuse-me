import 'dart:typed_data';

import 'package:excuse_me/services/card_share_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  test('card sharing exports only a PNG of the displayed boundary', () async {
    final files = <XFile>[];
    var downloaded = false;
    final service = CardShareService(
      capturePng: (_, repaintBoundaryKey) async =>
          Uint8List.fromList([137, 80, 78, 71]),
      shareFiles:
          (
            items, {
            subject,
            text,
            sharePositionOrigin,
            fileNameOverrides,
          }) async {
            files.addAll(items);
            expect(subject, 'Pardon card');
            expect(text, isNull);
            expect(fileNameOverrides, ['excusee-card.png']);
            expect(sharePositionOrigin, isNotNull);
            expect(sharePositionOrigin!.width, greaterThan(0));
            expect(sharePositionOrigin.height, greaterThan(0));
            return ShareResult.unavailable;
          },
      downloadPng: (bytes, filename) async {
        downloaded = true;
        expect(bytes, [137, 80, 78, 71]);
        expect(filename, 'excusee-card.png');
      },
    );

    await service.shareCard(
      const _FakeBuildContext(),
      GlobalKey(),
      sharePositionOrigin: const Rect.fromLTWH(10, 20, 30, 40),
    );

    expect(files, hasLength(1));
    expect(files.single.mimeType, 'image/png');
    expect(await files.single.readAsBytes(), [137, 80, 78, 71]);
    expect(downloaded, isTrue);
  });
}

class _FakeBuildContext implements BuildContext {
  const _FakeBuildContext();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
