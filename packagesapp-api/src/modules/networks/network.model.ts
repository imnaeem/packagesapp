export interface Network {
  id: string;
  name: string;
  slug: string;
  slogan: string;
  logoUrl: string;
  brandColor: string;
  isActive: boolean;
  packageCount?: number;
  createdAt?: string;
}

export type CreateNetworkDto = Omit<Network, 'id' | 'createdAt'>;
