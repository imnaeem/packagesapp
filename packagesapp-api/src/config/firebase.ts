import * as admin from 'firebase-admin';
import { env } from './env';

let _db: admin.firestore.Firestore;
let _auth: admin.auth.Auth;

export function initFirebase(): void {
  if (admin.apps.length > 0) return;

  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: env.FIREBASE_PROJECT_ID,
      clientEmail: env.FIREBASE_CLIENT_EMAIL,
      privateKey: env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    }),
  });

  _db = admin.firestore();
  _auth = admin.auth();

  console.log('✅ Firebase Admin SDK initialized');
}

export function getDb(): admin.firestore.Firestore {
  if (!_db) throw new Error('Firebase not initialized. Call initFirebase() first.');
  return _db;
}

export function getAuth(): admin.auth.Auth {
  if (!_auth) throw new Error('Firebase not initialized. Call initFirebase() first.');
  return _auth;
}

export { admin };
