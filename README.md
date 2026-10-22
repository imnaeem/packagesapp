# PK Packages - Pakistan Network Packages & Offers

A comprehensive multi-network mobile application and 100% free Cloudflare serverless backend for browsing, comparing, and managing telecom packages across all major cellular networks in Pakistan (Jazz, Zong, Telenor, Ufone, and Warid).

🔗 **GitHub Repository**: [https://github.com/imnaeem/packagesapp](https://github.com/imnaeem/packagesapp)

---

## 📁 Repository Structure

```
.
├── packagesapp/            # Flutter mobile application (Android, iOS, Web)
├── packagesapp-worker/     # Cloudflare Worker API + Cloudflare D1 SQL Backend (100% Free Tier)
├── packagesapp-api/        # Original Node.js / Express API and scrapers
└── README.md               # Project documentation
```

---

## 📱 1. Flutter Mobile App (`packagesapp/`)

### Key Features
* **Full Offline Support**: Bundled seed database in `assets/data/bundled_packages.json` with automatic Hive local caching. Functions seamlessly even without an internet connection.
* **Dual SIM Auto-Detection**: Detects active SIMs on device (e.g. Jazz, Zong) and highlights relevant packages.
* **3D Layered Infinite Carousel**: Interactive, animated cards highlighting featured and popular packages.
* **Free Tricks & Deals (Rs. 0)**: Dedicated filter and banners for 100% free network offers, SIM Lagao offers, and zero-balance social packages.
* **WordPress Blog Reader**: Live integration with `techshiner.com` via WP REST API with built-in offline cached fallback articles.
* **Dynamic Theme Accent Switcher**: Live user-selectable theme colors (Teal, Indigo Blue, Emerald Green, Purple, Sunset Orange) in Drawer and Settings.
* **Smart Compare Tool**: Side-by-side comparison of data, on-net/off-net minutes, SMS, and validity.
* **AI Package Finder / Filter**: Filter by exact budget, data needs, and calling requirements.
* **Responsive Layout**: Widened 88px price tags with `FittedBox` supporting 4-digit pricing without wrapping, horizontal scrolling activation buttons, and zero overflow errors across small/standard screens.
* **One-Tap Direct Dial**: USSD activation and status check dialing via native Android phone intent.

---

## ⚡ 2. Cloudflare Worker API (`packagesapp-worker/`)

A high-performance serverless backend built with [Hono](https://hono.dev/) on Cloudflare Workers and Cloudflare D1 (Serverless SQLite), engineered strictly within Cloudflare's **100% Free Tier** (100,000 requests/day, 5M D1 reads/day).

### Features
* **Zero-Cost Auth**: Web Crypto PBKDF2 with SHA-256 password hashing + salt, 30-day JWT issuing and verification, and Google ID token claims decoder.
* **User Favorites & Sync**: `GET /api/v1/favourites`, `POST /api/v1/favourites/:id`, `DELETE /api/v1/favourites/:id`, and batch sync `POST /api/v1/favourites/sync` between offline guest storage and user accounts.
* **Smart Ingestion (Upsert)**: `POST /api/v1/packages/ingest` handles bulk package updates with zero duplicates using network-scoped compound keys.
* **Workers AI Engine**: `POST /api/v1/ai/recommend` powered by `@cf/meta/llama-3.1-8b-instruct` on Cloudflare's free Workers AI tier with deterministic offline-friendly fallback.
* **Techshiner Feedback & Contact**: Persisted in D1 database with Resend / SMTP email delivery hooks.
* **Test Suite**: Fully automated integration tests (`test_worker_endpoints.mjs`) with 30/30 tests passing.

---

## 🚀 3. Node.js API (`packagesapp-api/`)

The original Node.js / Express backend containing data models, network endpoints, validation middleware, and legacy seeding scripts.

---

## 🛠️ Quick Start

### Flutter Mobile App
```bash
cd packagesapp
flutter pub get
flutter run
```

### Cloudflare Worker
```bash
cd packagesapp-worker
npm install
npm run dev        # Local development on localhost:8787
npm run test       # Run 30/30 endpoint test suite
npm run deploy     # Deploy to Cloudflare Workers
```

---

## 📄 License
MIT License. Maintained by [imnaeem](https://github.com/imnaeem).
