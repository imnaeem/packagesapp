import { getDb, admin } from '../../config/firebase';
import { AppError } from '../../middleware/error.middleware';
import { CreatePackageDto, UpdatePackageDto, PackageQuery } from './package.schema';
import { Package } from './package.model';

const COLLECTION = 'packages';

function serializePackage(
  id: string,
  data: FirebaseFirestore.DocumentData
): Package {
  return {
    id,
    ...data,
    createdAt:
      data.createdAt instanceof admin.firestore.Timestamp
        ? data.createdAt.toDate().toISOString()
        : data.createdAt,
    updatedAt:
      data.updatedAt instanceof admin.firestore.Timestamp
        ? data.updatedAt.toDate().toISOString()
        : data.updatedAt,
  } as Package;
}

export async function getAllPackages(query: PackageQuery): Promise<Package[]> {
  const db = getDb();

  // Only filter by isActive in Firestore to avoid composite index requirements.
  // All other filters are applied in-memory.
  const snapshot = await db
    .collection(COLLECTION)
    .where('isActive', '==', true)
    .get();

  let packages = snapshot.docs.map((doc) => serializePackage(doc.id, doc.data()));

  if (query.networkId) {
    packages = packages.filter((p) => p.networkId === query.networkId);
  }
  if (query.category && query.category !== 'all') {
    packages = packages.filter((p) => p.category === query.category);
  }
  if (query.subCategory) {
    packages = packages.filter((p) => p.subCategory === query.subCategory);
  }
  if (query.isFeatured === 'true') {
    packages = packages.filter((p) => p.isFeatured);
  }

  // Sort in memory
  const sortField = (query.sort ?? 'createdAt') as keyof Package;
  const sortOrder = query.order ?? 'asc';
  packages.sort((a, b) => {
    const av = a[sortField] as string | number;
    const bv = b[sortField] as string | number;
    if (av < bv) return sortOrder === 'asc' ? -1 : 1;
    if (av > bv) return sortOrder === 'asc' ? 1 : -1;
    return 0;
  });

  const limit = query.limit ? parseInt(query.limit, 10) : 200;
  return packages.slice(0, Math.min(limit, 200));
}

export async function getPackageById(id: string): Promise<Package> {
  const db = getDb();
  const doc = await db.collection(COLLECTION).doc(id).get();

  if (!doc.exists) {
    throw new AppError('Package not found', 404);
  }

  return serializePackage(doc.id, doc.data()!);
}

export async function createPackage(dto: CreatePackageDto): Promise<Package> {
  const db = getDb();
  const now = admin.firestore.FieldValue.serverTimestamp();

  const docRef = await db.collection(COLLECTION).add({
    ...dto,
    createdAt: now,
    updatedAt: now,
  });

  const doc = await docRef.get();
  return serializePackage(doc.id, doc.data()!);
}

export async function updatePackage(
  id: string,
  dto: UpdatePackageDto
): Promise<Package> {
  const db = getDb();
  const ref = db.collection(COLLECTION).doc(id);
  const existing = await ref.get();

  if (!existing.exists) {
    throw new AppError('Package not found', 404);
  }

  await ref.update({
    ...dto,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  const updated = await ref.get();
  return serializePackage(updated.id, updated.data()!);
}

export async function deletePackage(id: string): Promise<void> {
  const db = getDb();
  const ref = db.collection(COLLECTION).doc(id);
  const existing = await ref.get();

  if (!existing.exists) {
    throw new AppError('Package not found', 404);
  }

  await ref.delete();
}
