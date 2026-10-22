import { z } from 'zod';

export const resourceSchema = z.object({
  onNetMinutes: z.number().int().nonnegative().optional(),
  offNetMinutes: z.number().int().nonnegative().optional(),
  sms: z.number().int().nonnegative().optional(),
  dataMb: z.number().int().nonnegative().optional(),
  dataGb: z.number().nonnegative().optional(),
});

export const addonSchema = z.object({
  name: z.string().min(1),
  value: z.string().min(1),
  unit: z.string().min(1),
});

export const createPackageSchema = z.object({
  networkId: z.string().min(1, 'networkId is required'),
  name: z.string().min(1, 'name is required').max(200),
  category: z.enum(['call', 'sms', 'internet', 'hybrid', 'social', 'gaming']),
  subCategory: z.enum(['daily', 'weekly', 'monthly', 'yearly', 'custom']),
  price: z.number().nonnegative(),
  validityDays: z.number().int().nonnegative(),
  activationCode: z.string().default(''),
  deactivationCode: z.string().default(''),
  resources: resourceSchema.default({}),
  addons: z.array(addonSchema).default([]),
  extraServices: z.array(z.string()).default([]),
  details: z.string().default(''),
  tags: z.array(z.string()).default([]),
  isActive: z.boolean().default(true),
  isFeatured: z.boolean().default(false),
});

export const updatePackageSchema = createPackageSchema.partial();

export const packageQuerySchema = z.object({
  networkId: z.string().optional(),
  category: z.enum(['all', 'call', 'sms', 'internet', 'hybrid', 'social', 'gaming']).optional(),
  subCategory: z.enum(['daily', 'weekly', 'monthly', 'yearly', 'custom']).optional(),
  sort: z.enum(['price', 'validityDays', 'name', 'createdAt']).optional().default('createdAt'),
  order: z.enum(['asc', 'desc']).optional().default('asc'),
  isFeatured: z.string().optional(),
  limit: z.string().optional(),
  page: z.string().optional(),
});

export type CreatePackageDto = z.infer<typeof createPackageSchema>;
export type UpdatePackageDto = z.infer<typeof updatePackageSchema>;
export type PackageQuery = z.infer<typeof packageQuerySchema>;
