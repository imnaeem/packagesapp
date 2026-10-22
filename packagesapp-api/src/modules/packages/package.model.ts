export interface Resource {
  onNetMinutes?: number;
  offNetMinutes?: number;
  sms?: number;
  dataMb?: number;
  dataGb?: number;
}

export interface Addon {
  name: string;
  value: string;
  unit: string;
}

export type PackageCategory = 'call' | 'sms' | 'internet' | 'hybrid' | 'social' | 'gaming';
export type PackageSubCategory = 'daily' | 'weekly' | 'monthly' | 'yearly' | 'custom';

export interface Package {
  id: string;
  networkId: string;
  name: string;
  category: PackageCategory;
  subCategory: PackageSubCategory;
  price: number;
  validityDays: number;
  activationCode: string;
  deactivationCode: string;
  resources: Resource;
  addons: Addon[];
  extraServices: string[];
  details: string;
  tags: string[];
  isActive: boolean;
  isFeatured: boolean;
  createdAt: FirebaseFirestore.Timestamp | string;
  updatedAt: FirebaseFirestore.Timestamp | string;
}

export type CreatePackageDto = Omit<Package, 'id' | 'createdAt' | 'updatedAt'>;
export type UpdatePackageDto = Partial<CreatePackageDto>;
