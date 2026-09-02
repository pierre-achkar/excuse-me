const REQUIRED_FIELDS = [
  ['situation', 'Situation'],
  ['relationship', 'Relationship'],
  ['urgency', 'Urgency'],
  ['tone', 'Tone']
];

function validateRequest(input) {
  if (!input || typeof input !== 'object' || Array.isArray(input)) {
    return { valid: false, error: 'Invalid request body.' };
  }

  for (const [field, label] of REQUIRED_FIELDS) {
    if (typeof input[field] !== 'string' || !input[field].trim()) {
      return { valid: false, error: `${label} is required.` };
    }
  }

  return { valid: true };
}

function localIdea({ relationship, urgency, tone }) {
  const urgencyPhrase = urgency.toLowerCase() === 'soon'
    ? 'time-sensitive issue'
    : `${urgency.toLowerCase()} scheduling conflict`;
  return `Idea: Briefly attribute the delay to a ${urgencyPhrase}, acknowledge your ${relationship.trim()}, and keep the explanation ${tone.trim().toLowerCase()}.`;
}

function isSafeIdea(content) {
  if (typeof content !== 'string') return false;
  const trimmed = content.trim();
  if (!trimmed || !trimmed.startsWith('Idea:') || trimmed.length > 280) return false;

  if (/['"“”]/.test(trimmed) || /^(hello|hi|dear|hey)\b/im.test(trimmed) || /\b(regards|sincerely|best|thanks|thank you)\b[,!]?\s*(?:\n|$)/im.test(trimmed) || /\b(i|i'm|i am|my|me)\b/i.test(trimmed)) {
    return false;
  }

  return /[.!?]$/.test(trimmed);
}

async function createExcuseIdea(input) {
  const validation = validateRequest(input);
  if (!validation.valid) throw new Error(validation.error);

  const idea = localIdea(input);
  if (!isSafeIdea(idea)) throw new Error('Generated idea failed safety checks.');
  return { idea };
}

module.exports = { createExcuseIdea, isSafeIdea, validateRequest };
