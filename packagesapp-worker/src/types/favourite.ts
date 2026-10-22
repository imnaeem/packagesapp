import { PackageResponse } from './package';

export interface UserFavouriteRow {
  id: string;
  user_id: string;
  package_id: string;
  network_id: string;
  created_at: string;
}

export interface UserFavouriteItem {
  id: string;
  packageId: string;
  networkId: string;
  createdAt: string;
  package?: PackageResponse | null;
}
