# PackagesApp Cloudflare Worker API

A modern, high-performance, 100% free Cloudflare Worker API built with **Hono**, **TypeScript**, and **Cloudflare D1 (Serverless SQLite)** for Pakistan Mobile Network Packages (Jazz, Zong, Telenor, Ufone, and PTCL).

---

## ⚡ Tech Stack & Features

- **Runtime:** Cloudflare Workers (Globally distributed edge compute, zero cold starts, generous 100k requests/day free tier).
- **Framework:** [Hono v4](https://hono.dev/) with TypeScript for ultra-low latency (<10ms edge response).
- **Database:** Cloudflare D1 (Serverless SQLite at the edge, 5GB storage free tier).
- **Validation:** [Zod v3](https://zod.dev/) for strict schema validation, versatile inputs, and safe non-null client fallbacks.
- **Smart Upsert:** Ingestion endpoint intelligently checks existing packages by `(network_id, activation_code)` or `(network_id, name)` and updates them in place or inserts new ones.
- **Edge Caching:** HTTP Cache-Control headers (`public, max-age=3600, stale-while-revalidate=86400`) for blazing-fast cached responses.

---

## 📁 Project Structure

```
packagesapp-worker/
├── schema.sql              # D1 SQL Schema (networks, packages, feedback)
├── seed.sql                # Comprehensive seed data (5 networks + 33 packages)
├── wrangler.jsonc          # Cloudflare Wrangler configuration
├── package.json            # Scripts & dependencies
├── tsconfig.json           # TypeScript configuration
└── src/
    ├── index.ts            # Hono application root & global middlewares (CORS, Logger, Errors)
    ├── types/
    │   ├── env.ts          # Worker bindings (DB, INGEST_API_KEY, ENVIRONMENT)
    │   ├── network.ts      # Network interfaces
    │   ├── package.ts      # Package interfaces (resources, addons, flags)
    │   └── feedback.ts     # Feedback interfaces
    ├── schemas/
    │   ├── package.schema.ts   # Zod validation schemas with smart normalization
    │   └── feedback.schema.ts  # Zod validation schemas for feedback
    ├── middleware/
    │   └── auth.ts         # Bearer and X-API-KEY authentication for ingestion
    ├── routes/
    │   ├── health.ts       # GET /health
    │   ├── networks.ts     # GET /api/v1/networks
    │   ├── packages.ts     # GET /api/v1/packages, GET /api/v1/packages/:id, POST /ingest
    │   └── feedback.ts     # POST /api/v1/feedback
    └── utils/
        └── formatter.ts    # Database row formatting to non-null camelCase objects
```

---

## 🚀 Getting Started

### 1. Install Dependencies
```bash
npm install
```

### 2. Initialize Local D1 Database
```bash
npm run db:init
npm run db:seed
```

### 3. Start Local Development Server
```bash
npm run dev
```
The server will start at `http://127.0.0.1:8787`.

### 4. Deploy to Cloudflare (Free)
1. Login to Cloudflare:
   ```bash
   npx wrangler login
   ```
2. Create your remote D1 database:
   ```bash
   npx wrangler d1 create packagesapp-db
   ```
   (Update `database_id` in `wrangler.jsonc` with the generated ID)
3. Initialize and seed remote D1:
   ```bash
   npm run db:init:remote
   npm run db:seed:remote
   ```
4. Deploy the worker:
   ```bash
   npm run deploy
   ```

---

## 🌐 API Endpoints Reference

### 1. Health Check
- **Endpoint:** `GET /health`
- **Response:**
```json
{
  "status": "healthy",
  "timestamp": "2026-10-22T18:55:43.649Z",
  "environment": "development",
  "version": "1.0.0"
}
```

---

### 2. Networks
- **Endpoint:** `GET /api/v1/networks`
- **Cache Header:** `public, max-age=3600, stale-while-revalidate=86400`
- **Response:**
```json
{
  "success": true,
  "count": 5,
  "data": [
    {
      "id": "jazz",
      "name": "Jazz",
      "slug": "jazz",
      "slogan": "Pakistan Ka Dil",
      "logoUrl": "assets/images/jazz.png",
      "brandColor": "#E31837",
      "isActive": true,
      "packageCount": 8,
      "createdAt": "2026-10-22 18:50:16"
    }
  ]
}
```

---

### 3. Packages List
- **Endpoint:** `GET /api/v1/packages`
- **Query Parameters:**
  - `networkId`: Filter by network (`jazz`, `zong`, `telenor`, `ufone`, `ptcl`)
  - `category`: Filter by category (`call`, `sms`, `internet`, `hybrid`, `social`, `gaming`)
  - `subCategory`: Filter by duration (`daily`, `weekly`, `monthly`, `yearly`, `custom`)
  - `isFeatured`: `true` | `false`
  - `isPopular`: `true` | `false`
  - `search`: Searches across name, details, activation code, and tags
  - `sort`: `price` | `validity` | `name` | `popular` | `created`
  - `order`: `asc` | `desc` (default: `asc`)
  - `limit`: Number of results (default: `50`, max: `200`)
  - `offset`: Pagination offset (default: `0`)
- **Cache Header:** `public, max-age=3600, stale-while-revalidate=86400`

---

### 4. Single Package
- **Endpoint:** `GET /api/v1/packages/:id`
- **Example:** `GET /api/v1/packages/jazz_weekly_super_duper`
- **Response:** Returns single package object with full rich resources.

---

### 5. Smart Ingestion (Protected)
- **Endpoint:** `POST /api/v1/packages/ingest`
- **Headers:**
  - `Authorization: Bearer <INGEST_API_KEY>` OR `X-API-KEY: <INGEST_API_KEY>`
  - Default dev key: `pk_dev_ingest_secret_2026`
- **Payload:** Accepts either a single package object or an array of package objects:
```json
[
  {
    "networkId": "jazz",
    "name": "Jazz Weekly Super Duper",
    "category": "hybrid",
    "subCategory": "weekly",
    "price": 415.0,
    "rechargeRequired": 480.0,
    "validityDays": 7,
    "validityHours": 168,
    "validityType": "weekly",
    "activationCode": "*770#",
    "deactivationCode": "*770*4#",
    "resources": {
      "onNetMinutes": 3000,
      "offNetMinutes": 100,
      "allNetMinutes": 3100,
      "sms": 3000,
      "dataMb": 8192,
      "dataGb": 8.0,
      "dataTimeWindow": "24 Hours",
      "dataPeakMb": 8192,
      "dataOffPeakMb": 0,
      "socialMb": 2048,
      "socialApps": ["whatsapp", "youtube"]
    },
    "addons": [
      { "name": "YouTube & WhatsApp", "value": "2", "unit": "GB" }
    ],
    "extraServices": ["Free WhatsApp", "Free Tamasha Access"],
    "details": "3000 Jazz minutes, 100 off-net minutes, 3000 SMS, 8 GB internet for 7 days.",
    "tags": ["weekly", "hybrid", "popular", "jazz"],
    "isActive": true,
    "isFeatured": true,
    "isPopular": true,
    "isSpecialOffer": false
  }
]
```
- **Response:**
```json
{
  "success": true,
  "inserted": 0,
  "updated": 1,
  "total": 1,
  "packages": [ ... ]
}
```

---

### 6. User Feedback
- **Endpoint:** `POST /api/v1/feedback`
- **Payload:**
```json
{
  "userId": "usr_12345",
  "rating": 5,
  "category": "feature_request",
  "message": "Add PTCL Flash Fiber 50Mbps package!",
  "deviceInfo": "Pixel 8 Pro, Android 15"
}
```
- **Response:**
```json
{
  "success": true,
  "message": "Feedback submitted successfully",
  "feedback": {
    "id": "e5eff261-f179-4805-9285-c3348445eaec",
    "userId": "usr_12345",
    "rating": 5,
    "category": "feature_request",
    "message": "Add PTCL Flash Fiber 50Mbps package!",
    "deviceInfo": "Pixel 8 Pro, Android 15",
    "createdAt": "2026-10-22T18:56:48.331Z"
  }
}
```
