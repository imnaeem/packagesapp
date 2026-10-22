import { MiddlewareHandler } from 'hono';
import { Env } from '../types/env';
import { verifyUserToken } from '../utils/crypto';

export interface UserContext {
  id: string;
  email: string;
  displayName?: string;
}

export const ingestAuthMiddleware: MiddlewareHandler<{ Bindings: Env }> = async (c, next) => {
  const expectedKey = c.env.INGEST_API_KEY || 'pk_dev_ingest_secret_2026';

  let providedKey: string | undefined;

  // Check Authorization header: Bearer <token>
  const authHeader = c.req.header('Authorization');
  if (authHeader && authHeader.toLowerCase().startsWith('bearer ')) {
    providedKey = authHeader.substring(7).trim();
  }

  // Check X-API-KEY header as alternative
  if (!providedKey) {
    providedKey = c.req.header('X-API-KEY') || c.req.header('x-api-key');
  }

  if (!providedKey || providedKey !== expectedKey) {
    return c.json(
      {
        success: false,
        error: 'Unauthorized: Valid INGEST_API_KEY is required in Authorization or X-API-KEY header',
      },
      401
    );
  }

  await next();
};

export const userAuthMiddleware: MiddlewareHandler<{
  Bindings: Env;
  Variables: { user: UserContext };
}> = async (c, next) => {
  const authHeader = c.req.header('Authorization');
  if (!authHeader || !authHeader.toLowerCase().startsWith('bearer ')) {
    return c.json(
      {
        success: false,
        error: 'Unauthorized: Missing or invalid Authorization header. Expected Bearer token',
      },
      401
    );
  }

  const token = authHeader.substring(7).trim();
  const secret = c.env.JWT_SECRET || 'pk_packages_jwt_secret_free_2026_super_secure';

  try {
    const payload = await verifyUserToken(token, secret);
    c.set('user', {
      id: String(payload.id || payload.sub),
      email: String(payload.email || ''),
      displayName: payload.displayName ? String(payload.displayName) : undefined,
    });
    await next();
  } catch (err: any) {
    return c.json(
      {
        success: false,
        error: 'Unauthorized: Token is invalid or expired',
      },
      401
    );
  }
};
