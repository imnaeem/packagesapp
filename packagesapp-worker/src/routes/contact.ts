import { Hono } from 'hono';
import { Env } from '../types/env';
import { processInquiry } from './feedback';

export const contactRouter = new Hono<{ Bindings: Env }>();

/**
 * POST /api/v1/contact
 * Contact endpoint for inquiries related to techshiner.com and the Packages app.
 */
contactRouter.post('/', async (c) => {
  return processInquiry(c, 'contact');
});
