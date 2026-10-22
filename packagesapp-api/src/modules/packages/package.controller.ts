import { Request, Response, NextFunction } from 'express';
import * as packageService from './package.service';
import { PackageQuery } from './package.schema';

export async function getPackages(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const query = req.query as unknown as PackageQuery;
    const packages = await packageService.getAllPackages(query);
    res.json({ success: true, data: packages, count: packages.length });
  } catch (err) {
    next(err);
  }
}

export async function getPackage(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const pkg = await packageService.getPackageById(req.params.id as string);
    res.json({ success: true, data: pkg });
  } catch (err) {
    next(err);
  }
}

export async function createPackage(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const pkg = await packageService.createPackage(req.body);
    res.status(201).json({ success: true, data: pkg });
  } catch (err) {
    next(err);
  }
}

export async function updatePackage(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const pkg = await packageService.updatePackage(req.params.id as string, req.body);
    res.json({ success: true, data: pkg });
  } catch (err) {
    next(err);
  }
}

export async function deletePackage(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    await packageService.deletePackage(req.params.id as string);
    res.json({ success: true, message: 'Package deleted' });
  } catch (err) {
    next(err);
  }
}
