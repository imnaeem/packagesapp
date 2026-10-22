import { Hono } from 'hono';
import { Env } from '../types/env';
import { UserRow, UserProfile } from '../types/auth';
import { SignupSchema, LoginSchema, GoogleAuthSchema } from '../schemas/auth.schema';
import { hashPassword, verifyPassword, signUserToken, verifyGoogleIdToken } from '../utils/crypto';
import { userAuthMiddleware, UserContext } from '../middleware/auth';

export const authRouter = new Hono<{
  Bindings: Env;
  Variables: { user: UserContext };
}>();

// Helper to format UserRow to safe public profile
function formatUserProfile(row: UserRow): UserProfile {
  return {
    id: row.id,
    email: row.email,
    displayName: row.display_name || '',
    photoUrl: row.photo_url || '',
    authProvider: row.auth_provider || 'local',
    createdAt: row.created_at,
    lastLoginAt: row.last_login_at,
  };
}

/**
 * POST /api/v1/auth/signup
 * Register a new user with email & password (Edge PBKDF2 hashing).
 */
authRouter.post('/signup', async (c) => {
  try {
    const rawBody = await c.req.json().catch(() => null);
    if (!rawBody) {
      return c.json({ success: false, error: 'Invalid or empty JSON body' }, 400);
    }

    const validation = SignupSchema.safeParse(rawBody);
    if (!validation.success) {
      return c.json(
        {
          success: false,
          error: 'Validation failed',
          issues: validation.error.issues,
        },
        400
      );
    }

    const { email, password, displayName, name, photoUrl } = validation.data;
    const finalDisplayName = displayName || name || email.split('@')[0] || 'User';

    // Check if user already exists
    const existing = await c.env.DB.prepare('SELECT id FROM users WHERE email = ?')
      .bind(email)
      .first<{ id: string }>();

    if (existing) {
      return c.json(
        {
          success: false,
          error: 'A user with this email address already exists. Please log in.',
        },
        409
      );
    }

    const userId = crypto.randomUUID();
    const passwordHash = await hashPassword(password);
    const nowIso = new Date().toISOString();

    await c.env.DB.prepare(
      `INSERT INTO users (id, email, password_hash, display_name, photo_url, auth_provider, created_at, last_login_at)
       VALUES (?, ?, ?, ?, ?, 'local', ?, ?)`
    )
      .bind(userId, email, passwordHash, finalDisplayName, photoUrl || null, nowIso, nowIso)
      .run();

    const userRow = await c.env.DB.prepare('SELECT * FROM users WHERE id = ?')
      .bind(userId)
      .first<UserRow>();

    if (!userRow) {
      return c.json({ success: false, error: 'Failed to retrieve created user' }, 500);
    }

    const jwtSecret = c.env.JWT_SECRET || 'pk_packages_jwt_secret_free_2026_super_secure';
    const token = await signUserToken(
      { id: userRow.id, email: userRow.email, displayName: userRow.display_name || '' },
      jwtSecret
    );

    return c.json(
      {
        success: true,
        message: 'Registration successful',
        user: formatUserProfile(userRow),
        token,
      },
      201
    );
  } catch (error: any) {
    return c.json(
      {
        success: false,
        error: error?.message || 'Failed to complete signup',
      },
      500
    );
  }
});

/**
 * POST /api/v1/auth/login
 * Authenticate with email & password.
 */
authRouter.post('/login', async (c) => {
  try {
    const rawBody = await c.req.json().catch(() => null);
    if (!rawBody) {
      return c.json({ success: false, error: 'Invalid or empty JSON body' }, 400);
    }

    const validation = LoginSchema.safeParse(rawBody);
    if (!validation.success) {
      return c.json(
        {
          success: false,
          error: 'Validation failed',
          issues: validation.error.issues,
        },
        400
      );
    }

    const { email, password } = validation.data;

    const userRow = await c.env.DB.prepare('SELECT * FROM users WHERE email = ?')
      .bind(email)
      .first<UserRow>();

    if (!userRow || !userRow.password_hash) {
      return c.json(
        {
          success: false,
          error: 'Invalid email or password',
        },
        401
      );
    }

    const isValid = await verifyPassword(password, userRow.password_hash);
    if (!isValid) {
      return c.json(
        {
          success: false,
          error: 'Invalid email or password',
        },
        401
      );
    }

    // Update last_login_at
    const nowIso = new Date().toISOString();
    await c.env.DB.prepare('UPDATE users SET last_login_at = ? WHERE id = ?')
      .bind(nowIso, userRow.id)
      .run();

    userRow.last_login_at = nowIso;

    const jwtSecret = c.env.JWT_SECRET || 'pk_packages_jwt_secret_free_2026_super_secure';
    const token = await signUserToken(
      { id: userRow.id, email: userRow.email, displayName: userRow.display_name || '' },
      jwtSecret
    );

    return c.json({
      success: true,
      message: 'Login successful',
      user: formatUserProfile(userRow),
      token,
    });
  } catch (error: any) {
    return c.json(
      {
        success: false,
        error: error?.message || 'Failed to complete login',
      },
      500
    );
  }
});

/**
 * POST /api/v1/auth/google
 * Authenticate or upsert user with Google Sign In ID token or payload.
 */
authRouter.post('/google', async (c) => {
  try {
    const rawBody = await c.req.json().catch(() => null);
    if (!rawBody) {
      return c.json({ success: false, error: 'Invalid or empty JSON body' }, 400);
    }

    const validation = GoogleAuthSchema.safeParse(rawBody);
    if (!validation.success) {
      return c.json(
        {
          success: false,
          error: 'Validation failed',
          issues: validation.error.issues,
        },
        400
      );
    }

    const input = validation.data;
    const tokenToVerify = input.idToken || input.token || input.credential;

    let email = input.email ? input.email.toLowerCase().trim() : '';
    let name = input.displayName || input.name || '';
    let photoUrl = input.photoUrl || input.picture || '';

    if (tokenToVerify) {
      const verified = await verifyGoogleIdToken(tokenToVerify);
      if (verified && verified.email) {
        email = verified.email;
        if (!name && verified.name) name = verified.name;
        if (!photoUrl && verified.picture) photoUrl = verified.picture;
      }
    }

    if (!email) {
      return c.json(
        {
          success: false,
          error: 'Could not extract valid email from Google token or request',
        },
        400
      );
    }

    const nowIso = new Date().toISOString();
    let userRow = await c.env.DB.prepare('SELECT * FROM users WHERE email = ?')
      .bind(email)
      .first<UserRow>();

    if (userRow) {
      // User exists - update login time & profile if newer
      await c.env.DB.prepare(
        `UPDATE users 
         SET display_name = COALESCE(NULLIF(?, ''), display_name),
             photo_url = COALESCE(NULLIF(?, ''), photo_url),
             last_login_at = ?
         WHERE id = ?`
      )
        .bind(name || null, photoUrl || null, nowIso, userRow.id)
        .run();

      userRow = await c.env.DB.prepare('SELECT * FROM users WHERE id = ?')
        .bind(userRow.id)
        .first<UserRow>();
    } else {
      // First time Google user - create account
      const userId = crypto.randomUUID();
      const displayName = name || email.split('@')[0] || 'Google User';

      await c.env.DB.prepare(
        `INSERT INTO users (id, email, password_hash, display_name, photo_url, auth_provider, created_at, last_login_at)
         VALUES (?, ?, NULL, ?, ?, 'google', ?, ?)`
      )
        .bind(userId, email, displayName, photoUrl || null, nowIso, nowIso)
        .run();

      userRow = await c.env.DB.prepare('SELECT * FROM users WHERE id = ?')
        .bind(userId)
        .first<UserRow>();
    }

    if (!userRow) {
      return c.json({ success: false, error: 'Failed to retrieve or create Google user' }, 500);
    }

    const jwtSecret = c.env.JWT_SECRET || 'pk_packages_jwt_secret_free_2026_super_secure';
    const token = await signUserToken(
      { id: userRow.id, email: userRow.email, displayName: userRow.display_name || '' },
      jwtSecret
    );

    return c.json({
      success: true,
      message: 'Google authentication successful',
      user: formatUserProfile(userRow),
      token,
    });
  } catch (error: any) {
    return c.json(
      {
        success: false,
        error: error?.message || 'Failed to complete Google authentication',
      },
      500
    );
  }
});

/**
 * GET /api/v1/auth/me
 * Return profile of authenticated user.
 */
authRouter.get('/me', userAuthMiddleware, async (c) => {
  try {
    const userContext = c.get('user');
    const userRow = await c.env.DB.prepare('SELECT * FROM users WHERE id = ?')
      .bind(userContext.id)
      .first<UserRow>();

    if (!userRow) {
      return c.json({ success: false, error: 'User profile not found' }, 404);
    }

    return c.json({
      success: true,
      user: formatUserProfile(userRow),
    });
  } catch (error: any) {
    return c.json(
      {
        success: false,
        error: error?.message || 'Failed to fetch user profile',
      },
      500
    );
  }
});
