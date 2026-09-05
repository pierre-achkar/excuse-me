import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../analytics/analytics_client.dart';
import '../domain/excuse_request.dart';
import '../domain/idea_request.dart';
import '../domain/shop_selection.dart';
import '../l10n/app_localizations.dart';
import '../services/idea_client.dart';
import '../services/shop_flow_controller.dart';
import 'shop_theme.dart';

class ExcuseShopPage extends StatefulWidget {
  const ExcuseShopPage({
    super.key,
    required this.client,
    this.analytics = const NoOpAnalyticsClient(),
    this.disableAnimations = false,
  });

  final IdeaClient client;
  final AnalyticsClient analytics;
  final bool disableAnimations;

  @override
  State<ExcuseShopPage> createState() => _ExcuseShopPageState();
}

class _ExcuseShopPageState extends State<ExcuseShopPage>
    with WidgetsBindingObserver {
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
  bool _wasInactive = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = _controller.startSession();
    widget.analytics.record(AnalyticsEvent.appOpen);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

  void _enterShop() {
    setState(() => _stage = ShopFlowStage.intent);
  }

  void _selectIntent(ShopIntentOption value) {
    setState(() {
      _intent = value;
      _stage = ShopFlowStage.action;
    });
  }

  void _selectAction(ShopActionOption value) {
    setState(() {
      _action = value;
      _timing = null;
      _stage = ShopFlowStage.context;
    });
  }

  void _selectContext(ShopContextOption value) {
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
    setState(() {
      _timing = value;
      _stage = ShopFlowStage.relationship;
    });
  }

  void _selectRelationship(ShopRelationshipOption value) {
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
    );
    setState(() {
      _obligation = value;
      _request = request;
    });
    _brew(request);
  }

  Future<void> _brew(ExcuseRequest request) async {
    final ticket = _controller.beginOperation();
    setState(() => _stage = ShopFlowStage.search);

    if (!widget.disableAnimations) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
    }

    try {
      final idea = await generateDetailedIdea(
        widget.client,
        IdeaRequest.fromV6ExcuseRequest(request),
      );
      if (!mounted || !_controller.accepts(ticket)) return;
      setState(() {
        _idea = idea;
        _stage = ShopFlowStage.result;
      });
      widget.analytics.record(AnalyticsEvent.generationCompleted);
    } catch (error) {
      if (!mounted || !_controller.accepts(ticket)) return;
      setState(() {
        _error = error;
        _stage = ShopFlowStage.error;
      });
    }
  }

  void _restart() {
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
      _error = null;
    });
  }

  void _keepCard() {
    setState(() => _kept = true);
  }

  Future<void> _copyIdea() async {
    final idea = _idea;
    if (idea == null) return;
    await Clipboard.setData(ClipboardData(text: idea.idea));
    widget.analytics.record(AnalyticsEvent.copy);
  }

  void _setTone(ExcuseTone tone) {
    final idea = _idea;
    if (idea == null) return;
    setState(() => _idea = idea.withTone(tone));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: 'PressStart2P',
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            key: const ValueKey('restart-shop'),
            tooltip: 'Start a new visit',
            onPressed: _restart,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildShopScene(l10n),
                    if (_stage != ShopFlowStage.entry &&
                        _stage != ShopFlowStage.result &&
                        _stage != ShopFlowStage.error)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _ProgressTokens(
                          completed: _completedTokens,
                          activeIndex: _activeToken,
                        ),
                      ),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: widget.disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 180),
                      child: _buildStageContent(l10n),
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

  Widget _buildShopScene(AppLocalizations l10n) {
    final event = _session.ambientEvent;
    return Semantics(
      container: true,
      label:
          '${l10n.outfitSemantics(_session.outfit.paletteName)}. '
          '${l10n.ambientEventSemantics(event.line)}',
      child: Container(
        key: const ValueKey('shopkeeper-stage'),
        height: 224,
        decoration: BoxDecoration(
          color: ShopTheme.pixelOutline,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ShopTheme.pixelViolet, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ShopShelvesPainter(
                  outfit: _session.outfit,
                  eventIndex: _session.id - 1,
                ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 12,
              child: _Shopkeeper(
                key: const ValueKey('shopkeeper-avatar'),
                outfit: _session.outfit,
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ShopTheme.pixelOutline.withValues(alpha: .86),
                  border: Border.all(color: ShopTheme.pixelGlow),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Text(
                    event.line.toUpperCase(),
                    style: const TextStyle(
                      color: ShopTheme.pixelGlow,
                      fontFamily: 'PressStart2P',
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 112,
              right: 12,
              bottom: 14,
              child: _DialogueBubble(
                mainLine: _dialogueMain(l10n),
                supportingLine: _dialogueSupporting(l10n),
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
          style: Theme.of(context).textTheme.headlineSmall,
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
            style: const TextStyle(fontFamily: 'PressStart2P', fontSize: 11),
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
    final l10n = AppLocalizations.of(context)!;
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
        Text(
          l10n.tokenLabel(_activeToken + 1, 6),
          style: Theme.of(context).textTheme.labelMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
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
          const Center(child: _PixelSpinner()),
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
        Text(
          l10n.handoverDialogue,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Semantics(
          container: true,
          label: '${idea.playfulName ?? l10n.cardIdeaLabel}. ${idea.idea}',
          child: Card(
            key: const ValueKey('collectible-result-card'),
            color: ShopTheme.paperBody,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    key: const ValueKey('pixel-card-art'),
                    height: 112,
                    child: CustomPaint(painter: _CardArtPainter(idea: idea)),
                  ),
                  const Divider(color: ShopTheme.paperDivider),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.rarityCommon,
                        style: const TextStyle(
                          color: ShopTheme.pixelVioletDark,
                          fontFamily: 'PressStart2P',
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        l10n.cardNumber(idea.kernelId ?? 'LOCAL'),
                        style: const TextStyle(
                          color: ShopTheme.paperMeta,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    idea.playfulName ?? 'A small card from the shelves',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ShopTheme.pixelOutline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.cardIdeaLabel,
                    style: const TextStyle(
                      color: ShopTheme.paperMeta,
                      fontFamily: 'PressStart2P',
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    idea.idea,
                    key: const ValueKey('card-idea-body'),
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: ShopTheme.pixelOutline, height: 1.45),
                  ),
                ],
              ),
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
            _toneButton(l10n.tonePlayfulV6, ExcuseTone.funny, idea),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const ValueKey('v6-copy-card'),
                onPressed: _copyIdea,
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: const Text('COPY IDEA'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                key: const ValueKey('v6-keep-card'),
                onPressed: _kept ? null : _keepCard,
                child: Text(_kept ? l10n.cardKept : l10n.keepCardButton),
              ),
            ),
          ],
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
        onSelected: (_) => _setTone(tone),
        selectedColor: ShopTheme.pixelGlow,
        side: BorderSide(
          color: selected ? ShopTheme.pixelVioletDark : ShopTheme.paperDivider,
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
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
        return l10n.dialogueTimingV6;
      case ShopFlowStage.relationship:
        return l10n.dialogueRelationshipV6;
      case ShopFlowStage.obligation:
        return l10n.dialogueObligationV6;
      case ShopFlowStage.search:
        return l10n.searchDialogue;
      case ShopFlowStage.result:
        return l10n.handoverDialogue;
      case ShopFlowStage.error:
        return 'A small shelf-related complication.';
    }
  }

  String _dialogueSupporting(AppLocalizations l10n) {
    switch (_stage) {
      case ShopFlowStage.entry:
        return _session.opening.supportingLine;
      case ShopFlowStage.search:
        return 'The good ones are never on the front shelf.';
      case ShopFlowStage.result:
        return 'One card. Keep the situation yours.';
      case ShopFlowStage.error:
        return 'No card was taken from the shelves.';
      default:
        return 'Tell me just enough. I will do the digging.';
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
        return l10n.actionSayNo;
      case ExcuseAction.reschedule:
        return l10n.actionReschedule;
      case ExcuseAction.delay:
        return l10n.actionDelay;
      case ExcuseAction.avoidCommitting:
        return l10n.actionAvoidCommitting;
      case ExcuseAction.explainLateness:
        return l10n.actionExplainWhatHappened;
      case ExcuseAction.explainAbsence:
        return l10n.actionAskMoreTime;
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

  int get _activeToken {
    switch (_stage) {
      case ShopFlowStage.intent:
        return 0;
      case ShopFlowStage.action:
        return 1;
      case ShopFlowStage.context:
        return 2;
      case ShopFlowStage.timing:
        return 3;
      case ShopFlowStage.relationship:
        return 4;
      case ShopFlowStage.obligation:
        return 5;
      default:
        return math.min(
          _completedTokens.where((completed) => completed).length,
          5,
        );
    }
  }
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

class _ProgressTokens extends StatelessWidget {
  const _ProgressTokens({required this.completed, required this.activeIndex});

  final List<bool> completed;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: AppLocalizations.of(context)!
          .tokenLabel(activeIndex + 1, completed.length),
      child: Row(
        children: [
          for (var index = 0; index < completed.length; index++) ...[
            Expanded(
              child: Container(
                key: ValueKey('progress-token-$index'),
                height: 8,
                decoration: BoxDecoration(
                  color: completed[index]
                      ? ShopTheme.pixelTeal
                      : index == activeIndex
                      ? ShopTheme.pixelGlow
                      : ShopTheme.paperDivider,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: ShopTheme.pixelOutline, width: .5),
                ),
              ),
            ),
            if (index != completed.length - 1) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _DialogueBubble extends StatelessWidget {
  const _DialogueBubble({required this.mainLine, required this.supportingLine});

  final String mainLine;
  final String supportingLine;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ShopTheme.paperBody,
        border: Border.all(color: ShopTheme.pixelOutline, width: 2),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: ShopTheme.pixelGlow, offset: Offset(3, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EXCUSEE',
              style: TextStyle(
                color: ShopTheme.pixelVioletDark,
                fontFamily: 'PressStart2P',
                fontSize: 8,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              mainLine,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ShopTheme.pixelOutline,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              supportingLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: ShopTheme.paperMeta, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shopkeeper extends StatelessWidget {
  const _Shopkeeper({super.key, required this.outfit});

  final ShopOutfit outfit;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Excusee, ${outfit.paletteName}',
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          _parseColor(outfit.robeHex),
          BlendMode.modulate,
        ),
        child: Image.asset(
          'assets/design/shop-owner-sprite.png',
          width: 106,
          height: 174,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.auto_awesome,
            size: 90,
            color: ShopTheme.pixelGlow,
          ),
        ),
      ),
    );
  }
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

class _ShopShelvesPainter extends CustomPainter {
  const _ShopShelvesPainter({required this.outfit, required this.eventIndex});

  final ShopOutfit outfit;
  final int eventIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = _parseColor(outfit.hatHex);
    canvas.drawRect(Offset.zero & size, background);

    final shelf = Paint()..color = const Color(0xFF3A2A47);
    for (var row = 0; row < 3; row++) {
      final y = 30.0 + row * 48;
      canvas.drawRect(Rect.fromLTWH(8, y, size.width - 16, 5), shelf);
      canvas.drawRect(Rect.fromLTWH(12, y + 5, 5, 35), shelf);
      canvas.drawRect(Rect.fromLTWH(size.width - 17, y + 5, 5, 35), shelf);
    }

    final colors = [
      ShopTheme.pixelTeal,
      ShopTheme.pixelGlow,
      ShopTheme.pixelEmber,
      _parseColor(outfit.trimHex),
    ];
    for (var index = 0; index < 12; index++) {
      final row = index ~/ 4;
      final column = index % 4;
      final left = 28.0 + column * 31;
      final top = 12.0 + row * 48;
      final color = colors[(index + eventIndex) % colors.length];
      final item = Paint()..color = color;
      canvas.drawRect(Rect.fromLTWH(left, top, 16, 14 + (index % 3) * 4), item);
      canvas.drawRect(
        Rect.fromLTWH(left + 4, top - 4, 8, 4),
        Paint()..color = ShopTheme.pixelGlow.withValues(alpha: .65),
      );
    }

    final floor = Paint()..color = ShopTheme.pixelOutline;
    canvas.drawRect(Rect.fromLTWH(0, size.height - 28, size.width, 28), floor);
    for (var x = 0.0; x < size.width; x += 24) {
      canvas.drawRect(
        Rect.fromLTWH(x, size.height - 25, 12, 2),
        Paint()..color = ShopTheme.pixelVioletDark,
      );
    }
  }

  @override
  bool shouldRepaint(_ShopShelvesPainter oldDelegate) {
    return oldDelegate.outfit != outfit || oldDelegate.eventIndex != eventIndex;
  }
}

class _CardArtPainter extends CustomPainter {
  const _CardArtPainter({required this.idea});

  final GeneratedIdea idea;

  @override
  void paint(Canvas canvas, Size size) {
    final panel = Paint()..color = ShopTheme.paperPanel;
    canvas.drawRect(Offset.zero & size, panel);
    final violet = Paint()..color = ShopTheme.pixelViolet;
    final teal = Paint()..color = ShopTheme.pixelTeal;
    final ember = Paint()..color = ShopTheme.pixelEmber;
    final outline = Paint()..color = ShopTheme.pixelOutline;

    canvas.drawRect(Rect.fromLTWH(20, 22, 58, 58), violet);
    canvas.drawRect(Rect.fromLTWH(32, 12, 34, 12), teal);
    canvas.drawRect(Rect.fromLTWH(30, 48, 38, 36), outline);
    canvas.drawRect(Rect.fromLTWH(36, 54, 10, 10), ShopThemePaint.skin);
    canvas.drawRect(Rect.fromLTWH(52, 54, 10, 10), ShopThemePaint.skin);
    canvas.drawRect(Rect.fromLTWH(39, 72, 24, 7), ember);
    canvas.drawRect(Rect.fromLTWH(91, 25, 8, 62), outline);
    canvas.drawRect(Rect.fromLTWH(87, 18, 16, 10), ShopThemePaint.glow);

    final seed = idea.kernelId?.codeUnits.fold<int>(0, (a, b) => a + b) ?? 7;
    final accentColors = [ShopTheme.pixelTeal, ShopTheme.pixelViolet];
    for (var index = 0; index < 6; index++) {
      final left = 150.0 + ((seed + index * 19) % 90);
      final top = 16.0 + ((seed + index * 13) % 72);
      final item = Paint()..color = accentColors[index % accentColors.length];
      canvas.drawRect(Rect.fromLTWH(left, top, 9, 9), item);
    }
  }

  @override
  bool shouldRepaint(_CardArtPainter oldDelegate) => oldDelegate.idea != idea;
}

class ShopThemePaint {
  static final skin = Paint()..color = ShopTheme.paperSkin;
  static final glow = Paint()..color = ShopTheme.pixelGlow;
}

Color _parseColor(String value) {
  final normalized = value.replaceFirst('#', '');
  return Color(int.parse('FF$normalized', radix: 16));
}
