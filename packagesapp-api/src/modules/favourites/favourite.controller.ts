import { Response, NextFunction } from 'express';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import * as favouriteService from './favourite.service';

export async function getFavourites(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const favourites = await favouriteService.getUserFavourites(req.user!.uid);
    res.json({ success: true, data: favourites });
  } catch (err) {
    next(err);
  }
}

export async function addFavourite(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const packageId = req.params.packageId as string;
    const { networkId } = req.body;
    await favouriteService.addFavourite(req.user!.uid, packageId, networkId ?? '');
    res.status(201).json({ success: true, message: 'Added to favourites' });
  } catch (err) {
    next(err);
  }
}

export async function removeFavourite(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    await favouriteService.removeFavourite(req.user!.uid, req.params.packageId as string);
    res.json({ success: true, message: 'Removed from favourites' });
  } catch (err) {
    next(err);
  }
}

export async function syncFavourites(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { favourites } = req.body;
    await favouriteService.syncFavourites(req.user!.uid, favourites ?? []);
    res.json({ success: true, message: 'Favourites synced' });
  } catch (err) {
    next(err);
  }
}
