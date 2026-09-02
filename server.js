const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const { createExcuseIdea, validateRequest } = require('./src/excuse');

const publicDir = path.join(__dirname, 'public');
const MAX_BODY_BYTES = 10_000;

function sendJson(response, status, body) {
  response.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Cache-Control': 'no-store',
    'Access-Control-Allow-Origin': '*'
  });
  response.end(JSON.stringify(body));
}

function readJson(request) {
  return new Promise((resolve, reject) => {
    let body = '';
    request.on('data', (chunk) => {
      body += chunk;
      if (Buffer.byteLength(body) > MAX_BODY_BYTES) {
        reject(new Error('Request body is too large.'));
        request.destroy();
      }
    });
    request.on('end', () => {
      try {
        resolve(JSON.parse(body));
      } catch {
        reject(new Error('Invalid request body.'));
      }
    });
    request.on('error', () => reject(new Error('Invalid request body.')));
  });
}

function serveStatic(request, response) {
  const fileName = request.url === '/' ? 'index.html' : request.url.slice(1);
  if (!/^[a-zA-Z0-9._-]+$/.test(fileName)) {
    response.writeHead(404).end();
    return;
  }
  const filePath = path.join(publicDir, fileName);
  fs.readFile(filePath, (error, content) => {
    if (error) {
      response.writeHead(404).end();
      return;
    }
    const type = fileName.endsWith('.css') ? 'text/css' : fileName.endsWith('.js') ? 'application/javascript' : 'text/html';
    response.writeHead(200, { 'Content-Type': `${type}; charset=utf-8`, 'Cache-Control': 'no-store' });
    response.end(content);
  });
}

function createServer() {
  return http.createServer(async (request, response) => {
    if (request.method === 'POST' && request.url === '/api/generate') {
      try {
        const input = await readJson(request);
        const validation = validateRequest(input);
        if (!validation.valid) return sendJson(response, 400, { error: validation.error });
        const result = await createExcuseIdea(input);
        return sendJson(response, 200, result);
      } catch (error) {
        const message = error.message === 'Request body is too large.' ? error.message : 'Invalid request body.';
        return sendJson(response, 400, { error: message });
      }
    }

    if (request.method === 'OPTIONS' && request.url === '/api/generate') {
      response.writeHead(204, {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type'
      }).end();
      return;
    }

    if (request.method === 'GET') return serveStatic(request, response);
    response.writeHead(405).end();
  });
}

if (require.main === module) {
  const port = Number(process.env.PORT) || 3000;
  createServer().listen(port, () => console.log(`Excuse Me is running at http://localhost:${port}`));
}

module.exports = { createServer };
