import { z } from 'zod';

export const createCustomerSchema = {
  body: z.object({
    name: z
      .string({ required_error: 'Nama pelanggan wajib diisi' })
      .trim()
      .min(2, 'Nama pelanggan minimal 2 karakter')
      .max(150, 'Nama pelanggan maksimal 150 karakter'),
    phone: z
      .string()
      .trim()
      .regex(/^[0-9+]+$/, 'Nomor telepon hanya boleh berisi angka dan tanda +')
      .min(8, 'Nomor telepon minimal 8 digit')
      .max(15, 'Nomor telepon maksimal 15 digit')
      .optional()
      .nullable(),
    address: z
      .string()
      .trim()
      .max(255, 'Alamat maksimal 255 karakter')
      .optional()
      .nullable(),
    area_id: z
      .coerce
      .number()
      .int()
      .positive('Area ID tidak valid')
      .optional()
      .nullable(),
    odp_id: z
      .coerce
      .number()
      .int()
      .positive('ODP ID tidak valid')
      .optional()
      .nullable(),
  }),
};

export const updateCustomerSchema = {
  params: z.object({
    id: z.coerce.number().int().positive('ID pelanggan tidak valid'),
  }),
  body: z.object({
    name: z
      .string({ required_error: 'Nama pelanggan wajib diisi' })
      .trim()
      .min(2, 'Nama pelanggan minimal 2 karakter')
      .max(150, 'Nama pelanggan maksimal 150 karakter'),
    phone: z
      .string()
      .trim()
      .regex(/^[0-9+]+$/, 'Nomor telepon hanya boleh berisi angka dan tanda +')
      .min(8, 'Nomor telepon minimal 8 digit')
      .max(15, 'Nomor telepon maksimal 15 digit')
      .optional()
      .nullable(),
    address: z
      .string()
      .trim()
      .max(255, 'Alamat maksimal 255 karakter')
      .optional()
      .nullable(),
    area_id: z
      .coerce
      .number()
      .int()
      .positive('Area ID tidak valid')
      .optional()
      .nullable(),
    odp_id: z
      .coerce
      .number()
      .int()
      .positive('ODP ID tidak valid')
      .optional()
      .nullable(),
  }),
};

export const deleteCustomerSchema = {
  params: z.object({
    id: z.coerce.number().int().positive('ID pelanggan tidak valid'),
  }),
};
