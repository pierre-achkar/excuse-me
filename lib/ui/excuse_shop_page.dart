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
    this.onShareCard,
    this.navigationVersion = 0,
  });

  final IdeaClient client;
  final AnalyticsClient analytics;
  final bool disableAnimations;
  final CardCollection? collection;
  final UserProfile profile;
  final VoidCallback? onCollectionChanged;
  final CardViewerShareCallback? onShareCard;
  final int navigationVersion;

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

  /// The answered beats, in the order they are asked. Timing is skipped for
  /// actions that describe something that already happened.
  List<ShopFlowStage> get _questionPath => [
    ShopFlowStage.entry,
    ShopFlowStage.intent,
    ShopFlowStage.action,
    ShopFlowStage.context,
    if (_action == null || shopTimingOptionsFor(_action!).isNotEmpty)
      ShopFlowStage.timing,
    ShopFlowStage.relationship,
    ShopFlowStage.obligation,
    if (_shouldAskForVisitContext) ShopFlowStage.visitContext,
  ];

  /// Back only means something while a question is on screen. Once a card
  /// exists there is nothing behind it but the answers that produced it, and
  /// stepping there would throw the card away.
  bool get _canGoBack => _questionPath.indexOf(_stage) > 0;

  void _back() {
    final path = _questionPath;
    final index = path.indexOf(_stage);
    if (index <= 0) return;
    _rewindTo(path[index - 1]);
  }

  /// Returns to an earlier beat. The answer being revisited and every answer
  /// after it are cleared, because each one narrows the ones that follow.
  void _rewindTo(ShopFlowStage target) {
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
      if (target.index <= ShopFlowStage.obligation.index) _obligation = null;
      _request = null;
      _idea = null;
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
      await _openCurrentCard();
    } catch (_) {
      if (!mounted || !_controller.accepts(ticket)) return;
      setState(() {
        _kept = isAlternative ? (_alternativeOriginalKept ?? _kept) : _kept;
        _alternativeRequested = false;
        _alternativeFailed = isAlternative;
        _alternativeOriginalKept = null;
        _stage = ShopFlowStage.error;
      });
    }
  }

  /// A failed generation should not cost the user six answers: the same
  /// request goes back to the shelf. Start over stays in the panel header.
  void _retryGeneration() {
    final request = _request;
    if (request == null) {
      _restart();
      return;
    }
    _brew(request);
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
    });
  }

  Future<bool> _keepCard() async {
    final idea = _idea;
    if (idea == null || _saving) return false;
    setState(() => _saving = true);
    try {
      await _collection.save(idea);
      if (!mounted) return true;
      setState(() {
        if (identical(_idea, idea)) _kept = true;
      });
      widget.onCollectionChanged?.call();
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.saveCardFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    return false;
  }

  Future<void> _openCurrentCard() async {
    final idea = _idea;
    if (idea == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CardViewerPage(
          idea: idea,
          mode: CardViewerMode.reveal,
          kept: _kept,
          disableAnimations:
              widget.disableAnimations ||
              MediaQuery.of(context).disableAnimations,
          onShare: widget.onShareCard,
          onKeep: _keepCard,
          onAnother: _anotherCard,
          onCopy: _copyIdea,
        ),
      ),
    );
    if (mounted) setState(() {});
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
        SnackBar(content: Text(AppLocalizations.of(context)!.shareUnavailable)),
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
          SnackBar(content: Text(AppLocalizations.of(context)!.shareFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
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
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // The shop is the welcome; once questions start, the answers
              // matter more than the scenery, so the scene gives up room.
              final sceneHeight = switch (_stage) {
                ShopFlowStage.result => 150.0,
                // The shop is the welcome, so the entry gives it room -- but
                // never at the cost of the way in, which has to stay on screen
                // even on a small phone. 340 is what the greeting and its
                // button need below the scene.
                ShopFlowStage.entry =>
                  math
                      .min(
                        constraints.maxHeight * .52,
                        constraints.maxHeight - 340,
                      )
                      .clamp(120.0, 520.0),
                _ => (constraints.maxHeight * .32).clamp(140.0, 300.0),
              };
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
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
                                constraints: const BoxConstraints(
                                  maxWidth: 640,
                                ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        l10n.shopkeeperName,
                                        style: const TextStyle(
                                          fontFamily: 'PressStart2P',
                                          fontSize: 8,
                                          color: ShopTheme.pixelVioletDark,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (_stage != ShopFlowStage.entry)
                                        Wrap(
                                          alignment: WrapAlignment.spaceBetween,
                                          spacing: 8,
                                          children: [
                                            if (_canGoBack)
                                              TextButton.icon(
                                                key: const ValueKey('v6-back'),
                                                onPressed: _back,
                                                icon: const Icon(
                                                  Icons.arrow_back,
                                                  size: 16,
                                                ),
                                                label: Text(l10n.backAction),
                                              )
                                            else
                                              const SizedBox.shrink(),
                                            TextButton(
                                              key: const ValueKey(
                                                'restart-shop',
                                              ),
                                              onPressed: _saving
                                                  ? null
                                                  : _restart,
                                              child: Text(l10n.startOverAction),
                                            ),
                                          ],
                                        ),
                                      if (_canGoBack) _buildStepIndicator(l10n),
                                      // The trail sits above the question so its
                                      // chips are never mistaken for the answers.
                                      if (_canGoBack)
                                        _buildAnswerTrail(
                                          l10n,
                                          interactive: true,
                                        )
                                      else if (_stage == ShopFlowStage.result)
                                        _buildAnswerTrail(
                                          l10n,
                                          interactive: false,
                                        ),
                                      if (_stage != ShopFlowStage.entry &&
                                          _stage != ShopFlowStage.search)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
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
                    ),
                  ),
                  if (_stage == ShopFlowStage.result) _buildResultActions(l10n),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// The result's two ways forward, held out of the scroll view so a tall
  /// card can never push them off screen.
  Widget _buildResultActions(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF241B30),
        border: Border(
          top: BorderSide(color: ShopTheme.pixelVioletDark, width: 3),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  key: const ValueKey('v6-see-card'),
                  onPressed: _saving ? null : _openCurrentCard,
                  child: Text(l10n.openCardAction),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  key: const ValueKey('v6-another-card'),
                  onPressed: _saving ? null : _anotherCard,
                  child: Text(l10n.anotherOneAction),
                ),
              ),
            ],
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
                  child: Text(
                    l10n.appTitle,
                    style: const TextStyle(
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
                label: '${l10n.shopkeeperName}, ${_session.outfit.paletteName}',
                image: true,
                child: const SizedBox(height: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The answers given so far, in the order they were asked, each paired with
  /// the beat that produced it so the trail can send you back to it.
  List<_AnswerData> _answers(AppLocalizations l10n) {
    final intent = _intent;
    final action = _action;
    final answerContext = _context;
    final timing = _timing;
    final relationship = _relationship;
    final obligation = _obligation;
    return [
      if (intent != null)
        _AnswerData(ShopFlowStage.intent, _intentLabel(l10n, intent)),
      if (action != null)
        _AnswerData(ShopFlowStage.action, _actionLabel(l10n, action)),
      if (answerContext != null)
        _AnswerData(ShopFlowStage.context, _contextLabel(l10n, answerContext)),
      if (timing != null)
        _AnswerData(ShopFlowStage.timing, _timingLabel(l10n, timing)),
      if (relationship != null)
        _AnswerData(
          ShopFlowStage.relationship,
          _relationshipLabel(l10n, relationship),
        ),
      if (obligation != null)
        _AnswerData(
          ShopFlowStage.obligation,
          _obligationLabel(l10n, obligation),
        ),
    ];
  }

  /// What you have told the shopkeeper so far. During the conversation each
  /// answer is a way back to its question; once a card exists the trail is
  /// only a record, because revisiting an answer would discard the card.
  Widget _buildAnswerTrail(AppLocalizations l10n, {required bool interactive}) {
    final answers = _answers(l10n);
    if (answers.isEmpty) return const SizedBox.shrink();
    return Padding(
      key: const ValueKey('v6-answer-trail'),
      padding: const EdgeInsets.only(bottom: 14),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final answer in answers)
            Semantics(
              button: interactive,
              label: interactive
                  ? l10n.changeAnswerSemantics(answer.label)
                  : answer.label,
              child: ActionChip(
                key: ValueKey('v6-answer-${answer.stage.name}'),
                label: Text(answer.label),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  color: ShopTheme.pixelOutline,
                ),
                backgroundColor: ShopTheme.paperPanel,
                visualDensity: VisualDensity.compact,
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: ShopTheme.paperDivider),
                ),
                onPressed: interactive ? () => _rewindTo(answer.stage) : null,
              ),
            ),
        ],
      ),
    );
  }

  /// "Step 3 of 6", so the conversation has a visible end.
  Widget _buildStepIndicator(AppLocalizations l10n) {
    final path = _questionPath;
    final index = path.indexOf(_stage);
    if (index <= 0) return const SizedBox.shrink();
    return Padding(
      key: const ValueKey('v6-step-indicator'),
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        l10n.stepIndicator(index, path.length - 1),
        style: const TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 9,
          color: ShopTheme.paperMeta,
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
        return _buildVisitContext(l10n);
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

  /// The question itself is rendered above by the dialogue line, so a step is
  /// just its answers.
  Widget _buildOptionsStep({
    required Key key,
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

  Widget _buildVisitContext(AppLocalizations l10n) {
    final options = _relevantVisitResponsibilities.map((responsibility) {
      final label = _visitContextLabel(l10n, responsibility);
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
        label: l10n.visitContextSkip,
        semantics: l10n.visitContextSkip,
        onTap: _skipVisitContext,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // This is the one beat that asks about the user's real life, so it
        // says why it is asking and that saying nothing is fine.
        Padding(
          key: const ValueKey('v6-visit-context-note'),
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            l10n.visitContextNote,
            style: const TextStyle(fontSize: 13, color: ShopTheme.paperMeta),
          ),
        ),
        _buildOptionsStep(
          key: const ValueKey('v6-step-visit-context'),
          options: options,
        ),
      ],
    );
  }

  void _skipVisitContext() {
    _selectVisitContext(const CurrentVisitContext.skip());
  }

  String _visitContextLabel(
    AppLocalizations l10n,
    CurrentVisitResponsibility responsibility,
  ) {
    switch (responsibility) {
      case CurrentVisitResponsibility.childcare:
        return l10n.visitContextChildcare;
      case CurrentVisitResponsibility.anotherCaregivingResponsibility:
        return l10n.visitContextCaregiving;
      case CurrentVisitResponsibility.existingCommitment:
        return l10n.visitContextCommitment;
      case CurrentVisitResponsibility.needingRest:
        return l10n.visitContextRest;
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
            l10n.searchAmbient,
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
        // The request already carries whether a repair direction was asked
        // for; deciding again here is how the two fell out of step.
        if (_request?.repairPreference != null &&
            _request?.repairPreference != RepairOption.none) ...[
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
        Text(
          _kept ? l10n.resultKept : l10n.resultNotKept,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: ShopTheme.paperMeta),
        ),
      ],
    );
  }

  Widget _buildAlternativeError(AppLocalizations l10n) {
    final idea = _idea!;
    return Column(
      key: const ValueKey('v6-error'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.alternativeErrorDialogue,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.alternativeErrorBody,
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
                ? l10n.savingCard
                : _kept
                ? l10n.cardSavedToCollection
                : l10n.keepCardButton,
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const ValueKey('v6-another-card'),
          onPressed: _saving ? null : _anotherCard,
          icon: const Icon(Icons.style_outlined, size: 18),
          label: Text(l10n.anotherOneAction),
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
            label: Text(l10n.shareAction),
          ),
        ),
      ],
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    if (_alternativeFailed && _idea != null) {
      return _buildAlternativeError(l10n);
    }
    return Column(
      key: const ValueKey('v6-error'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The dialogue line above already names the trouble; this says what
        // it means for the answers and offers the way out.
        Text(
          l10n.generationErrorBody,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 14),
        FilledButton(
          key: const ValueKey('v6-retry-generation'),
          onPressed: _retryGeneration,
          child: Text(l10n.generationRetry),
        ),
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
          return l10n.timingEscapePrompt;
        }
        if (_intent?.intent == ExcuseIntent.recoverFromSituation) {
          return l10n.timingRecoverPrompt;
        }
        return l10n.dialogueTimingV6;
      case ShopFlowStage.relationship:
        return l10n.dialogueRelationshipV6;
      case ShopFlowStage.obligation:
        return l10n.dialogueObligationV6;
      case ShopFlowStage.visitContext:
        return l10n.visitContextPrompt;
      case ShopFlowStage.search:
        return l10n.searchDialogue;
      case ShopFlowStage.result:
        return l10n.handoverDialogue;
      case ShopFlowStage.error:
        return l10n.errorDialogue;
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
        return l10n.actionBackOut;
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

class _AnswerData {
  const _AnswerData(this.stage, this.label);

  final ShopFlowStage stage;
  final String label;
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
