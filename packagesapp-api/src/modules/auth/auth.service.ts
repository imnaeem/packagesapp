import { getDb, admin } from '../../config/firebase';

const USERS_COLLECTION = 'users';

export interface UserProfile {
  uid: string;
  displayName: string;
  email: string;
  photoUrl?: string;
  theme: string;
  createdAt: string;
  updatedAt: string;
}

export async function syncProfile(
  uid: string,
  profile: Partial<UserProfile>
): Promise<UserProfile> {
  const db = getDb();
  const ref = db.collection(USERS_COLLECTION).doc(uid);
  const now = admin.firestore.FieldValue.serverTimestamp();
  const doc = await ref.get();

  if (!doc.exists) {
    await ref.set({
      ...profile,
      uid,
      createdAt: now,
      updatedAt: now,
    });
  } else {
    await ref.update({
      ...profile,
      updatedAt: now,
    });
  }

  const updated = await ref.get();
  const data = updated.data()!;
  return {
    uid: updated.id,
    displayName: data.displayName ?? '',
    email: data.email ?? '',
    photoUrl: data.photoUrl,
    theme: data.theme ?? 'system',
    createdAt:
      data.createdAt instanceof admin.firestore.Timestamp
        ? data.createdAt.toDate().toISOString()
        : data.createdAt ?? '',
    updatedAt:
      data.updatedAt instanceof admin.firestore.Timestamp
        ? data.updatedAt.toDate().toISOString()
        : data.updatedAt ?? '',
  };
}
