import { Hono } from 'hono';
import { Env } from '../types/env';
import { PackageRow, PackageResponse } from '../types/package';
import { formatPackage } from '../utils/formatter';

export const aiRouter = new Hono<{ Bindings: Env }>();

interface ParsedCriteria {
  network?: string;
  category?: string;
  validity?: string;
  maxPrice?: number;
  keywords: string[];
}

/**
 * Extract telecom search intent from a natural language query.
 */
function parseUserQuery(query: string, networkParam?: string): ParsedCriteria {
  const q = query.toLowerCase();

  // 1. Detect Network
  let network: string | undefined = networkParam ? networkParam.toLowerCase() : undefined;
  if (!network) {
    if (q.includes('jazz') || q.includes('mobilink') || q.includes('warid')) {
      network = 'jazz';
    } else if (q.includes('zong') || q.includes('cmpak')) {
      network = 'zong';
    } else if (q.includes('telenor')) {
      network = 'telenor';
    } else if (q.includes('ufone')) {
      network = 'ufone';
    } else if (q.includes('ptcl')) {
      network = 'ptcl';
    }
  }

  // 2. Detect Category
  let category: string | undefined;
  if (
    q.includes('internet') ||
    q.includes('data') ||
    q.includes('4g') ||
    q.includes('mb') ||
    q.includes('gb') ||
    q.includes('net') ||
    q.includes('browse') ||
    q.includes('browsing')
  ) {
    category = 'internet';
  } else if (q.includes('social') || q.includes('whatsapp') || q.includes('facebook') || q.includes('youtube') || q.includes('tiktok')) {
    category = 'social';
  } else if (q.includes('gaming') || q.includes('pubg') || q.includes('game')) {
    category = 'gaming';
  } else if (q.includes('sms') || q.includes('message') || q.includes('text')) {
    category = 'sms';
  } else if (q.includes('call') || q.includes('minute') || q.includes('minutes') || q.includes('voice')) {
    category = 'call';
  } else if (q.includes('hybrid') || q.includes('all in one') || q.includes('all-in-one') || q.includes('super duper')) {
    category = 'hybrid';
  }

  // 3. Detect Validity
  let validity: string | undefined;
  if (q.includes('daily') || q.includes('1 day') || q.includes('one day') || q.includes('24 hour') || q.includes('today')) {
    validity = 'daily';
  } else if (q.includes('weekly') || q.includes('7 day') || q.includes('seven day') || q.includes('week')) {
    validity = 'weekly';
  } else if (q.includes('monthly') || q.includes('30 day') || q.includes('month')) {
    validity = 'monthly';
  }

  // 4. Detect Price Budget
  let maxPrice: number | undefined;
  const priceMatches = [
    q.match(/(?:under|below|less than|within|max|budget)\s*(?:rs\.?|pkr)?\s*(\d+)/i),
    q.match(/(?:rs\.?|pkr)\s*(\d+)/i),
  ];
  for (const m of priceMatches) {
    if (m && m[1]) {
      const p = parseInt(m[1], 10);
      if (!isNaN(p) && p > 0) {
        maxPrice = p;
        break;
      }
    }
  }

  // Tokenize keywords
  const keywords = q
    .replace(/[^\w\s]/gi, ' ')
    .split(/\s+/)
    .filter((w) => w.length > 2);

  return { network, category, validity, maxPrice, keywords };
}

/**
 * Generate fallback structured advice if Workers AI is not bound or offline.
 */
function generateStructuredAdvice(query: string, suggestedPackages: PackageResponse[]): string {
  if (suggestedPackages.length === 0) {
    return `We couldn't find an exact match for "${query}". Try searching for specific networks like Jazz, Zong, Telenor, or Ufone with durations such as daily, weekly, or monthly.`;
  }

  const best = suggestedPackages[0];
  const networkName = best.networkId.toUpperCase();
  const validityStr = best.validityDays === 1 ? '1 day' : `${best.validityDays} days`;

  let advice = `For "${query}", we recommend **${best.name}** on **${networkName}**. It costs **Rs. ${best.price}** for ${validityStr} and can be activated directly by dialing **${best.activationCode}**.`;

  if (best.details) {
    advice += ` ${best.details}`;
  }

  if (suggestedPackages.length > 1) {
    advice += ` We also found ${suggestedPackages.length - 1} other suitable options listed below.`;
  }

  return advice;
}

/**
 * POST /api/v1/ai/recommend
 * AI-powered Mobile Package Advisor with Cloudflare Workers AI + Smart Fallback.
 */
aiRouter.post('/recommend', async (c) => {
  try {
    const body = await c.req.json().catch(() => null);
    if (!body || typeof body.query !== 'string' || body.query.trim().length < 2) {
      return c.json(
        {
          success: false,
          error: 'Query parameter is required (minimum 2 characters)',
        },
        400
      );
    }

    const userQuery = body.query.trim();
    const networkParam = body.network ? String(body.network).trim() : undefined;
    const criteria = parseUserQuery(userQuery, networkParam);

    // Build SQL query for candidate packages
    let whereClauses: string[] = ['is_active = 1'];
    let params: any[] = [];

    if (criteria.network) {
      whereClauses.push('network_id = ?');
      params.push(criteria.network);
    }

    if (criteria.category) {
      if (criteria.category === 'internet') {
        whereClauses.push("(category = 'internet' OR category = 'hybrid')");
      } else if (criteria.category === 'call') {
        whereClauses.push("(category = 'call' OR category = 'hybrid')");
      } else {
        whereClauses.push('(category = ? OR category = "hybrid")');
        params.push(criteria.category);
      }
    }

    if (criteria.validity) {
      whereClauses.push('(sub_category = ? OR validity_type = ?)');
      params.push(criteria.validity, criteria.validity);
    }

    if (criteria.maxPrice) {
      whereClauses.push('price <= ?');
      params.push(criteria.maxPrice);
    }

    let sql = `
      SELECT * FROM packages 
      WHERE ${whereClauses.join(' AND ')}
      ORDER BY is_featured DESC, is_popular DESC, price ASC
      LIMIT 5;
    `;

    let { results } = await c.env.DB.prepare(sql).bind(...params).all<PackageRow>();

    // Fallback search if strict filter gave no results
    if (!results || results.length === 0) {
      let relaxedClauses: string[] = ['is_active = 1'];
      let relaxedParams: any[] = [];

      if (criteria.network) {
        relaxedClauses.push('network_id = ?');
        relaxedParams.push(criteria.network);
      }

      // Keyword LIKE search
      if (criteria.keywords.length > 0) {
        const keywordConditions = criteria.keywords
          .slice(0, 3)
          .map(() => '(name LIKE ? OR details LIKE ? OR tags_json LIKE ?)')
          .join(' OR ');

        relaxedClauses.push(`(${keywordConditions})`);
        for (const kw of criteria.keywords.slice(0, 3)) {
          const pattern = `%${kw}%`;
          relaxedParams.push(pattern, pattern, pattern);
        }
      }

      const fallbackSql = `
        SELECT * FROM packages
        WHERE ${relaxedClauses.join(' AND ')}
        ORDER BY is_popular DESC, price ASC
        LIMIT 5;
      `;

      const fallbackRes = await c.env.DB.prepare(fallbackSql).bind(...relaxedParams).all<PackageRow>();
      results = fallbackRes.results;
    }

    // Ultimate fallback if still empty: return top popular packages
    if (!results || results.length === 0) {
      const topSql = `
        SELECT * FROM packages
        WHERE is_active = 1
        ORDER BY is_popular DESC, is_featured DESC
        LIMIT 4;
      `;
      const topRes = await c.env.DB.prepare(topSql).all<PackageRow>();
      results = topRes.results;
    }

    const suggestedPackages: PackageResponse[] = (results || []).map(formatPackage);

    let answer: string = '';

    // Check if Cloudflare Workers AI binding is available
    if (c.env.AI && typeof c.env.AI.run === 'function') {
      try {
        const packageContext = suggestedPackages
          .map(
            (p, idx) =>
              `${idx + 1}. [${p.networkId.toUpperCase()}] ${p.name}: Rs. ${p.price}, ${p.validityDays} Days, Dial ${p.activationCode}. Details: ${p.details}`
          )
          .join('\n');

        const systemPrompt = `You are an expert, friendly telecom consultant for Pakistani mobile networks (Jazz, Zong, Telenor, Ufone).
Answer the user's question concisely in 2 to 3 sentences maximum.
Recommend the most suitable package from the provided options, stating its exact name, network, price (Rs.), and dial activation code.
Do not invent packages not present in the options list.`;

        const userPrompt = `User question: "${userQuery}"\n\nAvailable packages:\n${packageContext}\n\nWhat is your recommendation?`;

        const aiResponse = await c.env.AI.run('@cf/meta/llama-3.1-8b-instruct', {
          messages: [
            { role: 'system', content: systemPrompt },
            { role: 'user', content: userPrompt },
          ],
          max_tokens: 256,
        });

        if (aiResponse && (aiResponse.response || aiResponse.content)) {
          answer = String(aiResponse.response || aiResponse.content).trim();
        }
      } catch (aiError) {
        console.warn('Workers AI execution skipped or encountered an issue:', aiError);
      }
    }

    // If answer not set by Workers AI, use smart structured advice
    if (!answer) {
      answer = generateStructuredAdvice(userQuery, suggestedPackages);
    }

    return c.json({
      success: true,
      query: userQuery,
      detectedCriteria: {
        network: criteria.network || null,
        category: criteria.category || null,
        validity: criteria.validity || null,
        maxPrice: criteria.maxPrice || null,
      },
      answer,
      suggestedPackages,
    });
  } catch (error: any) {
    return c.json(
      {
        success: false,
        error: error?.message || 'Failed to process AI package recommendation',
      },
      500
    );
  }
});
