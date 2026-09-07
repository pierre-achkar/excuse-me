import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

typedef ShareFilesCallback = Future<ShareResult> Function(
  List<XFile> files, {
  String? subject,
  String? text,
  Rect? sharePositionOrigin,
  List<String>? fileNameOverrides,
});

typedef CardPngCapture = Future<Uint8List> Function(
  BuildContext context,
  GlobalKey repaintBoundaryKey,
);

typedef DownloadPngCallback = Future<void> Function(
  Uint8List bytes,
  String filename,
);

/// Exports only the rendered card boundary. Profile and request data never
/// enter the share payload.
class CardShareService {
  const CardShareService({
    this.shareFiles = Share.shareXFiles,
    this.capturePng = _capturePng,
    this.downloadPng = _downloadPng,
  });

  final ShareFilesCallback shareFiles;
  final CardPngCapture capturePng;
  final DownloadPngCallback downloadPng;

  Future<void> shareCard(
    BuildContext context,
    GlobalKey repaintBoundaryKey, {
    required Rect sharePositionOrigin,
  }) async {
    final bytes = await capturePng(context, repaintBoundaryKey);
    if (bytes.isEmpty) {
      throw StateError('Could not encode the card image.');
    }
    final result = await shareFiles(
      [XFile.fromData(bytes, mimeType: 'image/png', name: 'excusee-card.png')],
      subject: 'Pardon card',
      sharePositionOrigin: sharePositionOrigin,
      fileNameOverrides: const ['excusee-card.png'],
    );
    if (result.status == ShareResultStatus.unavailable) {
      await downloadPng(bytes, 'excusee-card.png');
    }
  }

  static Future<void> _downloadPng(Uint8List bytes, String filename) async {
    await XFile.fromData(
      bytes,
      mimeType: 'image/png',
      name: filename,
    ).saveTo(filename);
  }

  static Future<Uint8List> _capturePng(
    BuildContext context,
    GlobalKey repaintBoundaryKey,
  ) async {
    final renderObject = repaintBoundaryKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw StateError('The card is not ready to share.');
    }

    final image = await renderObject.toImage(
      pixelRatio: View.of(context).devicePixelRatio,
    );
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw StateError('Could not encode the card image.');
      }
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image.dispose();
    }
  }
}
