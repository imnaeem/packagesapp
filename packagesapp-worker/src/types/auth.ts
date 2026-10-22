export interface UserRow {
  id: string;
  email: string;
  password_hash: string | null;
  display_name: string | null;
  photo_url: string | null;
  auth_provider: string; // 'local' | 'google'
  created_at: string;
  last_login_at: string;
}

export interface UserProfile {
  id: string;
  email: string;
  displayName: string;
  photoUrl: string;
  authProvider: string;
  createdAt?: string;
  lastLoginAt?: string;
}

export interface AuthResponse {
  user: UserProfile;
  token: string;
}
