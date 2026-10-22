export interface NetworkRow {
  id: string;
  name: string;
  slug: string;
  slogan: string | null;
  logo_url: string | null;
  brand_color: string;
  is_active: number;
  package_count: number;
  created_at: string;
}

export interface NetworkResponse {
  id: string;
  name: string;
  slug: string;
  slogan: string;
  logoUrl: string;
  brandColor: string;
  isActive: boolean;
  packageCount: number;
  createdAt: string;
}
