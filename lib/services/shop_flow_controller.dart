import '../domain/excuse_request.dart';

enum ShopFlowStage {
  entry,
  intent,
  action,
  context,
  timing,
  relationship,
  obligation,
  visitContext,
  search,
  result,
  error,
}

const shopFlowStages = <ShopFlowStage>[
  ShopFlowStage.entry,
  ShopFlowStage.intent,
  ShopFlowStage.action,
  ShopFlowStage.context,
  ShopFlowStage.timing,
  ShopFlowStage.relationship,
  ShopFlowStage.obligation,
  ShopFlowStage.visitContext,
  ShopFlowStage.search,
  ShopFlowStage.result,
  ShopFlowStage.error,
];

enum ShopMood { calm, curious, hurried, pleased, mysterious }

class ShopOutfit {
  const ShopOutfit({
    required this.id,
    required this.paletteName,
    required this.hatHex,
    required this.robeHex,
    required this.trimHex,
    required this.lanternHex,
  });

  final String id;
  final String paletteName;
  final String hatHex;
  final String robeHex;
  final String trimHex;
  final String lanternHex;
}

const shopOutfits = <ShopOutfit>[
  ShopOutfit(
    id: 'storm-scholar',
    paletteName: 'Storm scholar',
    hatHex: '#302A52',
    robeHex: '#4A527B',
    trimHex: '#A7C7D8',
    lanternHex: '#FCDE5A',
  ),
  ShopOutfit(
    id: 'amethyst-dealer',
    paletteName: 'Amethyst dealer',
    hatHex: '#2B173E',
    robeHex: '#7045A7',
    trimHex: '#D5A7F5',
    lanternHex: '#FCDE5A',
  ),
  ShopOutfit(
    id: 'moss-keeper',
    paletteName: 'Moss keeper',
    hatHex: '#233D36',
    robeHex: '#527A57',
    trimHex: '#B8D19D',
    lanternHex: '#FCDE5A',
  ),
  ShopOutfit(
    id: 'ember-archivist',
    paletteName: 'Ember archivist',
    hatHex: '#48231E',
    robeHex: '#9E4F3D',
    trimHex: '#F0B064',
    lanternHex: '#FCDE5A',
  ),
  ShopOutfit(
    id: 'midnight-broker',
    paletteName: 'Midnight broker',
    hatHex: '#171B2D',
    robeHex: '#283C66',
    trimHex: '#88A8D8',
    lanternHex: '#FCDE5A',
  ),
];

class ShopOpening {
  const ShopOpening({required this.mainLine, required this.supportingLine});

  final String mainLine;
  final String supportingLine;
}

const shopOpenings = <ShopOpening>[
  ShopOpening(
    mainLine: 'Well, well. What happened?',
    supportingLine: "Let's see what I've got for you.",
  ),
  ShopOpening(
    mainLine: 'Back again? What happened?',
    supportingLine: 'I might have something for you.',
  ),
  ShopOpening(
    mainLine: "Oh. You've got that look. What happened?",
    supportingLine: "Let's see what we can find.",
  ),
  ShopOpening(
    mainLine: 'Hmm. Trouble?',
    supportingLine: 'I may have just the thing.',
  ),
  ShopOpening(
    mainLine: 'Come in, come in. What happened?',
    supportingLine: "Let's find you something.",
  ),
  ShopOpening(
    mainLine: 'Well, this looks promising. What happened?',
    supportingLine: "I'm sure I've got something around here.",
  ),
  ShopOpening(
    mainLine: 'Alright. What happened this time?',
    supportingLine: "Let's have a look at the shelves.",
  ),
  ShopOpening(
    mainLine: 'You look like you need something.',
    supportingLine: "Tell me just enough. I'll do the digging.",
  ),
];

class ShopAmbientEvent {
  const ShopAmbientEvent({
    required this.id,
    required this.mood,
    required this.line,
  });

  final String id;
  final ShopMood mood;
  final String line;
}

const shopAmbientEvents = <ShopAmbientEvent>[
  ShopAmbientEvent(
    id: 'lantern-flicker',
    mood: ShopMood.calm,
    line: 'The lantern gives a small, knowing flicker.',
  ),
  ShopAmbientEvent(
    id: 'shelf-rattle',
    mood: ShopMood.curious,
    line: 'Something on the upper shelf quietly changes its mind.',
  ),
  ShopAmbientEvent(
    id: 'ledger-page',
    mood: ShopMood.hurried,
    line: 'A ledger page turns itself. It seems impatient.',
  ),
  ShopAmbientEvent(
    id: 'bell-chime',
    mood: ShopMood.pleased,
    line: 'A tiny bell approves of the selection.',
  ),
  ShopAmbientEvent(
    id: 'dust-orbit',
    mood: ShopMood.mysterious,
    line: 'A small orbit of dust passes through the light.',
  ),
];

class ShopSession {
  const ShopSession({
    required this.id,
    required this.outfit,
    required this.opening,
    required this.ambientEvent,
  });

  final int id;
  final ShopOutfit outfit;
  final ShopOpening opening;
  final ShopAmbientEvent ambientEvent;
}

class ShopFlowController {
  int _sessionId = 0;
  int _operationId = 0;
  int _outfitIndex = -1;
  int _openingIndex = -1;
  ShopSession? _session;

  ShopSession get session {
    final active = _session;
    if (active == null) {
      throw StateError('Start a shop session before reading its state.');
    }
    return active;
  }

  ShopSession startSession() {
    _sessionId += 1;
    _operationId += 1;
    _outfitIndex = (_outfitIndex + 1) % shopOutfits.length;
    _openingIndex = (_openingIndex + 1) % shopOpenings.length;
    _session = ShopSession(
      id: _sessionId,
      outfit: shopOutfits[_outfitIndex],
      opening: shopOpenings[_openingIndex],
      ambientEvent:
          shopAmbientEvents[(_sessionId - 1) % shopAmbientEvents.length],
    );
    return _session!;
  }

  int beginOperation() {
    _operationId += 1;
    return _operationId;
  }

  bool accepts(int operationId) => operationId == _operationId;

  void invalidatePendingOperations() {
    _operationId += 1;
  }

  void cancelPending() {
    invalidatePendingOperations();
  }
}

bool skipsTimingFor(ExcuseAction action) {
  return action == ExcuseAction.explainLateness ||
      action == ExcuseAction.explainAbsence ||
      action == ExcuseAction.acknowledgeMiss;
}
