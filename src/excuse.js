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

function sanitizeProviderIdea(content) {
  if (typeof content !== 'string') return null;
  const trimmed = content.trim();
  if (!trimmed || trimmed.length > 280) return null;

  // Direct-message signals trigger the local idea instead of risking reusable text.
  if (/['"“”]/.test(trimmed) || /^(hello|hi|dear|hey)\b/im.test(trimmed) || /\b(regards|sincerely|best|thanks|thank you)\b[,!]?\s*(?:\n|$)/im.test(trimmed) || /\b(i|i'm|i am|my|me)\b/i.test(trimmed)) {
    return null;
  }

  const withoutFormatting = trimmed.replace(/^\s*(?:[-*•]|\d+[.)])\s*/, '');
  const idea = withoutFormatting.startsWith('Idea:')
    ? withoutFormatting
    : `Idea: ${withoutFormatting}`;
  if (idea.length > 280 || !/[.!?]$/.test(idea)) return null;
  return idea;
}

async function requestProviderIdea(input, { env, fetch }) {
  const baseUrl = (env.OPENAI_COMPATIBLE_BASE_URL || 'https://api.openai.com/v1').replace(/\/$/, '');
  const response = await fetch(`${baseUrl}/chat/completions`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${env.OPENAI_COMPATIBLE_API_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      model: env.OPENAI_COMPATIBLE_MODEL || 'gpt-4o-mini',
      messages: [
        {
          role: 'system',
          content: 'Return exactly one concise excuse idea, not a message. Never use greetings, sign-offs, dialogue, quotes, bullets, or a recipient name. Start with "Idea:".'
        },
        {
          role: 'user',
          content: `Situation: ${input.situation}\nRelationship: ${input.relationship}\nUrgency: ${input.urgency}\nTone: ${input.tone}`
        }
      ]
    })
  });

  if (!response.ok) return null;
  const data = await response.json();
  return sanitizeProviderIdea(data?.choices?.[0]?.message?.content);
}

async function createExcuseIdea(input, options = {}) {
  const validation = validateRequest(input);
  if (!validation.valid) throw new Error(validation.error);

  const env = options.env || process.env;
  if (!env.OPENAI_COMPATIBLE_API_KEY) return { idea: localIdea(input) };

  try {
    const providerIdea = await requestProviderIdea(input, {
      env,
      fetch: options.fetch || globalThis.fetch
    });
    return { idea: providerIdea || localIdea(input) };
  } catch {
    return { idea: localIdea(input) };
  }
}

module.exports = { createExcuseIdea, sanitizeProviderIdea, validateRequest };
