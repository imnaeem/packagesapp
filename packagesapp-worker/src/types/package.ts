export type PackageCategory = 'call' | 'sms' | 'internet' | 'hybrid' | 'social' | 'gaming';
export type PackageSubCategory = 'daily' | 'weekly' | 'monthly' | 'yearly' | 'custom';
export type ValidityType = 'daily' | 'weekly' | 'monthly' | 'yearly' | 'other';

export interface ResourceData {
  onNetMinutes?: number;
  offNetMinutes?: number;
  allNetMinutes?: number;
  sms?: number;
  dataMb?: number;
  dataGb?: number;
  dataTimeWindow?: string;
  dataPeakMb?: number;
  dataOffPeakMb?: number;
  socialMb?: number;
  socialApps?: string[];
}

export interface AddonData {
  name: string;
  value: string;
  unit: string;
}

export interface PackageRow {
  id: string;
  network_id: string;
  name: string;
  category: string;
  sub_category: string;
  price: number;
  recharge_required: number;
  validity_days: number;
  validity_hours: number;
  validity_type: string;
  activation_code: string;
  deactivation_code: string;
  resources_json: string | null;
  addons_json: string | null;
  extra_services_json: string | null;
  details: string | null;
  tags_json: string | null;
  is_active: number;
  is_featured: number;
  is_popular: number;
  is_special_offer: number;
  created_at: string;
  updated_at: string;
}

export interface PackageResponse {
  id: string;
  networkId: string;
  name: string;
  category: string;
  subCategory: string;
  price: number;
  rechargeRequired: number;
  validityDays: number;
  validityHours: number;
  validityType: string;
  activationCode: string;
  deactivationCode: string;
  resources: ResourceData;
  addons: AddonData[];
  extraServices: string[];
  details: string;
  tags: string[];
  isActive: boolean;
  isFeatured: boolean;
  isPopular: boolean;
  isSpecialOffer: boolean;
  createdAt: string;
  updatedAt: string;
}
