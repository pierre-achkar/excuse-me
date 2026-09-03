import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/excuse_request.dart';
import '../domain/idea_request.dart';
import '../domain/shop_selection.dart';
import '../services/idea_client.dart';
import 'shop_theme.dart';

class ExcuseShopPage extends StatefulWidget {
  const ExcuseShopPage({super.key, required this.client});

  final IdeaClient client;

  @override
  State<ExcuseShopPage> createState() => _ExcuseShopPageState();
}

enum _Step { mission, situation, tone, brewing, result, error }

class _ExcuseShopPageState extends State<ExcuseShopPage> {
  _Step _step = _Step.mission;
  ShopMission? _mission;
  ShopSituation? _situation;
  ShopTone? _tone;
  String? _idea;
  String? _error;

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
      final idea = await widget.client.generate(
        IdeaRequest(
          situation: _requestSituation(),
          relationship: 'Friend',
          urgency: 'Today',
          tone: _requestTone(),
        ),
      );
      if (!mounted) return;
      setState(() {
        _idea = idea;
        _step = _Step.result;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to generate an idea. Please try again.';
        _step = _Step.error;
      });
    }
  }

  String _requestSituation() {
    final action = _situation!.action ?? _mission!.action;
    final actionCue = switch (action) {
      ExcuseAction.cancel => 'cancel',
      ExcuseAction.decline => 'decline',
      ExcuseAction.leaveEarly => 'leave early',
      ExcuseAction.backOut => 'back out',
      ExcuseAction.reschedule => 'reschedule',
      ExcuseAction.delay || ExcuseAction.avoidCommitting => 'delay',
      ExcuseAction.explainLateness => 'late',
      ExcuseAction.explainAbsence => 'missed',
      ExcuseAction.suggestAlternative => 'reschedule',
    };
    final contextCue = switch (_situation!.context) {
      ExcuseContext.celebration => 'celebration',
      ExcuseContext.party => 'party',
      ExcuseContext.dinner => 'dinner',
      ExcuseContext.date => 'date',
      ExcuseContext.family => 'family',
      ExcuseContext.work => 'work',
      ExcuseContext.friends => 'friends',
      ExcuseContext.hobby => 'hobby',
      ExcuseContext.travel => 'travel',
      ExcuseContext.other => 'other',
    };
    return '${_mission!.label}: $actionCue, $contextCue';
  }

  String _requestTone() {
    return switch (_tone!.tone) {
      ExcuseTone.lowKey => 'Straightforward',
      ExcuseTone.nice => 'Warm',
      ExcuseTone.funny => 'Funny',
      ExcuseTone.dramatic => 'Dramatic',
      ExcuseTone.unhinged => 'Unhinged',
    };
  }

  void _onMissionSelected(ShopMission mission) {
    setState(() {
      _mission = mission;
      _step = _Step.situation;
    });
  }

  void _onSituationSelected(ShopSituation situation) {
    setState(() {
      _situation = situation;
      _step = _Step.tone;
    });
  }

  void _onToneSelected(ShopTone tone) {
    _tone = tone;
    _brew();
  }

  Future<void> _regenerate() async {
    await _brew();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _idea!));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Idea copied.')));
    }
  }

  void _startNew() {
    setState(() {
      _step = _Step.mission;
      _mission = null;
      _situation = null;
      _tone = null;
      _idea = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Excuse Shop')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStepContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Semantics(
          label: 'Pixel art shopkeeper',
          image: true,
          child: SizedBox(
            key: const Key('shopkeeper-avatar'),
            width: 72,
            height: 72,
            child: CustomPaint(painter: _ShopkeeperPainter()),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'A friendly shopkeeper helps you craft the perfect excuse.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: ShopTheme.subtle),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    return switch (_step) {
      _Step.mission => _buildMissionStep(),
      _Step.situation => _buildSituationStep(),
      _Step.tone => _buildToneStep(),
      _Step.brewing => _buildBrewingStep(),
      _Step.result => _buildResultStep(),
      _Step.error => _buildErrorStep(),
    };
  }

  Widget _buildStepIndicator(int current, int total) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        'Step $current of $total',
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }

  Widget _buildShopkeeperBubble(String text) {
    return Semantics(
      label: 'Shopkeeper says: $text',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ShopTheme.cardBackground,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: ShopTheme.subtle.withAlpha(80)),
        ),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }

  Widget _buildChoiceCard({
    required String label,
    required String semanticsLabel,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
    );
  }

  Widget _buildMissionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepIndicator(1, 3),
        _buildShopkeeperBubble(
          'Welcome! Tell me what you need and I will help you out.',
        ),
        const SizedBox(height: 20),
        for (final mission in shopMissions)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildChoiceCard(
              label: mission.label,
              semanticsLabel: 'Choose mission: ${mission.label}',
              onTap: () => _onMissionSelected(mission),
            ),
          ),
      ],
    );
  }

  Widget _buildSituationStep() {
    final situations = _mission!.situations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepIndicator(2, 3),
        _buildShopkeeperBubble('Great choice. Now pick a situation that fits.'),
        const SizedBox(height: 20),
        Text(
          'Choose a situation',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        for (final situation in situations)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildChoiceCard(
              label: situation.label,
              semanticsLabel: 'Choose situation: ${situation.label}',
              onTap: () => _onSituationSelected(situation),
            ),
          ),
      ],
    );
  }

  Widget _buildToneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepIndicator(3, 3),
        _buildShopkeeperBubble(
          'Almost there. Pick your ingredient for the tone.',
        ),
        const SizedBox(height: 20),
        Text(
          'Choose your ingredient',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        for (final tone in shopTones)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildChoiceCard(
              label: tone.label,
              semanticsLabel: 'Choose ingredient: ${tone.label}',
              onTap: () => _onToneSelected(tone),
            ),
          ),
      ],
    );
  }

  Widget _buildBrewingStep() {
    return Semantics(
      label: 'Brewing your excuse',
      container: true,
      child: const Column(
        children: [
          SizedBox(height: 48),
          Center(child: CircularProgressIndicator()),
          SizedBox(height: 24),
          Center(child: Text('Brewing your excuse...')),
        ],
      ),
    );
  }

  Widget _buildResultStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your excuse', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          key: const Key('collectible-result-card'),
          color: ShopTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: ShopTheme.accent, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'COLLECTIBLE IDEA',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: ShopTheme.accent,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(_idea!),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          children: [
            Semantics(
              label: 'Regenerate excuse',
              button: true,
              child: OutlinedButton(
                onPressed: _regenerate,
                child: const Text('Regenerate'),
              ),
            ),
            Semantics(
              label: 'Copy excuse to clipboard',
              button: true,
              child: OutlinedButton(
                onPressed: _copy,
                child: const Text('Copy'),
              ),
            ),
            Semantics(
              label: 'Share excuse',
              button: true,
              child: OutlinedButton(
                onPressed: () => Share.share(_idea!),
                child: const Text('Share'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Semantics(
          label: 'Start new excuse',
          button: true,
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _startNew,
              child: const Text('New excuse'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_error!, style: TextStyle(color: ShopTheme.errorColor)),
        const SizedBox(height: 20),
        Semantics(
          label: 'Start new excuse',
          button: true,
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _startNew,
              child: const Text('New excuse'),
            ),
          ),
        ),
      ],
    );
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
