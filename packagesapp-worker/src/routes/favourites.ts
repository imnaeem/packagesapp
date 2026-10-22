import { Hono } from 'hono';
import { Env } from '../types/env';
import { userAuthMiddleware, UserContext } from '../middleware/auth';
import { formatPackage } from '../utils/formatter';
import { PackageRow } from '../types/package';

export const favouritesRouter = new Hono<{
  Bindings: Env;
  Variables: { user: UserContext };
}>();

// Apply user authentication to all favourites endpoints
favouritesRouter.use('*', userAuthMiddleware);

/**
 * GET /api/v1/favourites
 * Returns all favourited packages for the authenticated user.
 */
favouritesRouter.get('/', async (c) => {
  try {
    const user = c.get('user');

    const sql = `
      SELECT 
        uf.id as favourite_id,
        uf.user_id as fav_user_id,
        uf.package_id as fav_package_id,
        uf.network_id as fav_network_id,
        uf.created_at as favourited_at,
        p.*
      FROM user_favourites uf
      LEFT JOIN packages p ON uf.package_id = p.id
      WHERE uf.user_id = ?
      ORDER BY uf.created_at DESC;
    `;

    const { results } = await c.env.DB.prepare(sql).bind(user.id).all<any>();

    const favouritesList: any[] = [];
    const packagesList: any[] = [];
    const favouriteIds: string[] = [];

    for (const row of results || []) {
      const packageId = row.fav_package_id || row.id;
      favouriteIds.push(packageId);

      const pkgFormatted = row.id ? formatPackage(row as PackageRow) : null;
      if (pkgFormatted) {
        packagesList.push(pkgFormatted);
      }

      favouritesList.push({
        id: row.favourite_id,
        packageId,
        networkId: row.fav_network_id,
        createdAt: row.favourited_at,
        package: pkgFormatted,
      });
    }

    return c.json({
      success: true,
      count: favouritesList.length,
      favourites: favouritesList,
      packages: packagesList,
      favouriteIds,
    });
  } catch (error: any) {
    return c.json(
      {
        success: false,
        error: error?.message || 'Failed to fetch user favourites',
      },
      500
    );
  }
});

/**
 * POST /api/v1/favourites/sync
 * Sync multiple favourites (e.g. offline cache sync from mobile app).
 * Placed BEFORE /:packageId so /sync is not matched as a parameter.
 */
favouritesRouter.post('/sync', async (c) => {
  try {
    const user = c.get('user');
    const body = await c.req.json().catch(() => null);

    if (!body || !Array.isArray(body.favourites)) {
      return c.json(
        {
          success: false,
          error: 'Invalid request body. Expected { favourites: Array<{ packageId, networkId?, addedAt? }> }',
        },
        400
      );
    }

    const incoming = body.favourites as Array<{
      packageId?: string;
      package_id?: string;
      networkId?: string;
      network_id?: string;
      addedAt?: string;
    }>;

    if (incoming.length > 0) {
      const candidateIds = incoming
        .map((i) => i.packageId || i.package_id)
        .filter(Boolean) as string[];

      if (candidateIds.length > 0) {
        const placeholders = candidateIds.map(() => '?').join(',');
        const existingPackages = await c.env.DB.prepare(
          `SELECT id, network_id FROM packages WHERE id IN (${placeholders})`
        )
          .bind(...candidateIds)
          .all<{ id: string; network_id: string }>();

        const existingMap = new Map((existingPackages.results || []).map((p) => [p.id, p.network_id]));

        const statements: D1PreparedStatement[] = [];

        for (const item of incoming) {
          const packageId = item.packageId || item.package_id;
          if (!packageId || !existingMap.has(packageId)) continue;

          const networkId = item.networkId || item.network_id || existingMap.get(packageId) || 'general';
          const favId = crypto.randomUUID();
          const createdAt = item.addedAt || new Date().toISOString();

          statements.push(
            c.env.DB.prepare(
              `INSERT INTO user_favourites (id, user_id, package_id, network_id, created_at)
               VALUES (?, ?, ?, ?, ?)
               ON CONFLICT(user_id, package_id) DO NOTHING;`
            ).bind(favId, user.id, packageId, networkId, createdAt)
          );
        }

        if (statements.length > 0) {
          await c.env.DB.batch(statements);
        }
      }
    }

    // Return the full merged list
    const sql = `
      SELECT 
        uf.id as favourite_id,
        uf.user_id as fav_user_id,
        uf.package_id as fav_package_id,
        uf.network_id as fav_network_id,
        uf.created_at as favourited_at,
        p.*
      FROM user_favourites uf
      LEFT JOIN packages p ON uf.package_id = p.id
      WHERE uf.user_id = ?
      ORDER BY uf.created_at DESC;
    `;

    const { results } = await c.env.DB.prepare(sql).bind(user.id).all<any>();

    const favouritesList: any[] = [];
    const packagesList: any[] = [];
    const favouriteIds: string[] = [];

    for (const row of results || []) {
      const packageId = row.fav_package_id || row.id;
      favouriteIds.push(packageId);

      const pkgFormatted = row.id ? formatPackage(row as PackageRow) : null;
      if (pkgFormatted) {
        packagesList.push(pkgFormatted);
      }

      favouritesList.push({
        id: row.favourite_id,
        packageId,
        networkId: row.fav_network_id,
        createdAt: row.favourited_at,
        package: pkgFormatted,
      });
    }

    return c.json({
      success: true,
      message: 'Favourites synchronized successfully',
      count: favouritesList.length,
      favourites: favouritesList,
      packages: packagesList,
      favouriteIds,
    });
  } catch (error: any) {
    return c.json(
      {
        success: false,
        error: error?.message || 'Failed to sync favourites',
      },
      500
    );
  }
});

/**
 * POST /api/v1/favourites/:packageId
 * Add a package to user's favourites.
 */
favouritesRouter.post('/:packageId', async (c) => {
  try {
    const user = c.get('user');
    const packageId = c.req.param('packageId');

    if (!packageId) {
      return c.json({ success: false, error: 'Package ID is required' }, 400);
    }

    // Verify package exists in DB
    const pkg = await c.env.DB.prepare('SELECT id, network_id FROM packages WHERE id = ?')
      .bind(packageId)
      .first<{ id: string; network_id: string }>();

    if (!pkg) {
      return c.json({ success: false, error: `Package with id '${packageId}' does not exist` }, 404);
    }

    const body = await c.req.json().catch(() => ({}));
    const networkId = body?.networkId || body?.network_id || pkg.network_id;

    const favId = crypto.randomUUID();
    const nowIso = new Date().toISOString();

    await c.env.DB.prepare(
      `INSERT INTO user_favourites (id, user_id, package_id, network_id, created_at)
       VALUES (?, ?, ?, ?, ?)
       ON CONFLICT(user_id, package_id) 
       DO UPDATE SET network_id = excluded.network_id, created_at = excluded.created_at;`
    )
      .bind(favId, user.id, packageId, networkId, nowIso)
      .run();

    return c.json({
      success: true,
      message: 'Package added to favourites',
      favourite: {
        id: favId,
        userId: user.id,
        packageId,
        networkId,
        createdAt: nowIso,
      },
    });
  } catch (error: any) {
    return c.json(
      {
        success: false,
        error: error?.message || 'Failed to add favourite',
      },
      500
    );
  }
});

/**
 * DELETE /api/v1/favourites/:packageId
 * Remove a package from user's favourites.
 */
favouritesRouter.delete('/:packageId', async (c) => {
  try {
    const user = c.get('user');
    const packageId = c.req.param('packageId');

    if (!packageId) {
      return c.json({ success: false, error: 'Package ID is required' }, 400);
    }

    await c.env.DB.prepare(
      'DELETE FROM user_favourites WHERE user_id = ? AND package_id = ?;'
    )
      .bind(user.id, packageId)
      .run();

    return c.json({
      success: true,
      message: 'Package removed from favourites',
      packageId,
    });
  } catch (error: any) {
    return c.json(
      {
        success: false,
        error: error?.message || 'Failed to remove favourite',
      },
      500
    );
  }
});
