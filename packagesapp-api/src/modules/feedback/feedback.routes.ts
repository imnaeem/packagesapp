import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { validate } from '../../middleware/validate.middleware';
import { optionalAuth, AuthenticatedRequest } from '../../middleware/auth.middleware';
import * as feedbackService from './feedback.service';

const feedbackSchema = z.object({
  message: z.string().min(10, 'Message must be at least 10 characters'),
  email: z.string().email('Valid email required'),
  name: z.string().optional(),
});

const router = Router();

router.post(
  '/',
  optionalAuth,
  validate(feedbackSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const authReq = req as AuthenticatedRequest;
      await feedbackService.submitFeedback({
        message: req.body.message,
        email: req.body.email,
        name: req.body.name,
        uid: authReq.user?.uid,
      });
      res.status(201).json({ success: true, message: 'Feedback submitted. Thank you!' });
    } catch (err) {
      next(err);
    }
  }
);

export default router;
