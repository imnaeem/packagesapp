export interface FeedbackRow {
  id: string;
  user_id: string | null;
  name: string | null;
  email: string;
  subject: string | null;
  rating: number;
  category: string;
  message: string;
  type: string;
  status: string;
  device_info: string | null;
  created_at: string;
}

export interface FeedbackResponse {
  id: string;
  userId: string;
  name: string;
  email: string;
  subject: string;
  rating: number;
  category: string;
  message: string;
  type: string;
  status: string;
  deviceInfo: string;
  createdAt: string;
}
