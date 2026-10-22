import { z } from 'zod';

export const FeedbackInputSchema = z.preprocess(
  (val: any) => {
    if (typeof val !== 'object' || val === null) return val;
    const copy = { ...val };
    if (copy.user_id && !copy.userId) copy.userId = copy.user_id;
    if (copy.device_info && !copy.deviceInfo) {
      copy.deviceInfo = typeof copy.device_info === 'string' ? copy.device_info : JSON.stringify(copy.device_info);
    } else if (copy.deviceInfo && typeof copy.deviceInfo !== 'string') {
      copy.deviceInfo = JSON.stringify(copy.deviceInfo);
    }
    return copy;
  },
  z.object({
    userId: z.string().optional().default(''),
    name: z.string().trim().optional().default(''),
    email: z
      .string()
      .trim()
      .email('Invalid email address')
      .optional()
      .or(z.literal(''))
      .default(''),
    subject: z.string().trim().optional().default(''),
    rating: z.coerce.number().int().min(1).max(5).default(5),
    category: z.string().trim().min(1).default('general'),
    message: z.string().min(2, 'Message must be at least 2 characters'),
    type: z.string().trim().default('feedback'), // 'feedback' | 'contact' | 'inquiry' | 'bug'
    deviceInfo: z.string().default(''),
  })
);

export type FeedbackInput = z.infer<typeof FeedbackInputSchema>;
