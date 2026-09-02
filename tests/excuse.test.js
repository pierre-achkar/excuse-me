const test = require('node:test');
const assert = require('node:assert/strict');

const {
  createExcuseIdea,
  validateRequest
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

test('uses deterministic local generation', async () => {
  const first = await createExcuseIdea(request);
  const second = await createExcuseIdea(request);

  assert.deepEqual(first, second);
  assert.match(first.idea, /^Idea: /);
  assert.equal(first.idea.includes('Hello'), false);
  assert.equal(first.idea.includes('Thanks'), false);
});

test('does not invoke a network callback', async () => {
  let called = false;
  const originalFetch = globalThis.fetch;
  globalThis.fetch = async () => {
    called = true;
    throw new Error('Network callback must not be called');
  };
  let result;
  try {
    result = await createExcuseIdea(request);
  } finally {
    globalThis.fetch = originalFetch;
  }

  assert.equal(called, false);
  assert.match(result.idea, /^Idea: /);
  assert.equal(result.idea.includes('Hello'), false);
  assert.equal(result.idea.includes('Thanks'), false);
});
