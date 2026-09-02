const test = require('node:test');
const assert = require('node:assert/strict');

const {
  createExcuseIdea,
  validateRequest,
  sanitizeProviderIdea
} = require('../src/excuse');

const request = {
  situation: 'I need to miss a project meeting',
  relationship: 'manager',
  urgency: 'today',
  tone: 'professional'
};

test('validates all required form fields', () => {
  assert.deepEqual(validateRequest({}), {
    valid: false,
    error: 'Situation is required.'
  });
  assert.deepEqual(validateRequest({ ...request, urgency: '' }), {
    valid: false,
    error: 'Urgency is required.'
  });
});

test('uses a deterministic local fallback when no provider key is set', async () => {
  const first = await createExcuseIdea(request, { env: {} });
  const second = await createExcuseIdea(request, { env: {} });

  assert.deepEqual(first, second);
  assert.match(first.idea, /^Idea: /);
  assert.equal(first.idea.includes('Hello'), false);
  assert.equal(first.idea.includes('Thanks'), false);
});

test('uses an explicitly enabled OpenAI-compatible provider', async () => {
  let called = false;
  const result = await createExcuseIdea(request, {
    env: { OPENAI_COMPATIBLE_API_KEY: 'test-key' },
    fetch: async (url, options) => {
      called = true;
      assert.equal(url, 'https://api.openai.com/v1/chat/completions');
      assert.equal(options.headers.Authorization, 'Bearer test-key');
      return {
        ok: true,
        json: async () => ({ choices: [{ message: { content: 'Idea: Mention an unavoidable scheduling conflict and offer a prompt update.' } }] })
      };
    }
  });

  assert.equal(called, true);
  assert.equal(result.idea, 'Idea: Mention an unavoidable scheduling conflict and offer a prompt update.');
});

test('falls back safely when the provider returns copy-ready message content', async () => {
  const result = await createExcuseIdea(request, {
    env: { OPENAI_COMPATIBLE_API_KEY: 'test-key' },
    fetch: async () => ({
      ok: true,
      json: async () => ({ choices: [{ message: { content: 'Hello Pat,\n\n"I cannot make the meeting today."\n\nThanks,\nAlex' } }] })
    })
  });

  assert.match(result.idea, /^Idea: /);
  assert.equal(result.idea.includes('Hello'), false);
  assert.equal(result.idea.includes('cannot make'), false);
});

test('removes copy-ready formatting from provider ideas', () => {
  assert.equal(
    sanitizeProviderIdea('• Idea: Cite a scheduling conflict, then offer a new time.'),
    'Idea: Cite a scheduling conflict, then offer a new time.'
  );
  assert.equal(sanitizeProviderIdea('Regards,\nIdea: Cite a conflict.'), null);
  assert.equal(sanitizeProviderIdea('"I cannot attend."'), null);
});
