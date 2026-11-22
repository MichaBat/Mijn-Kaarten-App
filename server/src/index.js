require('dotenv').config();
const express = require('express');
const rateLimit = require('express-rate-limit');
const { TtlCache } = require('./cache');
const { searchBrands } = require('./logoDev');

const PORT = process.env.PORT || 3000;
const CACHE_TTL_MS = 30 * 24 * 60 * 60 * 1000; // 30 dagen, logo's/domeinen veranderen zelden

const app = express();
const cache = new TtlCache(CACHE_TTL_MS);

// Nodig achter Caddy/Nginx om het echte client-IP te zien i.p.v. dat van de reverse proxy
app.set('trust proxy', 1);

app.use(
  rateLimit({
    windowMs: 60 * 1000,
    max: 20,
    standardHeaders: true,
    legacyHeaders: false,
  })
);

app.use((req, res, next) => {
  if (req.header('x-app-key') !== process.env.APP_SHARED_SECRET) {
    return res.status(401).json({ error: 'unauthorized' });
  }
  next();
});

app.get('/search', async (req, res) => {
  const query = (req.query.q || '').toString().trim();
  if (query.length < 2 || query.length > 100) {
    return res.status(400).json({ error: 'q must be 2-100 characters' });
  }

  const cacheKey = query.toLowerCase();
  const cached = cache.get(cacheKey);
  if (cached) {
    return res.json({ data: cached, cached: true });
  }

  try {
    const data = await searchBrands(query);
    cache.set(cacheKey, data);
    res.json({ data, cached: false });
  } catch (error) {
    if (error.status === 429) {
      return res.status(429).json({ error: 'logo.dev rate limit reached, try again shortly' });
    }
    console.error('Logo.dev search error:', error);
    res.status(502).json({ error: 'search failed' });
  }
});

// Alleen op localhost luisteren: nooit rechtstreeks vanaf internet bereikbaar,
// enkel via de Nginx reverse proxy op deze zelfde machine.
app.listen(PORT, '127.0.0.1', () => {
  console.log(`mycards brand-search proxy listening on 127.0.0.1:${PORT}`);
});
