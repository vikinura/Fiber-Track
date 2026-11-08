import { z } from 'zod';

export const loginSchema = {
  body: z.object({
    email: z.string({ required_error: 'Email wajib diisi' })
      .trim()
      .email('Format email tidak valid')
      .max(150, 'Email maksimal 150 karakter'),
    password: z.string({ required_error: 'Password wajib diisi' })
      .min(8, 'Password minimal 8 karakter')
      .max(72, 'Password maksimal 72 karakter'),
  }),
};
