export interface Env {
  DB: D1Database;
  AI?: any;
  JWT_SECRET?: string;
  INGEST_API_KEY?: string;
  RESEND_API_KEY?: string;
  SUPPORT_EMAIL?: string;
  INFO_EMAIL?: string;
  ENVIRONMENT?: string;
}
