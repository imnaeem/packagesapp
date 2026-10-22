import { getDb, admin } from '../../config/firebase';
import { AppError } from '../../middleware/error.middleware';

const USERS_COLLECTION = 'users';
const FAVOURITES_SUBCOLLECTION = 'favourites';

export interface Favourite {
  packageId: string;
  networkId: string;
  addedAt: string;
}

export async function getUserFavourites(uid: string): Promise<Favourite[]> {
  const db = getDb();
  const snapshot = await db
    .collection(USERS_COLLECTION)
    .doc(uid)
    .collection(FAVOURITES_SUBCOLLECTION)
    .orderBy('addedAt', 'desc')
    .get();

  return snapshot.docs.map((doc) => {
    const data = doc.data();
    return {
      packageId: doc.id,
      networkId: data.networkId,
      addedAt:
        data.addedAt instanceof admin.firestore.Timestamp
          ? data.addedAt.toDate().toISOString()
          : data.addedAt,
    };
  });
}

export async function addFavourite(uid: string, packageId: string, networkId: string): Promise<void> {
  const db = getDb();
  await db
    .collection(USERS_COLLECTION)
    .doc(uid)
    .collection(FAVOURITES_SUBCOLLECTION)
    .doc(packageId)
    .set({
      networkId,
      addedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}

export async function removeFavourite(uid: string, packageId: string): Promise<void> {
  const db = getDb();
  const ref = db
    .collection(USERS_COLLECTION)
    .doc(uid)
    .collection(FAVOURITES_SUBCOLLECTION)
    .doc(packageId);

  const doc = await ref.get();
  if (!doc.exists) throw new AppError('Favourite not found', 404);
  await ref.delete();
}

export async function syncFavourites(uid: string, favourites: Favourite[]): Promise<void> {
  const db = getDb();
  const colRef = db
    .collection(USERS_COLLECTION)
    .doc(uid)
    .collection(FAVOURITES_SUBCOLLECTION);

  const batch = db.batch();
  for (const fav of favourites) {
    const ref = colRef.doc(fav.packageId);
    batch.set(ref, {
      networkId: fav.networkId,
      addedAt: fav.addedAt ?? admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
}
