import { z } from 'zod';

// ODP schemas
export const createOdpSchema = {
  body: z.object({
    area_id: z.coerce.number().int().positive('Area ID wajib dipilih'),
    code: z
      .string({ required_error: 'Kode ODP wajib diisi' })
      .trim()
      .min(2, 'Kode ODP minimal 2 karakter')
      .max(50, 'Kode ODP maksimal 50 karakter'),
    latitude: z
      .number()
      .min(-90)
      .max(90)
      .optional()
      .nullable(),
    longitude: z
      .number()
      .min(-180)
      .max(180)
      .optional()
      .nullable(),
  }).refine(
    (data) => {
      const hasLat = data.latitude !== undefined && data.latitude !== null;
      const hasLng = data.longitude !== undefined && data.longitude !== null;
      return (hasLat && hasLng) || (!hasLat && !hasLng);
    },
    {
      message: 'Latitude dan longitude harus diisi bersamaan',
      path: ['latitude'],
    }
  ),
};

export const updateOdpSchema = {
  params: z.object({
    id: z.coerce.number().int().positive('ID ODP tidak valid'),
  }),
  body: z.object({
    area_id: z.coerce.number().int().positive('Area ID wajib dipilih'),
    code: z
      .string({ required_error: 'Kode ODP wajib diisi' })
      .trim()
      .min(2, 'Kode ODP minimal 2 karakter')
      .max(50, 'Kode ODP maksimal 50 karakter'),
    latitude: z
      .number()
      .min(-90)
      .max(90)
      .optional()
      .nullable(),
    longitude: z
      .number()
      .min(-180)
      .max(180)
      .optional()
      .nullable(),
  }).refine(
    (data) => {
      const hasLat = data.latitude !== undefined && data.latitude !== null;
      const hasLng = data.longitude !== undefined && data.longitude !== null;
      return (hasLat && hasLng) || (!hasLat && !hasLng);
    },
    {
      message: 'Latitude dan longitude harus diisi bersamaan',
      path: ['latitude'],
    }
  ),
};

export const deleteOdpSchema = {
  params: z.object({
    id: z.coerce.number().int().positive('ID ODP tidak valid'),
  }),
};

// Issue Type schemas
export const createIssueTypeSchema = {
  body: z.object({
    name: z
      .string({ required_error: 'Nama jenis gangguan wajib diisi' })
      .trim()
      .min(2, 'Nama minimal 2 karakter')
      .max(100, 'Nama maksimal 100 karakter'),
  }),
};

export const updateIssueTypeSchema = {
  params: z.object({
    id: z.coerce.number().int().positive('ID jenis gangguan tidak valid'),
  }),
  body: z.object({
    name: z
      .string({ required_error: 'Nama jenis gangguan wajib diisi' })
      .trim()
      .min(2, 'Nama minimal 2 karakter')
      .max(100, 'Nama maksimal 100 karakter'),
  }),
};

export const deleteIssueTypeSchema = {
  params: z.object({
    id: z.coerce.number().int().positive('ID jenis gangguan tidak valid'),
  }),
};

// Priority schemas
export const createPrioritySchema = {
  body: z.object({
    name: z
      .string({ required_error: 'Nama prioritas wajib diisi' })
      .trim()
      .min(2, 'Nama minimal 2 karakter')
      .max(50, 'Nama maksimal 50 karakter'),
    sla_hours: z
      .coerce
      .number()
      .int()
      .positive('SLA hours harus bilangan bulat positif'),
  }),
};

export const updatePrioritySchema = {
  params: z.object({
    id: z.coerce.number().int().positive('ID prioritas tidak valid'),
  }),
  body: z.object({
    name: z
      .string({ required_error: 'Nama prioritas wajib diisi' })
      .trim()
      .min(2, 'Nama minimal 2 karakter')
      .max(50, 'Nama maksimal 50 karakter'),
    sla_hours: z
      .coerce
      .number()
      .int()
      .positive('SLA hours harus bilangan bulat positif'),
  }),
};

export const deletePrioritySchema = {
  params: z.object({
    id: z.coerce.number().int().positive('ID prioritas tidak valid'),
  }),
};
