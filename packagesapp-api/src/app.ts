import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { env } from './config/env';
import { errorHandler, notFoundHandler } from './middleware/error.middleware';
import packageRoutes from './modules/packages/package.routes';
import networkRoutes from './modules/networks/network.routes';
import favouriteRoutes from './modules/favourites/favourite.routes';
import authRoutes from './modules/auth/auth.routes';
import feedbackRoutes from './modules/feedback/feedback.routes';

const app = express();

// Security headers
app.use(helmet());

// CORS
const corsOrigin = env.ALLOWED_ORIGINS.includes('*') ? '*' : env.ALLOWED_ORIGINS;
app.use(
  cors({
    origin: corsOrigin,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: corsOrigin !== '*',
  })
);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Request logging
if (env.NODE_ENV !== 'test') {
  app.use(morgan(env.NODE_ENV === 'production' ? 'combined' : 'dev'));
}

// Health check
app.get('/health', (_req, res) => {
  res.json({
    success: true,
    status: 'healthy',
    env: env.NODE_ENV,
    timestamp: new Date().toISOString(),
  });
});

// API routes
app.use('/api/v1/packages', packageRoutes);
app.use('/api/v1/networks', networkRoutes);
app.use('/api/v1/favourites', favouriteRoutes);
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/feedback', feedbackRoutes);

// 404 handler
app.use(notFoundHandler);

// Error handler
app.use(errorHandler);

export default app;
