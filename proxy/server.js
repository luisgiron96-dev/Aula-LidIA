const http = require('http');
const https = require('https');

const PORT = 3000;
const GROQ_API_KEY = 'API KEY'; // pon tu key aquí

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  if (req.method === 'POST' && req.url === '/chat') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      const parsed = JSON.parse(body);
      const data = JSON.stringify({
        model: 'llama3-8b-8192',
        messages: parsed.messages,
        max_tokens: 1024,
        temperature: 0.7,
      });

      const options = {
        hostname: 'api.groq.com',
        path: '/openai/v1/chat/completions',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${GROQ_API_KEY}`,
          'Content-Length': Buffer.byteLength(data),
        },
      };

      const groqReq = https.request(options, groqRes => {
        let responseData = '';
        groqRes.on('data', chunk => responseData += chunk);
        groqRes.on('end', () => {
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(responseData);
        });
      });

      groqReq.on('error', err => {
        res.writeHead(500);
        res.end(JSON.stringify({ error: err.message }));
      });

      groqReq.write(data);
      groqReq.end();
    });
  }
});

server.listen(PORT, () => {
  console.log(`✅ Proxy corriendo en http://localhost:${PORT}`);
});