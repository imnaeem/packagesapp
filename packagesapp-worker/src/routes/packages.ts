import { Hono } from 'hono';
import { Env } from '../types/env';
import { PackageRow } from '../types/package';
import { formatPackage } from '../utils/formatter';
import { ingestAuthMiddleware } from '../middleware/auth';
import { IngestPayloadSchema, PackageInput } from '../schemas/package.schema';

export const packagesRouter = new Hono<{ Bindings: Env }>();

/**
 * GET /api/v1/packages
 * Query filters: networkId, category, subCategory, isFeatured, isPopular, search, sort, order, limit, offset
 */
packagesRouter.get('/', async (c) => {
  try {
    const {
      networkId,
      category,
      subCategory,
      isFeatured,
      isPopular,
      search,
      sort,
      order = 'asc',
      limit = '50',
      offset = '0',
    } = c.req.query();

    const conditions: string[] = ['is_active = 1'];
    const params: any[] = [];

    if (networkId) {
      conditions.push('network_id = ?');
      params.push(networkId.toLowerCase().trim());
    }

    if (category) {
      conditions.push('category = ?');
      params.push(category.toLowerCase().trim());
    }

    if (subCategory) {
      conditions.push('sub_category = ?');
      params.push(subCategory.toLowerCase().trim());
    }

    if (isFeatured !== undefined) {
      const featuredVal = isFeatured === 'true' || isFeatured === '1' ? 1 : 0;
      conditions.push('is_featured = ?');
      params.push(featuredVal);
    }

    if (isPopular !== undefined) {
      const popularVal = isPopular === 'true' || isPopular === '1' ? 1 : 0;
      conditions.push('is_popular = ?');
      params.push(popularVal);
    }

    if (search && search.trim().length > 0) {
      const searchTerm = `%${search.trim().toLowerCase()}%`;
      conditions.push('(LOWER(name) LIKE ? OR LOWER(details) LIKE ? OR activation_code LIKE ? OR tags_json LIKE ?)');
      params.push(searchTerm, searchTerm, searchTerm, searchTerm);
    }

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

    // Sorting
    let orderByClause = 'ORDER BY is_featured DESC, is_popular DESC, price ASC';
    const sortOrder = order.toLowerCase() === 'desc' ? 'DESC' : 'ASC';

    if (sort) {
      switch (sort.toLowerCase()) {
        case 'price':
          orderByClause = `ORDER BY price ${sortOrder}`;
          break;
        case 'validity':
          orderByClause = `ORDER BY validity_days ${sortOrder}`;
          break;
        case 'name':
          orderByClause = `ORDER BY name ${sortOrder}`;
          break;
        case 'popular':
          orderByClause = `ORDER BY is_popular ${sortOrder}, price ASC`;
          break;
        case 'created':
          orderByClause = `ORDER BY created_at ${sortOrder}`;
          break;
      }
    }

    // Pagination
    const parsedLimit = Math.min(Math.max(parseInt(limit, 10) || 50, 1), 200);
    const parsedOffset = Math.max(parseInt(offset, 10) || 0, 0);

    // Count query
    const countSql = `SELECT COUNT(*) as total FROM packages ${whereClause};`;
    const countResult = await c.env.DB.prepare(countSql).bind(...params).first<{ total: number }>();
    const totalCount = countResult?.total || 0;

    // Fetch query
    const dataSql = `SELECT * FROM packages ${whereClause} ${orderByClause} LIMIT ? OFFSET ?;`;
    const dataParams = [...params, parsedLimit, parsedOffset];
    const { results } = await c.env.DB.prepare(dataSql).bind(...dataParams).all<PackageRow>();

    const packages = (results || []).map(formatPackage);

    c.header('Cache-Control', 'public, max-age=3600, stale-while-revalidate=86400');
    return c.json({
      success: true,
      count: packages.length,
      total: totalCount,
      limit: parsedLimit,
      offset: parsedOffset,
      data: packages,
    });
  } catch (error: any) {
    return c.json(
      {
        success: false,
        error: error?.message || 'Failed to fetch packages',
      },
      500
    );
  }
});

/**
 * GET /api/v1/packages/:id
 */
packagesRouter.get('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const sql = `SELECT * FROM packages WHERE id = ? LIMIT 1;`;
    const row = await c.env.DB.prepare(sql).bind(id).first<PackageRow>();

    if (!row) {
      return c.json(
        {
          success: false,
          error: `Package with id '${id}' not found`,
        },
        404
      );
    }

    c.header('Cache-Control', 'public, max-age=3600, stale-while-revalidate=86400');
    return c.json({
      success: true,
      data: formatPackage(row),
    });
  } catch (error: any) {
    return c.json(
      {
        success: false,
        error: error?.message || 'Failed to fetch package',
      },
      500
    );
  }
});

/**
 * POST /api/v1/packages/ingest
 * Protected endpoint for single package or bulk ingestion with SMART UPSERT
 */
packagesRouter.post('/ingest', ingestAuthMiddleware, async (c) => {
  try {
    const rawBody = await c.req.json().catch(() => null);
    if (!rawBody) {
      return c.json({ success: false, error: 'Invalid or empty JSON body' }, 400);
    }

    const validation = IngestPayloadSchema.safeParse(rawBody);
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

    const { packages } = validation.data;
    let insertedCount = 0;
    let updatedCount = 0;
    const affectedNetworkIds = new Set<string>();
    const savedPackageIds: string[] = [];

    for (const pkg of packages) {
      const netId = pkg.networkId.toLowerCase().trim();
      affectedNetworkIds.add(netId);

      // Check if package already exists with same network_id AND activation_code OR same network_id AND name
      const findSql = `
        SELECT id FROM packages 
        WHERE (network_id = ? AND activation_code = ?)
           OR (network_id = ? AND name = ?)
        LIMIT 1;
      `;
      const existing = await c.env.DB.prepare(findSql)
        .bind(netId, pkg.activationCode, netId, pkg.name)
        .first<{ id: string }>();

      const resourcesJson = JSON.stringify(pkg.resources);
      const addonsJson = JSON.stringify(pkg.addons);
      const extraServicesJson = JSON.stringify(pkg.extraServices);
      const tagsJson = JSON.stringify(pkg.tags);
      const nowIso = new Date().toISOString();

      if (existing?.id) {
        // SMART UPDATE
        const updateSql = `
          UPDATE packages SET
            name = ?,
            category = ?,
            sub_category = ?,
            price = ?,
            recharge_required = ?,
            validity_days = ?,
            validity_hours = ?,
            validity_type = ?,
            activation_code = ?,
            deactivation_code = ?,
            resources_json = ?,
            addons_json = ?,
            extra_services_json = ?,
            details = ?,
            tags_json = ?,
            is_active = ?,
            is_featured = ?,
            is_popular = ?,
            is_special_offer = ?,
            updated_at = ?
          WHERE id = ?;
        `;

        await c.env.DB.prepare(updateSql)
          .bind(
            pkg.name,
            pkg.category,
            pkg.subCategory,
            pkg.price,
            pkg.rechargeRequired,
            pkg.validityDays,
            pkg.validityHours,
            pkg.validityType,
            pkg.activationCode,
            pkg.deactivationCode,
            resourcesJson,
            addonsJson,
            extraServicesJson,
            pkg.details,
            tagsJson,
            pkg.isActive ? 1 : 0,
            pkg.isFeatured ? 1 : 0,
            pkg.isPopular ? 1 : 0,
            pkg.isSpecialOffer ? 1 : 0,
            nowIso,
            existing.id
          )
          .run();

        updatedCount++;
        savedPackageIds.push(existing.id);
      } else {
        // SMART INSERT
        const newId = pkg.id || crypto.randomUUID();
        const insertSql = `
          INSERT INTO packages (
            id, network_id, name, category, sub_category, price, recharge_required,
            validity_days, validity_hours, validity_type, activation_code, deactivation_code,
            resources_json, addons_json, extra_services_json, details, tags_json,
            is_active, is_featured, is_popular, is_special_offer, created_at, updated_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        `;

        await c.env.DB.prepare(insertSql)
          .bind(
            newId,
            netId,
            pkg.name,
            pkg.category,
            pkg.subCategory,
            pkg.price,
            pkg.rechargeRequired,
            pkg.validityDays,
            pkg.validityHours,
            pkg.validityType,
            pkg.activationCode,
            pkg.deactivationCode,
            resourcesJson,
            addonsJson,
            extraServicesJson,
            pkg.details,
            tagsJson,
            pkg.isActive ? 1 : 0,
            pkg.isFeatured ? 1 : 0,
            pkg.isPopular ? 1 : 0,
            pkg.isSpecialOffer ? 1 : 0,
            nowIso,
            nowIso
          )
          .run();

        insertedCount++;
        savedPackageIds.push(newId);
      }
    }

    // Refresh package_count on affected networks
    for (const netId of affectedNetworkIds) {
      await c.env.DB.prepare(`
        UPDATE networks 
        SET package_count = (SELECT COUNT(*) FROM packages WHERE network_id = ? AND is_active = 1)
        WHERE id = ?;
      `)
        .bind(netId, netId)
        .run();
    }

    // Fetch and return saved packages
    const placeholders = savedPackageIds.map(() => '?').join(',');
    const { results } = await c.env.DB.prepare(
      `SELECT * FROM packages WHERE id IN (${placeholders});`
    )
      .bind(...savedPackageIds)
      .all<PackageRow>();

    const savedPackages = (results || []).map(formatPackage);

    return c.json({
      success: true,
      inserted: insertedCount,
      updated: updatedCount,
      total: packages.length,
      packages: savedPackages,
    });
  } catch (error: any) {
    return c.json(
      {
        success: false,
        error: error?.message || 'Package ingestion failed',
      },
      500
    );
  }
});
