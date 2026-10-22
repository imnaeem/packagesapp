import { Request, Response, NextFunction } from 'express';
import * as networkService from './network.service';

export async function getNetworks(
  _req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const networks = await networkService.getAllNetworks();
    res.json({ success: true, data: networks });
  } catch (err) {
    next(err);
  }
}

export async function getNetwork(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const network = await networkService.getNetworkById(req.params.id as string);
    res.json({ success: true, data: network });
  } catch (err) {
    next(err);
  }
}

export async function createNetwork(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const network = await networkService.createNetwork(req.body);
    res.status(201).json({ success: true, data: network });
  } catch (err) {
    next(err);
  }
}

export async function seedNetworks(
  _req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    await networkService.seedNetworks();
    res.json({ success: true, message: 'Networks seeded' });
  } catch (err) {
    next(err);
  }
}
