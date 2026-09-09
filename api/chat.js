// api/chat.js
// Función serverless de VERCEL (equivalente a netlify/functions/chat.js,
// pero en el formato que Vercel sí reconoce automáticamente: cualquier
// archivo .js dentro de /api en la raíz del proyecto).
module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido' });
  }

  if (!process.env.GROQ_API_KEY) {
    return res.status(500).json({
      error: 'Falta configurar GROQ_API_KEY en las variables de entorno de Vercel.',
    });
  }

  try {
    const { messages } = req.body || {};

    const response = await fetch(
      'https://api.groq.com/openai/v1/chat/completions',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${process.env.GROQ_API_KEY}`,
        },
        body: JSON.stringify({
          model: 'openai/gpt-oss-120b',
          messages,
          max_tokens: 1024,
          temperature: 0.7,
        }),
      }
    );

    const data = await response.json();
    return res.status(response.status).json(data);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};