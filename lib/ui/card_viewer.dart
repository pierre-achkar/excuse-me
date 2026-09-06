import 'package:flutter/material.dart';

import '../services/idea_client.dart';
import 'excuse_card.dart';
import 'shop_theme.dart';

enum CardViewerMode { reveal, saved }

typedef CardViewerShareCallback = Future<void> Function(
  BuildContext context,
  GeneratedIdea idea,
  GlobalKey repaintBoundaryKey,
  Rect sharePositionOrigin,
);

Rect sharePositionOriginFor(GlobalKey shareButtonKey) {
  final renderObject = shareButtonKey.currentContext?.findRenderObject();
  if (renderObject is! RenderBox || !renderObject.hasSize) {
    throw StateError('The share control is not ready.');
  }
  final origin = renderObject.localToGlobal(Offset.zero);
  final rect = origin & renderObject.size;
  if (rect.isEmpty ||
      !rect.left.isFinite ||
      !rect.top.isFinite ||
      !rect.right.isFinite ||
      !rect.bottom.isFinite) {
    throw StateError('The share control has no valid anchor.');
  }
  return rect;
}

class CardViewerPage extends StatefulWidget {
  const CardViewerPage({
    super.key,
    required this.idea,
    required this.mode,
    this.disableAnimations = false,
    this.onShare,
  });

  final GeneratedIdea idea;
  final CardViewerMode mode;
  final bool disableAnimations;
  final CardViewerShareCallback? onShare;

  @override
  State<CardViewerPage> createState() => _CardViewerPageState();
}

class _CardViewerPageState extends State<CardViewerPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final GlobalKey _shareButtonKey = GlobalKey();
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: widget.disableAnimations ? 1 : 0,
    );
    if (!widget.disableAnimations) _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.disableAnimations || MediaQuery.of(context).disableAnimations) {
      _controller.stop();
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    if (_sharing) return;
    final onShare = widget.onShare;
    if (onShare == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sharing is not available here.')),
      );
      return;
    }
    setState(() => _sharing = true);
    try {
      await onShare(
        context,
        widget.idea,
        _repaintBoundaryKey,
        sharePositionOriginFor(_shareButtonKey),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not share this card. Try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _close() {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSaved = widget.mode == CardViewerMode.saved;
    return Theme(
      data: ShopTheme.darkTheme,
      child: Scaffold(
        key: const ValueKey('card-viewer'),
        backgroundColor: ShopTheme.pixelOutline,
        appBar: AppBar(
          title: Text(isSaved ? 'Saved card' : 'Card reveal'),
          leading: isSaved
              ? IconButton(
                  key: const ValueKey('card-viewer-close'),
                  tooltip: 'Close',
                  onPressed: _close,
                  icon: const Icon(Icons.close),
                )
              : null,
          actions: [
            KeyedSubtree(
              key: const ValueKey('card-viewer-share'),
              child: IconButton(
                key: _shareButtonKey,
                tooltip: 'Share card',
                onPressed: _sharing ? null : _share,
                icon: _sharing
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.ios_share),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  key: const ValueKey('card-viewer-scroll'),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                  child: Center(
                    child: FadeTransition(
                      key: const ValueKey('card-viewer-expanded'),
                      opacity: CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeOutCubic,
                      ),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: .88, end: 1).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: RepaintBoundary(
                          key: _repaintBoundaryKey,
                          child: ExcuseCard(idea: widget.idea, maxWidth: 560),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: SizedBox(
                  width: double.infinity,
                  child: isSaved
                      ? OutlinedButton(
                          key: const ValueKey('card-viewer-close-action'),
                          onPressed: _close,
                          child: const Text('Close'),
                        )
                      : FilledButton(
                          key: const ValueKey('card-viewer-continue'),
                          onPressed: _close,
                          child: const Text('Continue'),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
