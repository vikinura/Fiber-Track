import { z } from 'zod';

export const createAreaSchema = {
  body: z.object({
    name: z
      .string({ required_error: 'Nama area wajib diisi' })
      .trim()
      .min(2, 'Nama area minimal 2 karakter')
      .max(100, 'Nama area maksimal 100 karakter'),
    description: z
      .string()
      .trim()
      .max(255, 'Deskripsi maksimal 255 karakter')
      .optional()
      .nullable(),
  }),
};

export const updateAreaSchema = {
  params: z.object({
    id: z.coerce.number().int().positive('ID area tidak valid'),
  }),
  body: z.object({
    name: z
      .string({ required_error: 'Nama area wajib diisi' })
      .trim()
      .min(2, 'Nama area minimal 2 karakter')
      .max(100, 'Nama area maksimal 100 karakter'),
    description: z
      .string()
      .trim()
      .max(255, 'Deskripsi maksimal 255 karakter')
      .optional()
      .nullable(),
  }),
};

export const deleteAreaSchema = {
  params: z.object({
    id: z.coerce.number().int().positive('ID area tidak valid'),
  }),
};
