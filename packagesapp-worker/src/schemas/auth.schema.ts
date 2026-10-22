import { z } from 'zod';

export const SignupSchema = z.object({
  email: z
    .string({ required_error: 'Email is required' })
    .email('Invalid email address')
    .transform((val) => val.trim().toLowerCase()),
  password: z
    .string({ required_error: 'Password is required' })
    .min(6, 'Password must be at least 6 characters'),
  displayName: z.string().trim().min(1).max(100).optional(),
  name: z.string().trim().min(1).max(100).optional(),
  photoUrl: z.string().url().optional().or(z.literal('')),
});

export const LoginSchema = z.object({
  email: z
    .string({ required_error: 'Email is required' })
    .email('Invalid email address')
    .transform((val) => val.trim().toLowerCase()),
  password: z.string({ required_error: 'Password is required' }).min(1, 'Password is required'),
});

export const GoogleAuthSchema = z.object({
  idToken: z.string().optional(),
  token: z.string().optional(),
  credential: z.string().optional(),
  email: z.string().email().optional(),
  sub: z.string().optional(),
  displayName: z.string().optional(),
  name: z.string().optional(),
  photoUrl: z.string().optional(),
  picture: z.string().optional(),
});

export type SignupInput = z.infer<typeof SignupSchema>;
export type LoginInput = z.infer<typeof LoginSchema>;
export type GoogleAuthInput = z.infer<typeof GoogleAuthSchema>;
