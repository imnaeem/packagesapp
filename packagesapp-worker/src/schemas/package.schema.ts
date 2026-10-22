import { z } from 'zod';

export const ResourceSchema = z.object({
  onNetMinutes: z.number().int().min(0).default(0),
  offNetMinutes: z.number().int().min(0).default(0),
  allNetMinutes: z.number().int().min(0).default(0),
  sms: z.number().int().min(0).default(0),
  dataMb: z.number().min(0).default(0),
  dataGb: z.number().min(0).default(0),
  dataTimeWindow: z.string().default('24 Hours'),
  dataPeakMb: z.number().min(0).default(0),
  dataOffPeakMb: z.number().min(0).default(0),
  socialMb: z.number().min(0).default(0),
  socialApps: z.array(z.string()).default([]),
});

export const AddonSchema = z.object({
  name: z.string().min(1, 'Addon name cannot be empty'),
  value: z.string().default(''),
  unit: z.string().default(''),
});

// Normalizes input to camelCase and sets clean defaults
export const PackageInputSchema = z.preprocess((val: any) => {
  if (typeof val !== 'object' || val === null) return val;
  const copy = { ...val };

  // Map snake_case to camelCase if present
  if (copy.network_id && !copy.networkId) copy.networkId = copy.network_id;
  if (copy.sub_category && !copy.subCategory) copy.subCategory = copy.sub_category;
  if (copy.recharge_required !== undefined && copy.rechargeRequired === undefined) {
    copy.rechargeRequired = copy.recharge_required;
  }
  if (copy.validity_days !== undefined && copy.validityDays === undefined) {
    copy.validityDays = copy.validity_days;
  }
  if (copy.validity_hours !== undefined && copy.validityHours === undefined) {
    copy.validityHours = copy.validity_hours;
  }
  if (copy.validity_type && !copy.validityType) copy.validityType = copy.validity_type;
  if (copy.activation_code && !copy.activationCode) copy.activationCode = copy.activation_code;
  if (copy.deactivation_code !== undefined && copy.deactivationCode === undefined) {
    copy.deactivationCode = copy.deactivation_code;
  }
  if (copy.extra_services && !copy.extraServices) copy.extraServices = copy.extra_services;
  if (copy.is_active !== undefined && copy.isActive === undefined) copy.isActive = copy.is_active;
  if (copy.is_featured !== undefined && copy.isFeatured === undefined) copy.isFeatured = copy.is_featured;
  if (copy.is_popular !== undefined && copy.isPopular === undefined) copy.isPopular = copy.is_popular;
  if (copy.is_special_offer !== undefined && copy.isSpecialOffer === undefined) {
    copy.isSpecialOffer = copy.is_special_offer;
  }

  // Handle boolean conversions from 0/1 or 'true'/'false'
  if (typeof copy.isActive === 'number') copy.isActive = copy.isActive === 1;
  if (typeof copy.isFeatured === 'number') copy.isFeatured = copy.isFeatured === 1;
  if (typeof copy.isPopular === 'number') copy.isPopular = copy.isPopular === 1;
  if (typeof copy.isSpecialOffer === 'number') copy.isSpecialOffer = copy.isSpecialOffer === 1;

  return copy;
}, z.object({
  id: z.string().optional(),
  networkId: z.string().min(1, 'networkId is required'),
  name: z.string().min(1, 'name is required'),
  category: z.enum(['call', 'sms', 'internet', 'hybrid', 'social', 'gaming']).default('hybrid'),
  subCategory: z.enum(['daily', 'weekly', 'monthly', 'yearly', 'custom']).default('monthly'),
  price: z.number().min(0, 'price must be non-negative'),
  rechargeRequired: z.number().min(0).default(0),
  validityDays: z.number().int().min(0).default(30),
  validityHours: z.number().int().min(0).default(0),
  validityType: z.string().default(''),
  activationCode: z.string().min(1, 'activationCode is required'),
  deactivationCode: z.string().default(''),
  resources: ResourceSchema.default({}),
  addons: z.array(AddonSchema).default([]),
  extraServices: z.array(z.string()).default([]),
  details: z.string().default(''),
  tags: z.array(z.string()).default([]),
  isActive: z.boolean().default(true),
  isFeatured: z.boolean().default(false),
  isPopular: z.boolean().default(false),
  isSpecialOffer: z.boolean().default(false),
}));

export type PackageInput = z.infer<typeof PackageInputSchema>;

// Ingest accepts: a single package, an array of packages, or { packages: [...] }
export const IngestPayloadSchema = z.preprocess((val: any) => {
  if (Array.isArray(val)) {
    return { packages: val };
  }
  if (val && typeof val === 'object' && Array.isArray(val.packages)) {
    return val;
  }
  if (val && typeof val === 'object') {
    return { packages: [val] };
  }
  return { packages: [] };
}, z.object({
  packages: z.array(PackageInputSchema).min(1, 'At least one package is required for ingestion'),
}));

export type IngestPayload = z.infer<typeof IngestPayloadSchema>;
