import { Router, Response, NextFunction } from 'express';
import { authenticate, AuthenticatedRequest } from '../../middleware/auth.middleware';
import * as authService from './auth.service';

const router = Router();

router.post('/profile', authenticate, async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const profile = await authService.syncProfile(req.user!.uid, {
      displayName: req.body.displayName,
      email: req.body.email ?? req.user!.email,
      photoUrl: req.body.photoUrl,
      theme: req.body.theme,
    });
    res.json({ success: true, data: profile });
  } catch (err) {
    next(err);
  }
});

export default router;
