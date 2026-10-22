import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { Env } from './types/env';
import { healthRouter } from './routes/health';
import { networksRouter } from './routes/networks';
import { packagesRouter } from './routes/packages';
import { feedbackRouter } from './routes/feedback';
import { contactRouter } from './routes/contact';
import { authRouter } from './routes/auth';
import { favouritesRouter } from './routes/favourites';
import { aiRouter } from './routes/ai';

const app = new Hono<{ Bindings: Env }>();

// Global Middlewares
app.use('*', logger());
app.use(
  '*',
  cors({
    origin: '*',
    allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Authorization', 'X-API-KEY'],
    maxAge: 86400,
  })
);

// Root Welcome & Discovery
app.get('/', (c) => {
  return c.json({
    name: 'Pakistan Mobile Packages Cloudflare Worker API',
    status: 'running',
    runtime: 'Cloudflare Workers (Edge)',
    version: '1.1.0',
    domain: 'techshiner.com',
    documentation: {
      health: 'GET /health',
      networks: 'GET /api/v1/networks',
      packages: 'GET /api/v1/packages',
      packageById: 'GET /api/v1/packages/:id',
      ingest: 'POST /api/v1/packages/ingest (Requires INGEST_API_KEY)',
      auth: {
        signup: 'POST /api/v1/auth/signup',
        login: 'POST /api/v1/auth/login',
        google: 'POST /api/v1/auth/google',
        me: 'GET /api/v1/auth/me (Requires Bearer token)',
      },
      favourites: {
        list: 'GET /api/v1/favourites (Requires Bearer token)',
        add: 'POST /api/v1/favourites/:packageId (Requires Bearer token)',
        remove: 'DELETE /api/v1/favourites/:packageId (Requires Bearer token)',
        sync: 'POST /api/v1/favourites/sync (Requires Bearer token)',
      },
      contact: 'POST /api/v1/contact',
      feedback: 'POST /api/v1/feedback',
      aiAdvisor: 'POST /api/v1/ai/recommend',
    },
  });
});

// Mount Routes
app.route('/health', healthRouter);
app.route('/api/v1/networks', networksRouter);
app.route('/api/v1/packages', packagesRouter);
app.route('/api/v1/auth', authRouter);
app.route('/api/v1/favourites', favouritesRouter);
app.route('/api/v1/contact', contactRouter);
app.route('/api/v1/feedback', feedbackRouter);
app.route('/api/v1/ai', aiRouter);

// 404 Handler
app.notFound((c) => {
  return c.json(
    {
      success: false,
      error: `Route not found: ${c.req.method} ${c.req.path}`,
    },
    404
  );
});

// Global Error Handler
app.onError((err, c) => {
  console.error('Unhandled Application Error:', err);
  return c.json(
    {
      success: false,
      error: err.message || 'Internal Server Error',
    },
    500
  );
});

export default app;
