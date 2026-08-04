require('dotenv').config();
const http = require('http');
const https = require('https');

const PORT = process.env.PORT || 3000;
const GROQ_API_KEY = process.env.GROQ_API_KEY;

if (!GROQ_API_KEY) {
  console.error('❌ Falta GROQ_API_KEY. Crea un archivo .env en /proxy con GROQ_API_KEY=tu_key_real');
  process.exit(1);
}

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
    req.on('data', chunk => (body += chunk));
    req.on('end', () => {
      let parsed;
      try {
        parsed = JSON.parse(body);
      } catch (e) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'JSON inválido en el body' }));
        return;
      }

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
        groqRes.on('data', chunk => (responseData += chunk));
        groqRes.on('end', () => {
          // Reenvía el código de estado real de Groq (200, 401, 429, etc.)
          // así en Flutter podemos saber por qué falló, en vez de un error genérico.
          res.writeHead(groqRes.statusCode, { 'Content-Type': 'application/json' });
          res.end(responseData);
        });
      });

      groqReq.on('error', err => {
        console.error('Error llamando a Groq:', err.message);
        res.writeHead(502, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: err.message }));
      });

      groqReq.write(data);
      groqReq.end();
    });
    return;
  }

  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'Ruta no encontrada' }));
});

// 0.0.0.0 en vez de solo localhost: así el proxy también es
// alcanzable desde el emulador de Android (10.0.2.2) o desde
// otros dispositivos en tu misma red Wi-Fi usando tu IP local.
server.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Proxy corriendo en http://0.0.0.0:${PORT}`);
});