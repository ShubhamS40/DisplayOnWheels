import fetch from 'node-fetch';

export default async function handler(req, res) {
  // Set CORS headers for all responses
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  try {
    // Only allow POST requests
    if (req.method !== 'POST') {
      return res.status(405).json({ error: 'Method not allowed' });
    }

    // Log the request body for debugging
    console.log('Request body:', req.body);

    // Make sure we have a body
    if (!req.body || !req.body.token || !req.body.newPassword) {
      return res.status(400).json({ error: 'Missing required fields', received: req.body });
    }

    // Make the request to the backend API
    console.log('Making request to backend API...');
    const apiRes = await fetch('http://3.110.135.112/api/company/reset-password', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(req.body),
    });

    console.log('Backend API response status:', apiRes.status);

    // Handle non-JSON responses
    const contentType = apiRes.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      const data = await apiRes.json();
      console.log('Backend API response data:', data);
      return res.status(apiRes.status).json(data);
    } else {
      const text = await apiRes.text();
      console.log('Backend API response text:', text);
      return res.status(apiRes.status).json({ message: text });
    }
  } catch (err) {
    console.error("Proxy Error:", err);
    return res.status(500).json({ error: "Failed to proxy request", details: err.message });
  }
}
