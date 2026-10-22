import { getDb, admin } from '../../config/firebase';
import { AppError } from '../../middleware/error.middleware';
import { Network, CreateNetworkDto } from './network.model';

const COLLECTION = 'networks';

const SEED_NETWORKS: Array<Omit<Network, 'id'>> = [
  {
    name: 'Jazz',
    slug: 'jazz',
    slogan: 'Pakistan Ka Dil',
    logoUrl: '',
    brandColor: '#E31837',
    isActive: true,
    packageCount: 0,
  },
  {
    name: 'Zong',
    slug: 'zong',
    slogan: 'First in 4G',
    logoUrl: '',
    brandColor: '#009BDE',
    isActive: true,
    packageCount: 0,
  },
  {
    name: 'Telenor',
    slug: 'telenor',
    slogan: 'Skandinavian Spirit',
    logoUrl: '',
    brandColor: '#00A0E3',
    isActive: true,
    packageCount: 0,
  },
  {
    name: 'Ufone',
    slug: 'ufone',
    slogan: 'Tum Hi Toh Ho',
    logoUrl: '',
    brandColor: '#00A650',
    isActive: true,
    packageCount: 0,
  },
  {
    name: 'PTCL',
    slug: 'ptcl',
    slogan: "It's All About You",
    logoUrl: '',
    brandColor: '#003087',
    isActive: true,
    packageCount: 0,
  },
];

function serializeNetwork(
  id: string,
  data: FirebaseFirestore.DocumentData
): Network {
  return {
    id,
    name: data.name,
    slug: data.slug,
    slogan: data.slogan,
    logoUrl: data.logoUrl ?? '',
    brandColor: data.brandColor,
    isActive: data.isActive ?? true,
    packageCount: data.packageCount ?? 0,
    createdAt:
      data.createdAt instanceof admin.firestore.Timestamp
        ? data.createdAt.toDate().toISOString()
        : data.createdAt,
  };
}

export async function getAllNetworks(): Promise<Network[]> {
  const db = getDb();
  const snapshot = await db
    .collection(COLLECTION)
    .where('isActive', '==', true)
    .get();
  return snapshot.docs.map((doc) => serializeNetwork(doc.id, doc.data()));
}

export async function getNetworkById(id: string): Promise<Network> {
  const db = getDb();
  const doc = await db.collection(COLLECTION).doc(id).get();
  if (!doc.exists) throw new AppError('Network not found', 404);
  return serializeNetwork(doc.id, doc.data()!);
}

export async function getNetworkBySlug(slug: string): Promise<Network | null> {
  const db = getDb();
  const snap = await db.collection(COLLECTION).where('slug', '==', slug).limit(1).get();
  if (snap.empty) return null;
  const doc = snap.docs[0];
  return serializeNetwork(doc.id, doc.data());
}

export async function createNetwork(dto: CreateNetworkDto): Promise<Network> {
  const db = getDb();
  const now = admin.firestore.FieldValue.serverTimestamp();
  const docRef = await db.collection(COLLECTION).add({ ...dto, createdAt: now });
  const doc = await docRef.get();
  return serializeNetwork(doc.id, doc.data()!);
}

export async function seedNetworks(): Promise<void> {
  const db = getDb();
  const snapshot = await db.collection(COLLECTION).get();

  if (!snapshot.empty) {
    console.log('Networks already seeded, skipping.');
    return;
  }

  const batch = db.batch();
  for (const network of SEED_NETWORKS) {
    const ref = db.collection(COLLECTION).doc(network.slug);
    batch.set(ref, {
      ...network,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
  console.log('✅ Networks seeded successfully');
}
