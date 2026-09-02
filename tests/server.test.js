const test = require('node:test');
const assert = require('node:assert/strict');
const { once } = require('node:events');

const { createServer } = require('../server');

async function startServer() {
  const server = createServer({ env: {} });
  server.listen(0, '127.0.0.1');
  await once(server, 'listening');
  return server;
}

test('POST /api/generate returns one local idea', async (t) => {
  const server = await startServer();
  t.after(() => server.close());
  const { port } = server.address();

  const response = await fetch(`http://127.0.0.1:${port}/api/generate`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({
      situation: 'late arrival',
      relationship: 'friend',
      urgency: 'soon',
      tone: 'casual'
    })
  });

  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), {
    idea: 'Idea: Briefly attribute the delay to a time-sensitive issue, acknowledge your friend, and keep the explanation casual.'
  });
});

test('POST /api/generate rejects incomplete input without echoing it', async (t) => {
  const server = await startServer();
  t.after(() => server.close());
  const { port } = server.address();

  const response = await fetch(`http://127.0.0.1:${port}/api/generate`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ situation: 'secret personal detail' })
  });

  assert.equal(response.status, 400);
  assert.deepEqual(await response.json(), { error: 'Relationship is required.' });
});

test('POST /api/generate rejects malformed JSON', async (t) => {
  const server = await startServer();
  t.after(() => server.close());
  const { port } = server.address();

  const response = await fetch(`http://127.0.0.1:${port}/api/generate`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: '{'
  });

  assert.equal(response.status, 400);
  assert.deepEqual(await response.json(), { error: 'Invalid request body.' });
});
