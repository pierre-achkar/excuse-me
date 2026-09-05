import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../analytics/analytics_client.dart';
import '../domain/excuse_request.dart';
import '../domain/idea_request.dart';
import '../domain/shop_selection.dart';
import '../l10n/app_localizations.dart';
import '../services/idea_client.dart';
import 'shop_theme.dart';

class ExcuseShopPage extends StatefulWidget {
  const ExcuseShopPage({
    super.key,
    required this.client,
    this.analytics = const NoOpAnalyticsClient(),
  });

  final IdeaClient client;
  final AnalyticsClient analytics;

  @override
  State<ExcuseShopPage> createState() => _ExcuseShopPageState();
}

enum _Step { damage, timing, audience, delivery, brewing, result, error }

class _ExcuseShopPageState extends State<ExcuseShopPage>
    with WidgetsBindingObserver {
  _Step _step = _Step.damage;
  ShopDamageOption? _damage;
  ShopTimingOption? _timing;
  ShopAudienceOption? _audience;
  ShopDeliveryOption? _delivery;
  ExcuseRequest? _request;
  String? _idea;
  GeneratedIdea? _generatedIdea;
  bool _offerRepair = false;
  String? _error;
  bool _didOpen = false;
  bool _wasNonActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _recordOpenOnce();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _wasNonActive = true;
      return;
    }
    if (_wasNonActive) {
      _wasNonActive = false;
      _recordSafely(AnalyticsEvent.returnUse);
    }
  }

  void _recordOpenOnce() {
    if (_didOpen) return;
    _didOpen = true;
    _recordSafely(AnalyticsEvent.appOpen);
  }

  Future<void> _recordSafely(AnalyticsEvent event) async {
    try {
      await widget.analytics.record(event);
    } catch (_) {
      // Analytics must never block or crash the app.
    }
  }

  Future<void> _brew() async {
    setState(() {
      _step = _Step.brewing;
      _error = null;
    });

    if (!MediaQuery.disableAnimationsOf(context)) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
    if (!mounted) return;

    try {
      final generated = await generateDetailedIdea(
        widget.client,
        IdeaRequest.fromExcuseRequest(_request!),
      );
      if (!mounted) return;
      setState(() {
        _idea = generated.idea;
        _generatedIdea = generated;
        _step = _Step.result;
      });
      await _recordSafely(AnalyticsEvent.generationCompleted);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = l10n.generationError;
        _step = _Step.error;
      });
    }
  }

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  String _damageLabel(ShopDamageOption option) {
    return switch (option.labelKey) {
      'damageDinner' => l10n.damageDinner,
      'damageParty' => l10n.damageParty,
      'damageGroupWorkCall' => l10n.damageGroupWorkCall,
      'damageDate' => l10n.damageDate,
      'damageMissed' => l10n.damageMissed,
      _ => option.labelKey,
    };
  }

  String _timingLabel(ShopTimingOption option) {
    return switch (option.labelKey) {
      'timingPlannedAhead' => l10n.timingPlannedAhead,
      'timingToday' => l10n.timingToday,
      'timingLastMinute' => l10n.timingLastMinute,
      'timingAlreadyLate' => l10n.timingAlreadyLate,
      'timingAlreadyMissed' => l10n.timingAlreadyMissed,
      _ => option.labelKey,
    };
  }

  String _audienceLabel(ShopAudienceOption option) {
    return switch (option.labelKey) {
      'audienceSomeoneClose' => l10n.audienceSomeoneClose,
      'audienceSomeoneFamiliar' => l10n.audienceSomeoneFamiliar,
      'audienceAGroup' => l10n.audienceAGroup,
      'audienceWorkContact' => l10n.audienceWorkContact,
      'audienceSomeoneInCharge' => l10n.audienceSomeoneInCharge,
      _ => option.labelKey,
    };
  }

  String _deliveryLabel(ShopDeliveryOption option) {
    return switch (option.labelKey) {
      'deliveryLowKeyText' => l10n.deliveryLowKeyText,
      'deliveryNiceText' => l10n.deliveryNiceText,
      'deliveryFunnyText' => l10n.deliveryFunnyText,
      'deliveryDramaticVoiceNote' => l10n.deliveryDramaticVoiceNote,
      'deliveryUnhingedCall' => l10n.deliveryUnhingedCall,
      _ => option.labelKey,
    };
  }

  String _toneLabel(ExcuseTone tone) {
    return switch (tone) {
      ExcuseTone.lowKey => l10n.toneLowKey,
      ExcuseTone.nice => l10n.toneNice,
      ExcuseTone.funny => l10n.toneFunny,
      ExcuseTone.dramatic => l10n.toneDramatic,
      ExcuseTone.unhinged => l10n.toneUnhinged,
    };
  }

  void _onDamageSelected(ShopDamageOption damage) {
    setState(() {
      _damage = damage;
      _step = _Step.timing;
    });
  }

  void _onTimingSelected(ShopTimingOption timing) {
    setState(() {
      _timing = timing;
      _step = _Step.audience;
    });
  }

  void _onAudienceSelected(ShopAudienceOption audience) {
    setState(() {
      _audience = audience;
      _step = _Step.delivery;
    });
  }

  void _onDeliverySelected(ShopDeliveryOption delivery) {
    final request = requestForShopSelections(
      damage: _damage!,
      timing: _timing!,
      audience: _audience!,
      delivery: delivery,
    );
    setState(() {
      _delivery = delivery;
      _request = request;
      _offerRepair = shouldOfferRepair(request);
    });
    _brew();
  }

  Future<void> _regenerate() async {
    _recordSafely(AnalyticsEvent.regenerate);
    await _brew();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _idea!));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.ideaCopied)));
    }
    await _recordSafely(AnalyticsEvent.copy);
  }

  void _startNew() {
    setState(() {
      _step = _Step.damage;
      _damage = null;
      _timing = null;
      _audience = null;
      _delivery = null;
      _request = null;
      _idea = null;
      _generatedIdea = null;
      _offerRepair = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.shopTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            if (_step != _Step.result) ...[
              _buildHeader(),
              const SizedBox(height: 24),
            ],
            AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              child: KeyedSubtree(
                key: ValueKey<_Step>(_step),
                child: _buildStepContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: l10n.shopkeeperAvatarLabel,
          image: true,
          child: KeyedSubtree(
            key: const Key('shopkeeper-avatar'),
            child: Container(
              key: const Key('shopkeeper-stage'),
              width: double.infinity,
              height: 124,
              decoration: BoxDecoration(
                color: ShopTheme.paperPanel,
                border: Border.all(color: ShopTheme.uiHairline),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Image.asset(
                  'assets/design/shop-owner-sprite.png',
                  key: const Key('shopkeeper-sprite'),
                  width: 168,
                  height: 118,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (context, error, stackTrace) => SizedBox(
                    width: 96,
                    height: 96,
                    child: CustomPaint(painter: _ShopkeeperPainter()),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.shopHeaderDescription,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: ShopTheme.uiTextSecondary),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    return switch (_step) {
      _Step.damage => _buildDamageStep(),
      _Step.timing => _buildTimingStep(),
      _Step.audience => _buildAudienceStep(),
      _Step.delivery => _buildDeliveryStep(),
      _Step.brewing => _buildBrewingStep(),
      _Step.result => _buildResultStep(),
      _Step.error => _buildErrorStep(),
    };
  }

  Widget _buildStepIndicator(int current) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        l10n.stepIndicator(current, 4),
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }

  Widget _buildShopkeeperBubble(String text) {
    return Semantics(
      label: '${l10n.shopkeeperSays} $text',
      child: Container(
        key: const Key('shopkeeper-dialogue'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ShopTheme.uiHairline),
        ),
        child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }

  Widget _buildChoiceCard({
    required String label,
    required String semanticsLabel,
    required VoidCallback onTap,
    Key? key,
  }) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: Card(
        key: key,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogueStep<T>({
    required int step,
    required String question,
    required List<T> options,
    required String Function(T) label,
    required String Function(T) semanticsLabel,
    required String Function(T) id,
    required void Function(T) onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepIndicator(step),
        _buildShopkeeperBubble(question),
        const SizedBox(height: 20),
        for (final option in options)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildChoiceCard(
              label: label(option),
              semanticsLabel: semanticsLabel(option),
              onTap: () => onTap(option),
              key: Key('reaction-chip-${id(option)}'),
            ),
          ),
      ],
    );
  }

  Widget _buildDamageStep() {
    return _buildDialogueStep<ShopDamageOption>(
      step: 1,
      question: l10n.dialogueDamage,
      options: shopDamageOptions,
      label: _damageLabel,
      semanticsLabel: (option) => l10n.chooseDamage(_damageLabel(option)),
      id: (option) => option.id,
      onTap: _onDamageSelected,
    );
  }

  Widget _buildTimingStep() {
    return _buildDialogueStep<ShopTimingOption>(
      step: 2,
      question: l10n.dialogueTiming,
      options: shopTimingOptions,
      label: _timingLabel,
      semanticsLabel: (option) => l10n.chooseTiming(_timingLabel(option)),
      id: (option) => option.id,
      onTap: _onTimingSelected,
    );
  }

  Widget _buildAudienceStep() {
    return _buildDialogueStep<ShopAudienceOption>(
      step: 3,
      question: l10n.dialogueAudience,
      options: shopAudienceOptions,
      label: _audienceLabel,
      semanticsLabel: (option) => l10n.chooseAudience(_audienceLabel(option)),
      id: (option) => option.id,
      onTap: _onAudienceSelected,
    );
  }

  Widget _buildDeliveryStep() {
    return _buildDialogueStep<ShopDeliveryOption>(
      step: 4,
      question: l10n.dialogueDelivery,
      options: shopDeliveryOptions,
      label: _deliveryLabel,
      semanticsLabel: (option) => l10n.chooseDelivery(_deliveryLabel(option)),
      id: (option) => option.id,
      onTap: _onDeliverySelected,
    );
  }

  Widget _buildBrewingStep() {
    return Semantics(
      label: l10n.brewingYourExcuseSemantic,
      container: true,
      child: Column(
        children: [
          const SizedBox(height: 48),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 24),
          Center(child: Text(l10n.brewingYourExcuse)),
        ],
      ),
    );
  }

  Widget _buildResultStep() {
    final generated = _generatedIdea;
    final compact = MediaQuery.sizeOf(context).height < 700;
    final familyLabel = _familyLabel(generated?.family);
    final toneLabel = _delivery == null ? '' : _toneLabel(_delivery!.tone);
    final cardName = generated?.playfulName ?? 'Fresh idea';
    final cardNumber = generated?.kernelId ?? 'pending';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.resultTitle, style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: compact ? 8 : 12),
        if (compact) ...[
          _buildResultActions(),
          const SizedBox(height: 12),
          _buildNewExcuseButton(),
          const SizedBox(height: 12),
        ],
        KeyedSubtree(
          key: const Key('collectible-result-card'),
          child: TweenAnimationBuilder<double>(
            key: const Key('card-reveal'),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 400),
            curve: const _SteppedRevealCurve(),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 8),
                  child: child,
                ),
              );
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Container(
                  key: const Key('pixel-idea-card'),
                  decoration: BoxDecoration(
                    color: ShopTheme.pixelOutline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        color: ShopTheme.pixelViolet,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: compact ? 6 : 9,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                cardName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                  color: ShopTheme.pixelOutline,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              color: ShopTheme.pixelOutline,
                              padding: EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: compact ? 4 : 5,
                              ),
                              child: const Text(
                                'common',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9,
                                  height: 1.4,
                                  fontWeight: FontWeight.w400,
                                  color: ShopTheme.pixelGlow,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        key: const Key('pixel-card-art'),
                        height: compact ? 100 : 150,
                        color: ShopTheme.paperPanel,
                        child: Center(
                          child: SizedBox(
                            width: compact ? 96 : 120,
                            height: compact ? 96 : 120,
                            child: const CustomPaint(
                              painter: _IdeaCardPainter(),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: ShopTheme.paperBody,
                        padding: compact
                            ? const EdgeInsets.fromLTRB(11, 12, 11, 10)
                            : const EdgeInsets.fromLTRB(13, 15, 13, 13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'the claim',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 8,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                                color: ShopTheme.paperMeta,
                              ),
                            ),
                            SizedBox(height: compact ? 5 : 9),
                            SelectableText(
                              _idea!,
                              style: TextStyle(
                                fontSize: compact ? 16 : 17,
                                height: 1.45,
                                fontWeight: FontWeight.w400,
                                color: ShopTheme.pixelOutline,
                              ),
                            ),
                            SizedBox(height: compact ? 8 : 15),
                            Container(height: 3, color: ShopTheme.paperDivider),
                            SizedBox(height: compact ? 7 : 11),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 5,
                                    runSpacing: 5,
                                    children: [
                                      _buildPixelTag(familyLabel),
                                      _buildPixelTag(toneLabel, tone: true),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'no. $cardNumber',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 8,
                                      height: 1.4,
                                      fontWeight: FontWeight.w400,
                                      color: ShopTheme.paperMeta,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_offerRepair) ...[
                              SizedBox(height: compact ? 10 : 14),
                              Container(
                                key: const Key('repair-direction'),
                                width: double.infinity,
                                padding: const EdgeInsets.only(top: 10),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: ShopTheme.paperDivider,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.repairDirectionLabel,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 8,
                                        height: 1.4,
                                        fontWeight: FontWeight.w400,
                                        color: ShopTheme.paperMeta,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      l10n.repairDirectionPending,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                        fontWeight: FontWeight.w400,
                                        color: ShopTheme.pixelOutline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!compact) ...[const SizedBox(height: 20), _buildResultActions()],
        if (!compact) _buildNewExcuseButton(),
      ],
    );
  }

  Widget _buildResultActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Semantics(
          label: l10n.regenerateSemantics,
          button: true,
          child: FilledButton(
            onPressed: _regenerate,
            child: Text(l10n.regenerateButton),
          ),
        ),
        Semantics(
          label: l10n.copySemantics,
          button: true,
          child: OutlinedButton(onPressed: _copy, child: Text(l10n.copyButton)),
        ),
        Semantics(
          label: l10n.shareSemantics,
          button: true,
          child: OutlinedButton(
            onPressed: () {
              Share.share(_idea!);
              _recordSafely(AnalyticsEvent.share);
            },
            child: Text(l10n.shareButton),
          ),
        ),
      ],
    );
  }

  Widget _buildNewExcuseButton() {
    return Semantics(
      label: l10n.newExcuseSemantics,
      button: true,
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _startNew,
          child: Text(l10n.newExcuseButton),
        ),
      ),
    );
  }

  Widget _buildPixelTag(String label, {bool tone = false}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 132),
      color: tone ? ShopTheme.pixelGlow : ShopTheme.pixelTeal,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 8,
          height: 1.4,
          fontWeight: FontWeight.w400,
          color: ShopTheme.pixelOutline,
        ),
      ),
    );
  }

  String _familyLabel(ExcuseFamily? family) {
    return switch (family) {
      ExcuseFamily.capacityWellbeing => 'capacity',
      ExcuseFamily.careFamily => 'care',
      ExcuseFamily.workStudy => 'work',
      ExcuseFamily.moneyLogistics => 'logistics',
      ExcuseFamily.planningFailure => 'planning',
      ExcuseFamily.boundaryPreference => 'boundary',
      ExcuseFamily.absurdDramatic => 'absurd',
      null => 'family pending',
    };
  }

  Widget _buildErrorStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_error!, style: TextStyle(color: ShopTheme.errorColor)),
        const SizedBox(height: 20),
        Semantics(
          label: l10n.newExcuseSemantics,
          button: true,
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _startNew,
              child: Text(l10n.newExcuseButton),
            ),
          ),
        ),
      ],
    );
  }
}

class _SteppedRevealCurve extends Curve {
  const _SteppedRevealCurve();

  @override
  double transformInternal(double t) {
    if (t >= 1) return 1;
    return (t * 6).floor() / 6;
  }
}

class _ShopkeeperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 12;

    void block(int x, int y, int width, int height, Color color) {
      final paint = Paint()..color = color;
      canvas.drawRect(
        Rect.fromLTWH(x * unit, y * unit, width * unit, height * unit),
        paint,
      );
    }

    block(2, 10, 8, 1, ShopTheme.subtle);
    block(3, 7, 6, 3, ShopTheme.accent);
    block(2, 8, 1, 2, ShopTheme.ink);
    block(9, 8, 1, 2, ShopTheme.ink);
    block(3, 2, 6, 5, ShopTheme.ink);
    block(4, 1, 4, 1, ShopTheme.ink);
    block(3, 3, 1, 2, ShopTheme.ink);
    block(8, 3, 1, 2, ShopTheme.ink);
    block(4, 3, 4, 4, const Color(0xFFF2C49B));
    block(4, 2, 4, 1, ShopTheme.ink);
    block(5, 4, 1, 1, ShopTheme.ink);
    block(7, 4, 1, 1, ShopTheme.ink);
    block(5, 6, 2, 1, ShopTheme.ink);
    block(7, 7, 1, 2, ShopTheme.cardBackground);
    block(5, 8, 1, 2, ShopTheme.cardBackground);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IdeaCardPainter extends CustomPainter {
  const _IdeaCardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 15;

    void block(int x, int y, int width, int height, Color color) {
      canvas.drawRect(
        Rect.fromLTWH(x * unit, y * unit, width * unit, height * unit),
        Paint()..color = color,
      );
    }

    block(4, 1, 7, 13, ShopTheme.pixelOutline);
    block(5, 2, 5, 10, const Color(0xFF3A3346));
    block(6, 5, 3, 1, ShopTheme.pixelEmber);
    block(6, 7, 3, 1, ShopTheme.pixelEmber);
    block(6, 11, 3, 1, ShopTheme.pixelVioletDark);
    block(1, 4, 1, 1, ShopTheme.pixelGlow);
    block(12, 8, 1, 1, ShopTheme.pixelGlow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
