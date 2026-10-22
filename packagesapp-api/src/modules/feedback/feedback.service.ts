import { getDb, admin } from '../../config/firebase';

const COLLECTION = 'feedback';

export interface FeedbackEntry {
  message: string;
  email: string;
  name?: string;
  uid?: string;
  createdAt: FirebaseFirestore.FieldValue;
  status: 'new' | 'read' | 'resolved';
}

export async function submitFeedback(
  data: Omit<FeedbackEntry, 'createdAt' | 'status'>
): Promise<void> {
  const db = getDb();
  await db.collection(COLLECTION).add({
    ...data,
    status: 'new',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}
