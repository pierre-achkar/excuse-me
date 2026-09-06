import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../analytics/analytics_client.dart';
import '../domain/excuse_request.dart';
import '../domain/idea_request.dart';
import '../domain/shop_selection.dart';
import '../domain/user_profile.dart';
import '../l10n/app_localizations.dart';
import '../services/idea_client.dart';
import '../services/shop_flow_controller.dart';
import 'shop_theme.dart';
import 'card_viewer.dart';
import 'excuse_card.dart';
import 'collection_page.dart';
import '../services/card_collection.dart';
import 'reference_shop_painter.dart';

class ExcuseShopPage extends StatefulWidget {
  const ExcuseShopPage({
    super.key,
    required this.client,
    this.analytics = const NoOpAnalyticsClient(),
    this.disableAnimations = false,
    this.collection,
    this.profile = const UserProfile.empty(),
    this.onCollectionChanged,
    this.onOpenCollection,
    this.onShareCard,
    this.navigationVersion = 0,
    this.showInternalNavigation = true,
  });

  final IdeaClient client;
  final AnalyticsClient analytics;
  final bool disableAnimations;
  final CardCollection? collection;
  final UserProfile profile;
  final VoidCallback? onCollectionChanged;
  final VoidCallback? onOpenCollection;
  final CardViewerShareCallback? onShareCard;
  final int navigationVersion;
  final bool showInternalNavigation;

  @override
  State<ExcuseShopPage> createState() => ExcuseShopPageState();
}

class ExcuseShopPageState extends State<ExcuseShopPage>
    with WidgetsBindingObserver {
  late final CardCollection _collection;
  bool _saving = false;
  bool _sharing = false;
  final GlobalKey _resultRepaintBoundaryKey = GlobalKey();
  final GlobalKey _resultShareButtonKey = GlobalKey();
  final ScrollController _scroll = ScrollController();
  final ShopFlowController _controller = ShopFlowController();

  late ShopSession _session;
  ShopFlowStage _stage = ShopFlowStage.entry;
  ShopIntentOption? _intent;
  ShopActionOption? _action;
  ShopContextOption? _context;
  ShopTimingOption? _timing;
  ShopRelationshipOption? _relationship;
  ShopObligationOption? _obligation;
  ExcuseRequest? _request;
  GeneratedIdea? _idea;
  bool _kept = false;
  bool _alternativeRequested = false;
  bool _alternativeFailed = false;
  bool? _alternativeOriginalKept;
  bool _wasInactive = false;
  bool _shopActive = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _collection = widget.collection ?? CardCollection();
    _session = _controller.startSession();
    widget.analytics.record(AnalyticsEvent.appOpen);
  }

  void cancelPendingGeneration() {
    if (mounted) _cancelGenerationOnLeave();
  }

  void _cancelGenerationOnLeave() {
    _controller.cancelPending();
    if (_stage == ShopFlowStage.search) {
      final hasOriginalCard = _idea != null;
      setState(() {
        _stage = hasOriginalCard ? ShopFlowStage.result : ShopFlowStage.error;
        _error = hasOriginalCard
            ? null
            : StateError('Generation cancelled when leaving Shop.');
        _kept = hasOriginalCard ? (_alternativeOriginalKept ?? _kept) : false;
        _alternativeRequested = false;
        _alternativeFailed = false;
        _alternativeOriginalKept = null;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active = TickerMode.valuesOf(context).enabled;
    if (_shopActive && !active) _cancelGenerationOnLeave();
    _shopActive = active;
  }

  @override
  void didUpdateWidget(covariant ExcuseShopPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationVersion == widget.navigationVersion) return;
    _cancelGenerationOnLeave();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scroll.dispose();
    _controller.cancelPending();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _wasInactive = true;
    } else if (state == AppLifecycleState.resumed && _wasInactive) {
      _wasInactive = false;
      widget.analytics.record(AnalyticsEvent.returnUse);
    }
  }

  void _resetScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  void _back() {
    final path = [
      ShopFlowStage.entry,
      ShopFlowStage.intent,
      ShopFlowStage.action,
      ShopFlowStage.context,
      if (_action == null || shopTimingOptionsFor(_action!).isNotEmpty)
        ShopFlowStage.timing,
      ShopFlowStage.relationship,
      ShopFlowStage.obligation,
      ShopFlowStage.visitContext,
    ];
    final index = path.indexOf(_stage);
    final target = index > 0 ? path[index - 1] : ShopFlowStage.obligation;
    _controller.cancelPending();
    setState(() {
      _stage = target;
      if (target.index <= ShopFlowStage.intent.index) _intent = null;
      if (target.index <= ShopFlowStage.action.index) _action = null;
      if (target.index <= ShopFlowStage.context.index) _context = null;
      if (target.index <= ShopFlowStage.timing.index) _timing = null;
      if (target.index <= ShopFlowStage.relationship.index) {
        _relationship = null;
      }
      _obligation = null;
      _request = null;
      _idea = null;
      _error = null;
      _kept = false;
      _alternativeOriginalKept = null;
    });
    _resetScroll();
  }

  void _enterShop() {
    _resetScroll();
    setState(() => _stage = ShopFlowStage.intent);
  }

  void _selectIntent(ShopIntentOption value) {
    _resetScroll();
    setState(() {
      _intent = value;
      _stage = ShopFlowStage.action;
    });
  }

  void _selectAction(ShopActionOption value) {
    _resetScroll();
    setState(() {
      _action = value;
      _timing = null;
      _stage = ShopFlowStage.context;
    });
  }

  void _selectContext(ShopContextOption value) {
    _resetScroll();
    final action = _action;
    if (action == null) return;
    final timings = shopTimingOptionsFor(action);
    setState(() {
      _context = value;
      _stage = timings.isEmpty
          ? ShopFlowStage.relationship
          : ShopFlowStage.timing;
    });
  }

  void _selectTiming(ShopTimingOption value) {
    _resetScroll();
    setState(() {
      _timing = value;
      _stage = ShopFlowStage.relationship;
    });
  }

  void _selectRelationship(ShopRelationshipOption value) {
    _resetScroll();
    setState(() {
      _relationship = value;
      _stage = ShopFlowStage.obligation;
    });
  }

  void _selectObligation(ShopObligationOption value) {
    final intent = _intent;
    final action = _action;
    final context = _context;
    final relationship = _relationship;
    if (intent == null ||
        action == null ||
        context == null ||
        relationship == null) {
      return;
    }

    final request = requestForV6Selections(
      intent: intent,
      action: action,
      context: context,
      timing: _timing,
      relationship: relationship,
      obligation: value,
      profile: widget.profile,
      currentVisitContext: const CurrentVisitContext.skip(),
    );
    final askForVisitContext = _shouldAskForVisitContext;
    setState(() {
      _obligation = value;
      _request = askForVisitContext ? null : request;
      _stage = askForVisitContext
          ? ShopFlowStage.visitContext
          : ShopFlowStage.search;
    });
    if (!askForVisitContext) _brew(request);
  }

  bool get _shouldAskForVisitContext =>
      widget.profile.hasChildren == ProfileYesNo.yes ||
      widget.profile.caregiving == ProfileYesNo.yes;

  List<CurrentVisitResponsibility> get _relevantVisitResponsibilities {
    final values = <CurrentVisitResponsibility>[];
    if (widget.profile.hasChildren == ProfileYesNo.yes) {
      values.add(CurrentVisitResponsibility.childcare);
    }
    if (widget.profile.caregiving == ProfileYesNo.yes) {
      values.add(CurrentVisitResponsibility.anotherCaregivingResponsibility);
    }
    if (widget.profile.workStudyStatusIsKnown) {
      values.add(CurrentVisitResponsibility.existingCommitment);
    }
    values.add(CurrentVisitResponsibility.needingRest);
    return values;
  }

  void _selectVisitContext(CurrentVisitContext value) {
    _resetScroll();
    final intent = _intent;
    final action = _action;
    final context = _context;
    final relationship = _relationship;
    final obligation = _obligation;
    if (intent == null ||
        action == null ||
        context == null ||
        relationship == null ||
        obligation == null) {
      return;
    }
    final request = requestForV6Selections(
      intent: intent,
      action: action,
      context: context,
      timing: _timing,
      relationship: relationship,
      obligation: obligation,
      profile: widget.profile,
      currentVisitContext: value,
    );
    setState(() {
      _request = request;
    });
    _brew(request);
  }

  Future<void> _brew(ExcuseRequest request) async {
    final ticket = _controller.beginOperation();
    final isAlternative = _alternativeRequested;
    _resetScroll();
    setState(() {
      _stage = ShopFlowStage.search;
      _error = null;
      _kept = false;
    });

    if (!widget.disableAnimations &&
        !MediaQuery.of(context).disableAnimations) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
    }

    if (!mounted || !_controller.accepts(ticket)) return;

    try {
      final idea = await generateDetailedIdea(
        widget.client,
        IdeaRequest.fromV6ExcuseRequest(request),
      );
      if (!mounted || !_controller.accepts(ticket)) return;
      setState(() {
        _idea = idea;
        _stage = ShopFlowStage.result;
        _alternativeRequested = false;
        _alternativeFailed = false;
        _alternativeOriginalKept = null;
        _resetScroll();
      });
      widget.analytics.record(AnalyticsEvent.generationCompleted);
      if (!mounted || !_controller.accepts(ticket)) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => CardViewerPage(
            idea: idea,
            mode: CardViewerMode.reveal,
            disableAnimations:
                widget.disableAnimations ||
                MediaQuery.of(context).disableAnimations,
            onShare: widget.onShareCard,
          ),
        ),
      );
    } catch (error) {
      if (!mounted || !_controller.accepts(ticket)) return;
      setState(() {
        _error = error;
        _kept = isAlternative ? (_alternativeOriginalKept ?? _kept) : _kept;
        _alternativeRequested = false;
        _alternativeFailed = isAlternative;
        _alternativeOriginalKept = null;
        _stage = ShopFlowStage.error;
      });
    }
  }

  void _restart() {
    _resetScroll();
    setState(() {
      _session = _controller.startSession();
      _stage = ShopFlowStage.entry;
      _intent = null;
      _action = null;
      _context = null;
      _timing = null;
      _relationship = null;
      _obligation = null;
      _request = null;
      _idea = null;
      _kept = false;
      _alternativeRequested = false;
      _alternativeFailed = false;
      _alternativeOriginalKept = null;
      _error = null;
    });
  }

  Future<void> _keepCard() async {
    final idea = _idea;
    if (idea == null || _saving) return;
    setState(() => _saving = true);
    try {
      await _collection.save(idea);
      if (!mounted) return;
      setState(() {
        if (identical(_idea, idea)) _kept = true;
      });
      widget.onCollectionChanged?.call();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save this card. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openCollection() async {
    final onOpenCollection = widget.onOpenCollection;
    if (onOpenCollection != null) {
      onOpenCollection();
      return;
    }
    try {
      await _collection.load();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CollectionPage(cards: _collection.cards),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open your collection. Please try again.'),
          ),
        );
      }
    }
  }

  void _anotherCard() {
    if (_request != null &&
        !_saving &&
        (_stage == ShopFlowStage.result || _alternativeFailed)) {
      _alternativeOriginalKept = _kept;
      _alternativeRequested = true;
      _brew(_request!);
    }
  }

  Future<void> _copyIdea() async {
    final idea = _idea;
    if (idea == null) return;
    await Clipboard.setData(ClipboardData(text: idea.idea));
    widget.analytics.record(AnalyticsEvent.copy);
  }

  Future<void> _shareCurrentCard() async {
    final idea = _idea;
    final onShare = widget.onShareCard;
    if (idea == null || _sharing) return;
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
        idea,
        _resultRepaintBoundaryKey,
        sharePositionOriginFor(_resultShareButtonKey),
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

  void _setTone(ExcuseTone tone) {
    final idea = _idea;
    if (idea == null) return;
    setState(() {
      _idea = idea.withTone(tone);
      _kept = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Theme(
      data: ShopTheme.theme.copyWith(
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: ShopTheme.pixelOutline,
            minimumSize: const Size(44, 48),
            padding: const EdgeInsets.all(12),
            side: const BorderSide(color: ShopTheme.pixelOutline, width: 4),
            shape: const RoundedRectangleBorder(),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: ShopTheme.pixelViolet,
            foregroundColor: ShopTheme.pixelOutline,
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: ShopTheme.pixelOutline, width: 4),
            shape: const RoundedRectangleBorder(),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: ShopTheme.pixelOutline,
        bottomNavigationBar: widget.showInternalNavigation
            ? SafeArea(
                top: false,
                child: Container(
                  decoration: const BoxDecoration(
                    color: ShopTheme.pixelOutline,
                    border: Border(
                      top: BorderSide(
                        color: ShopTheme.pixelVioletDark,
                        width: 3,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          key: const ValueKey('open-collection'),
                          onPressed: _saving ? null : _openCollection,
                          style: TextButton.styleFrom(
                            foregroundColor: ShopTheme.paperBody,
                            minimumSize: const Size(44, 44),
                          ),
                          icon: const Icon(
                            Icons.collections_bookmark_outlined,
                            size: 18,
                          ),
                          label: const Text('Collection'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        key: const ValueKey('restart-shop'),
                        onPressed: _saving ? null : _restart,
                        style: TextButton.styleFrom(
                          foregroundColor: ShopTheme.paperBody,
                          minimumSize: const Size(44, 44),
                        ),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Restart'),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sceneHeight = _stage == ShopFlowStage.result
                  ? 150.0
                  : (constraints.maxHeight *
                            (_stage == ShopFlowStage.entry ? .52 : .35))
                        .clamp(180.0, 520.0);
              return SingleChildScrollView(
                controller: _scroll,
                child: Column(
                  children: [
                    if (_stage == ShopFlowStage.result)
                      SizedBox(
                        height: sceneHeight,
                        child: ClipRect(
                          child: OverflowBox(
                            minHeight: 320,
                            maxHeight: 320,
                            child: _buildShopScene(l10n, 320),
                          ),
                        ),
                      )
                    else
                      _buildShopScene(l10n, sceneHeight),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                      decoration: const BoxDecoration(
                        color: Color(0xFF241B30),
                        border: Border(
                          top: BorderSide(
                            color: ShopTheme.pixelVioletDark,
                            width: 6,
                          ),
                        ),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: ShopTheme.paperBody,
                              border: Border.all(
                                color: ShopTheme.pixelOutline,
                                width: 7,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: ShopTheme.paperBody,
                                  spreadRadius: 3,
                                ),
                                BoxShadow(
                                  color: ShopTheme.pixelVioletDark,
                                  spreadRadius: 7,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'EXCUSEE',
                                  style: TextStyle(
                                    fontFamily: 'PressStart2P',
                                    fontSize: 8,
                                    color: ShopTheme.pixelVioletDark,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_stage != ShopFlowStage.entry &&
                                    _stage != ShopFlowStage.search)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      key: const ValueKey('v6-back'),
                                      onPressed: _back,
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        size: 16,
                                      ),
                                      label: const Text('Back'),
                                    ),
                                  ),
                                if (_stage != ShopFlowStage.entry &&
                                    _stage != ShopFlowStage.search)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      _dialogueMain(l10n),
                                      style: const TextStyle(
                                        fontSize: 23,
                                        height: 1.25,
                                        fontWeight: FontWeight.w500,
                                        color: ShopTheme.pixelOutline,
                                      ),
                                    ),
                                  ),
                                _buildStageContent(l10n),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShopScene(AppLocalizations l10n, double height) {
    return Semantics(
      container: true,
      label:
          '${l10n.outfitSemantics(_session.outfit.paletteName)}. ${l10n.ambientEventSemantics(_session.ambientEvent.line)}',
      child: SizedBox(
        key: const ValueKey('shopkeeper-stage'),
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: ReferenceShopPainter(
                  outfit: _session.outfit,
                  mood: _stage.index,
                  completed: _completedTokens,
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: ShopTheme.pixelOutline,
                    border: Border.all(color: ShopTheme.pixelViolet, width: 5),
                    boxShadow: const [
                      BoxShadow(color: Color(0x6620182B), offset: Offset(8, 8)),
                    ],
                  ),
                  child: const Text(
                    'Excuse Me',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 12,
                      color: ShopTheme.pixelGlow,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: height * .19,
              child: Semantics(
                key: const ValueKey('shopkeeper-avatar'),
                label: 'Excusee, ${_session.outfit.paletteName}',
                image: true,
                child: const SizedBox(height: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageContent(AppLocalizations l10n) {
    switch (_stage) {
      case ShopFlowStage.entry:
        return _buildEntry(l10n);
      case ShopFlowStage.intent:
        return _buildOptionsStep(
          key: const ValueKey('v6-step-intent'),
          title: l10n.dialogueIntent,
          options: shopIntentOptions.map((option) {
            return _ChoiceData(
              key: ValueKey('v6-intent-${option.intent.name}'),
              label: _intentLabel(l10n, option),
              semantics: l10n.chooseIntent(_intentLabel(l10n, option)),
              onTap: () => _selectIntent(option),
            );
          }).toList(),
        );
      case ShopFlowStage.action:
        final intent = _intent;
        if (intent == null) return const SizedBox.shrink();
        return _buildOptionsStep(
          key: const ValueKey('v6-step-action'),
          title: _actionPrompt(l10n),
          options: shopActionOptionsFor(intent.intent).map((option) {
            return _ChoiceData(
              key: ValueKey('v6-action-${option.action.name}'),
              label: _actionLabel(l10n, option),
              semantics: l10n.chooseAction(_actionLabel(l10n, option)),
              onTap: () => _selectAction(option),
            );
          }).toList(),
        );
      case ShopFlowStage.context:
        return _buildOptionsStep(
          key: const ValueKey('v6-step-context'),
          title: l10n.dialogueContext,
          options: shopContextOptions.map((option) {
            return _ChoiceData(
              key: ValueKey('v6-context-${option.context.name}'),
              label: _contextLabel(l10n, option),
              semantics: l10n.chooseContext(_contextLabel(l10n, option)),
              onTap: () => _selectContext(option),
            );
          }).toList(),
        );
      case ShopFlowStage.timing:
        final action = _action;
        if (action == null) return const SizedBox.shrink();
        return _buildOptionsStep(
          key: const ValueKey('v6-step-timing'),
          title: l10n.dialogueTimingV6,
          options: shopTimingOptionsFor(action).map((option) {
            return _ChoiceData(
              key: ValueKey('v6-timing-${option.timing.name}'),
              label: _timingLabel(l10n, option),
              semantics: _timingLabel(l10n, option),
              onTap: () => _selectTiming(option),
            );
          }).toList(),
        );
      case ShopFlowStage.relationship:
        return _buildOptionsStep(
          key: const ValueKey('v6-step-relationship'),
          title: l10n.dialogueRelationshipV6,
          options: shopRelationshipOptions.map((option) {
            return _ChoiceData(
              key: ValueKey('v6-relationship-${option.relationship.name}'),
              label: _relationshipLabel(l10n, option),
              semantics: l10n.chooseRelationshipV6(
                _relationshipLabel(l10n, option),
              ),
              onTap: () => _selectRelationship(option),
            );
          }).toList(),
        );
      case ShopFlowStage.obligation:
        return _buildOptionsStep(
          key: const ValueKey('v6-step-obligation'),
          title: l10n.dialogueObligationV6,
          options: shopObligationOptions.map((option) {
            return _ChoiceData(
              key: ValueKey('v6-obligation-${option.obligation.name}'),
              label: _obligationLabel(l10n, option),
              semantics: l10n.chooseObligation(_obligationLabel(l10n, option)),
              onTap: () => _selectObligation(option),
            );
          }).toList(),
        );
      case ShopFlowStage.visitContext:
        return _buildVisitContext();
      case ShopFlowStage.search:
        return _buildSearch(l10n);
      case ShopFlowStage.result:
        return _buildResult(l10n);
      case ShopFlowStage.error:
        return _buildError(l10n);
    }
  }

  Widget _buildEntry(AppLocalizations l10n) {
    return Column(
      key: const ValueKey('v6-entry'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _session.opening.mainLine,
          style: const TextStyle(
            fontFamily: 'InterTight',
            fontSize: 25,
            height: 1.25,
            color: ShopTheme.pixelOutline,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _session.opening.supportingLine,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: ShopTheme.uiTextSecondary),
        ),
        const SizedBox(height: 18),
        FilledButton(
          key: const ValueKey('v6-entry-cta'),
          onPressed: _enterShop,
          child: Text(
            l10n.entryCta,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsStep({
    required Key key,
    required String title,
    required List<_ChoiceData> options,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Semantics(
              button: true,
              label: option.semantics,
              child: OutlinedButton(
                key: option.key,
                onPressed: option.onTap,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(option.label),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisitContext() {
    final options = _relevantVisitResponsibilities.map((responsibility) {
      final label = _visitContextLabel(responsibility);
      return _ChoiceData(
        key: ValueKey('v6-visit-context-${responsibility.name}'),
        label: label,
        semantics: label,
        onTap: () => _selectVisitContext(
          CurrentVisitContext(responsibility: responsibility),
        ),
      );
    }).toList();
    options.add(
      _ChoiceData(
        key: const ValueKey('v6-visit-context-skip'),
        label: 'None of these / Skip',
        semantics: 'None of these or skip',
        onTap: _skipVisitContext,
      ),
    );
    return _buildOptionsStep(
      key: const ValueKey('v6-step-visit-context'),
      title: 'Anything real we can work with?',
      options: options,
    );
  }

  void _skipVisitContext() {
    _selectVisitContext(const CurrentVisitContext.skip());
  }

  String _visitContextLabel(CurrentVisitResponsibility responsibility) {
    switch (responsibility) {
      case CurrentVisitResponsibility.childcare:
        return 'Childcare';
      case CurrentVisitResponsibility.anotherCaregivingResponsibility:
        return 'Another caregiving responsibility';
      case CurrentVisitResponsibility.existingCommitment:
        return 'An existing commitment';
      case CurrentVisitResponsibility.needingRest:
        return 'Needing rest';
    }
  }

  Widget _buildSearch(AppLocalizations l10n) {
    return Semantics(
      key: const ValueKey('v6-search'),
      liveRegion: true,
      label: l10n.searchingLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.searchDialogue,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'The shelves shift. A lantern blinks twice.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: ShopTheme.uiTextSecondary),
          ),
          const SizedBox(height: 18),
          if (!widget.disableAnimations &&
              !MediaQuery.of(context).disableAnimations)
            const Center(child: _PixelSpinner())
          else
            const Center(
              child: Icon(Icons.auto_awesome, color: ShopTheme.pixelViolet),
            ),
        ],
      ),
    );
  }

  Widget _buildResult(AppLocalizations l10n) {
    final idea = _idea;
    if (idea == null) return const SizedBox.shrink();
    return Column(
      key: const ValueKey('v6-result'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: RepaintBoundary(
            key: _resultRepaintBoundaryKey,
            child: ExcuseCard(
              key: const ValueKey('collectible-result-card'),
              idea: idea,
            ),
          ),
        ),
        if (_request != null && shouldOfferRepair(_request!)) ...[
          const SizedBox(height: 12),
          Card(
            key: const ValueKey('repair-direction'),
            color: ShopTheme.paperPanel,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.repairDirectionLabel,
                    style: const TextStyle(
                      color: ShopTheme.paperMeta,
                      fontFamily: 'PressStart2P',
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.repairDirectionPending,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: ShopTheme.pixelOutline),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        Text(l10n.tonePromptV6, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _toneButton(l10n.tonePlainV6, ExcuseTone.lowKey, idea),
            _toneButton(l10n.toneWarmV6, ExcuseTone.nice, idea),
            if (_request?.relationship != RelationshipKind.formal &&
                _request?.obligation != ObligationLevel.high &&
                idea.toneDirections.containsKey(ExcuseTone.funny))
              _toneButton(l10n.tonePlayfulV6, ExcuseTone.funny, idea),
          ],
        ),
        const SizedBox(height: 14),
        FilledButton(
          key: const ValueKey('v6-keep-card'),
          onPressed: _kept || _saving ? null : _keepCard,
          child: Text(
            _saving
                ? 'SAVING…'
                : _kept
                ? 'SAVED TO COLLECTION'
                : 'KEEP CARD',
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const ValueKey('v6-another-card'),
          onPressed: _saving ? null : _anotherCard,
          icon: const Icon(Icons.style_outlined, size: 18),
          label: const Text('ANOTHER ONE'),
        ),
        KeyedSubtree(
          key: const ValueKey('v6-share-card'),
          child: OutlinedButton.icon(
            key: _resultShareButtonKey,
            onPressed: _sharing ? null : _shareCurrentCard,
            icon: _sharing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share, size: 18),
            label: const Text('SHARE'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _kept
              ? 'Your card is waiting in Collection.'
              : 'Keep this one, or let Excusee find another.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: ShopTheme.paperMeta),
        ),
        TextButton.icon(
          key: const ValueKey('v6-copy-card'),
          onPressed: _copyIdea,
          icon: const Icon(Icons.copy_outlined, size: 16),
          label: const Text('Copy idea'),
        ),
        const SizedBox(height: 10),
        TextButton(
          key: const ValueKey('v6-new-excuse'),
          onPressed: _restart,
          child: const Text('NEW EXCUSE'),
        ),
      ],
    );
  }

  Widget _toneButton(String label, ExcuseTone tone, GeneratedIdea idea) {
    final selected = idea.selectedTone == tone;
    return Semantics(
      button: true,
      label: '${AppLocalizations.of(context)!.toneChangeSemantics}: $label',
      child: ChoiceChip(
        key: ValueKey('v6-tone-${tone.name}'),
        label: Text(label),
        selected: selected,
        onSelected: idea.toneDirections.containsKey(tone)
            ? (_) => _setTone(tone)
            : null,
        shape: const RoundedRectangleBorder(),
        selectedColor: ShopTheme.pixelGlow,
        side: BorderSide(
          color: selected ? ShopTheme.pixelVioletDark : ShopTheme.paperDivider,
        ),
      ),
    );
  }

  Widget _buildAlternativeError() {
    final idea = _idea!;
    return Column(
      key: const ValueKey('v6-error'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'The alternative shelf is being difficult.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Your current card is still available. Nothing was added to Collection.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 14),
        Center(
          child: RepaintBoundary(
            key: _resultRepaintBoundaryKey,
            child: ExcuseCard(
              key: const ValueKey('collectible-result-card'),
              idea: idea,
            ),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton(
          key: const ValueKey('v6-keep-card'),
          onPressed: _kept || _saving ? null : _keepCard,
          child: Text(
            _saving
                ? 'SAVING…'
                : _kept
                ? 'SAVED TO COLLECTION'
                : 'KEEP CARD',
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const ValueKey('v6-another-card'),
          onPressed: _saving ? null : _anotherCard,
          icon: const Icon(Icons.style_outlined, size: 18),
          label: const Text('TRY ANOTHER ONE'),
        ),
        KeyedSubtree(
          key: const ValueKey('v6-share-card'),
          child: OutlinedButton.icon(
            key: _resultShareButtonKey,
            onPressed: _sharing ? null : _shareCurrentCard,
            icon: _sharing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share, size: 18),
            label: const Text('SHARE'),
          ),
        ),
        TextButton(
          key: const ValueKey('v6-new-excuse'),
          onPressed: _restart,
          child: const Text('NEW EXCUSE'),
        ),
      ],
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    if (_alternativeFailed && _idea != null) {
      return _buildAlternativeError();
    }
    return Column(
      key: const ValueKey('v6-error'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'The shelf is being difficult.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          _error == null ? l10n.generationError : l10n.generationError,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 14),
        FilledButton(onPressed: _restart, child: const Text('START AGAIN')),
      ],
    );
  }

  String _actionPrompt(AppLocalizations l10n) {
    switch (_intent?.intent) {
      case ExcuseIntent.getOutOfPlans:
        return l10n.dialogueActionOut;
      case ExcuseIntent.buyTime:
        return l10n.dialogueActionTime;
      case ExcuseIntent.recoverFromSituation:
        return l10n.dialogueActionRecover;
      case null:
        return l10n.dialogueIntent;
    }
  }

  String _dialogueMain(AppLocalizations l10n) {
    switch (_stage) {
      case ShopFlowStage.entry:
        return _session.opening.mainLine;
      case ShopFlowStage.intent:
        return l10n.dialogueIntent;
      case ShopFlowStage.action:
        return _actionPrompt(l10n);
      case ShopFlowStage.context:
        return l10n.dialogueContext;
      case ShopFlowStage.timing:
        if (_action?.action == ExcuseAction.leaveEarly) {
          return 'Planning your escape, or already there?';
        }
        if (_intent?.intent == ExcuseIntent.recoverFromSituation) {
          return 'And when did this go wrong?';
        }
        return l10n.dialogueTimingV6;
      case ShopFlowStage.relationship:
        return l10n.dialogueRelationshipV6;
      case ShopFlowStage.obligation:
        return l10n.dialogueObligationV6;
      case ShopFlowStage.visitContext:
        return 'Anything real we can work with?';
      case ShopFlowStage.search:
        return l10n.searchDialogue;
      case ShopFlowStage.result:
        return l10n.handoverDialogue;
      case ShopFlowStage.error:
        return 'A small shelf-related complication.';
    }
  }

  String _intentLabel(AppLocalizations l10n, ShopIntentOption option) {
    switch (option.intent) {
      case ExcuseIntent.getOutOfPlans:
        return l10n.intentNeedOut;
      case ExcuseIntent.buyTime:
        return l10n.intentNeedMoreTime;
      case ExcuseIntent.recoverFromSituation:
        return l10n.intentAlreadyMessedUp;
    }
  }

  String _actionLabel(AppLocalizations l10n, ShopActionOption option) {
    switch (option.action) {
      case ExcuseAction.cancel:
        return l10n.actionCancelSomething;
      case ExcuseAction.decline:
        return l10n.actionSayNo;
      case ExcuseAction.leaveEarly:
        return l10n.actionLeaveEarly;
      case ExcuseAction.backOut:
        return 'Back out';
      case ExcuseAction.reschedule:
        return l10n.actionReschedule;
      case ExcuseAction.delay:
        return l10n.actionDelay;
      case ExcuseAction.avoidCommitting:
        return l10n.actionAvoidCommitting;
      case ExcuseAction.explainLateness:
        return "I'm late";
      case ExcuseAction.explainAbsence:
        return "I didn't show";
      case ExcuseAction.acknowledgeMiss:
        return l10n.actionAcknowledgeMiss;
      case ExcuseAction.suggestAlternative:
        return l10n.actionAskMoreTime;
    }
  }

  String _contextLabel(AppLocalizations l10n, ShopContextOption option) {
    switch (option.context) {
      case ExcuseContext.social:
        return l10n.contextSocial;
      case ExcuseContext.personal:
        return l10n.contextPersonal;
      case ExcuseContext.workStudy:
        return l10n.contextWorkStudy;
      case ExcuseContext.practical:
        return l10n.contextPractical;
      default:
        return option.context.name;
    }
  }

  String _timingLabel(AppLocalizations l10n, ShopTimingOption option) {
    switch (option.timing) {
      case ExcuseTiming.plannedAhead:
        return l10n.timingPlannedAhead;
      case ExcuseTiming.today:
        return l10n.timingToday;
      case ExcuseTiming.lastMinute:
        return l10n.timingLastMinute;
      case ExcuseTiming.happeningNow:
        return l10n.timingHappeningNow;
      default:
        return option.timing.name;
    }
  }

  String _relationshipLabel(
    AppLocalizations l10n,
    ShopRelationshipOption option,
  ) {
    switch (option.relationship) {
      case RelationshipKind.close:
        return l10n.relationshipClose;
      case RelationshipKind.casual:
        return l10n.relationshipCasual;
      case RelationshipKind.formal:
        return l10n.relationshipFormal;
      default:
        return option.relationship.name;
    }
  }

  String _obligationLabel(AppLocalizations l10n, ShopObligationOption option) {
    switch (option.obligation) {
      case ObligationLevel.low:
        return l10n.obligationLow;
      case ObligationLevel.medium:
        return l10n.obligationMedium;
      case ObligationLevel.high:
        return l10n.obligationHigh;
      default:
        return option.obligation.name;
    }
  }

  List<bool> get _completedTokens => [
    _intent != null,
    _action != null,
    _context != null,
    _timing != null ||
        (_action != null && shopTimingOptionsFor(_action!).isEmpty),
    _relationship != null,
    _obligation != null,
  ];
}

class _ChoiceData {
  const _ChoiceData({
    required this.key,
    required this.label,
    required this.semantics,
    required this.onTap,
  });

  final Key key;
  final String label;
  final String semantics;
  final VoidCallback onTap;
}

class _PixelSpinner extends StatefulWidget {
  const _PixelSpinner();

  @override
  State<_PixelSpinner> createState() => _PixelSpinnerState();
}

class _PixelSpinnerState extends State<_PixelSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.rotate(
        angle: (_animation.value * math.pi / 2).floor() * math.pi / 2,
        child: child,
      ),
      child: const Icon(
        Icons.auto_awesome,
        color: ShopTheme.pixelViolet,
        size: 42,
      ),
    );
  }
}
