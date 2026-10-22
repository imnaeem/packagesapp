-- Cloudflare D1 Database Schema for packagesapp-worker
-- Supports SQLite on Cloudflare D1 Serverless Edge

PRAGMA foreign_keys = ON;

-- 1. Networks Table
CREATE TABLE IF NOT EXISTS networks (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    slogan TEXT,
    logo_url TEXT,
    brand_color TEXT NOT NULL,
    is_active INTEGER DEFAULT 1,
    package_count INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_networks_slug ON networks(slug);
CREATE INDEX IF NOT EXISTS idx_networks_is_active ON networks(is_active);

-- 2. Packages Table
CREATE TABLE IF NOT EXISTS packages (
    id TEXT PRIMARY KEY,
    network_id TEXT NOT NULL,
    name TEXT NOT NULL,
    category TEXT NOT NULL, -- 'call' | 'sms' | 'internet' | 'hybrid' | 'social' | 'gaming'
    sub_category TEXT NOT NULL, -- 'daily' | 'weekly' | 'monthly' | 'yearly' | 'custom'
    price REAL NOT NULL,
    recharge_required REAL DEFAULT 0,
    validity_days INTEGER NOT NULL,
    validity_hours INTEGER DEFAULT 0,
    validity_type TEXT DEFAULT '', -- 'daily' | 'weekly' | 'monthly' | 'other'
    activation_code TEXT NOT NULL,
    deactivation_code TEXT DEFAULT '',
    resources_json TEXT, -- JSON: { onNetMinutes, offNetMinutes, allNetMinutes, sms, dataMb, dataGb, dataTimeWindow, dataPeakMb, dataOffPeakMb, socialMb, socialApps }
    addons_json TEXT, -- JSON: Array<{ name: string, value: string, unit: string }>
    extra_services_json TEXT, -- JSON: Array<string>
    details TEXT,
    tags_json TEXT, -- JSON: Array<string>
    is_active INTEGER DEFAULT 1,
    is_featured INTEGER DEFAULT 0,
    is_popular INTEGER DEFAULT 0,
    is_special_offer INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (network_id) REFERENCES networks(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_packages_network_id ON packages(network_id);
CREATE INDEX IF NOT EXISTS idx_packages_category ON packages(category);
CREATE INDEX IF NOT EXISTS idx_packages_sub_category ON packages(sub_category);
CREATE INDEX IF NOT EXISTS idx_packages_is_active ON packages(is_active);
CREATE INDEX IF NOT EXISTS idx_packages_is_featured ON packages(is_featured);
CREATE INDEX IF NOT EXISTS idx_packages_is_popular ON packages(is_popular);
CREATE INDEX IF NOT EXISTS idx_packages_network_activation ON packages(network_id, activation_code);
CREATE INDEX IF NOT EXISTS idx_packages_network_name ON packages(network_id, name);

-- 3. Users Table (100% Free Edge Auth)
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT,
    display_name TEXT,
    photo_url TEXT,
    auth_provider TEXT DEFAULT 'local', -- 'local' | 'google'
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    last_login_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_auth_provider ON users(auth_provider);

-- 4. User Favourites Table
CREATE TABLE IF NOT EXISTS user_favourites (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    package_id TEXT NOT NULL,
    network_id TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, package_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_user_favourites_user_id ON user_favourites(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favourites_package_id ON user_favourites(package_id);
CREATE INDEX IF NOT EXISTS idx_user_favourites_network_id ON user_favourites(network_id);

-- 5. Feedback and Contact Table
CREATE TABLE IF NOT EXISTS feedback (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    name TEXT,
    email TEXT NOT NULL DEFAULT '',
    subject TEXT,
    rating INTEGER DEFAULT 5,
    category TEXT DEFAULT 'general',
    message TEXT NOT NULL,
    type TEXT DEFAULT 'feedback', -- 'feedback' | 'contact' | 'inquiry' | 'bug'
    status TEXT DEFAULT 'pending', -- 'pending' | 'reviewed' | 'resolved'
    device_info TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_feedback_created_at ON feedback(created_at);
CREATE INDEX IF NOT EXISTS idx_feedback_email ON feedback(email);
CREATE INDEX IF NOT EXISTS idx_feedback_type ON feedback(type);
CREATE INDEX IF NOT EXISTS idx_feedback_status ON feedback(status);
