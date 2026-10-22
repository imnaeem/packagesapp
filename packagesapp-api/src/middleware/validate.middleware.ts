import { Request, Response, NextFunction } from 'express';
import { ZodSchema } from 'zod';

// Extend Express Request to carry validated data
declare global {
  namespace Express {
    interface Request {
      validated?: Record<string, unknown>;
    }
  }
}

export function validate(schema: ZodSchema, source: 'body' | 'query' | 'params' = 'body') {
  return (req: Request, res: Response, next: NextFunction): void => {
    const result = schema.safeParse(req[source]);
    if (!result.success) {
      res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: result.error.flatten().fieldErrors,
      });
      return;
    }
    // Store on req.validated instead of mutating req.query (read-only in Express 5)
    req.validated = result.data as Record<string, unknown>;
    next();
  };
}
