import { Hono } from 'hono';
import { Env } from '../types/env';
import { NetworkRow } from '../types/network';
import { formatNetwork } from '../utils/formatter';

export const networksRouter = new Hono<{ Bindings: Env }>();

networksRouter.get('/', async (c) => {
  try {
    // Select active networks with dynamic live active package count
    const query = `
      SELECT 
        n.id,
        n.name,
        n.slug,
        n.slogan,
        n.logo_url,
        n.brand_color,
        n.is_active,
        COALESCE(p.pkg_count, 0) AS package_count,
        n.created_at
      FROM networks n
      LEFT JOIN (
        SELECT network_id, COUNT(*) AS pkg_count 
        FROM packages 
        WHERE is_active = 1 
        GROUP BY network_id
      ) p ON n.id = p.network_id
      WHERE n.is_active = 1
      ORDER BY n.name ASC;
    `;

    const { results } = await c.env.DB.prepare(query).all<NetworkRow>();
    const networks = (results || []).map(formatNetwork);

    c.header('Cache-Control', 'public, max-age=3600, stale-while-revalidate=86400');
    return c.json({
      success: true,
      count: networks.length,
      data: networks,
    });
  } catch (error: any) {
    return c.json(
      {
        success: false,
        error: error?.message || 'Failed to fetch networks',
      },
      500
    );
  }
});
