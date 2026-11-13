import { z } from 'zod';

export const createTicketSchema = {
  body: z.object({
    customer_id: z.coerce.number().int().positive('Pelanggan wajib dipilih'),
    area_id: z.coerce.number().int().positive('Area wajib dipilih'),
    odp_id: z.coerce.number().int().positive().optional().nullable(),
    issue_type_id: z.coerce.number().int().positive('Jenis gangguan wajib dipilih'),
    priority_id: z.coerce.number().int().positive('Prioritas wajib dipilih'),
    description: z
      .string({ required_error: 'Deskripsi wajib diisi' })
      .trim()
      .min(10, 'Deskripsi minimal 10 karakter')
      .max(1000, 'Deskripsi maksimal 1000 karakter'),
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
      // Latitude and longitude must be provided together or both omitted
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

export const updateTicketSchema = {
  body: z.object({
    customer_id: z.coerce.number().int().positive('Pelanggan wajib dipilih'),
    area_id: z.coerce.number().int().positive('Area wajib dipilih'),
    odp_id: z.coerce.number().int().positive().optional().nullable(),
    issue_type_id: z.coerce.number().int().positive('Jenis gangguan wajib dipilih'),
    priority_id: z.coerce.number().int().positive('Prioritas wajib dipilih'),
    description: z
      .string({ required_error: 'Deskripsi wajib diisi' })
      .trim()
      .min(10, 'Deskripsi minimal 10 karakter')
      .max(1000, 'Deskripsi maksimal 1000 karakter'),
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

export const forwardTicketSchema = {
  body: z.object({
    vendor_id: z.coerce.number().int().positive('Vendor wajib dipilih'),
  }),
};

export const assignTicketSchema = {
  body: z.object({
    technician_id: z.coerce.number().int().positive('Teknisi wajib dipilih'),
  }),
};

export const updateStatusSchema = {
  body: z
    .object({
      to_status: z.enum(['in_progress', 'resolved'], {
        errorMap: () => ({ message: "Status tujuan hanya boleh 'in_progress' atau 'resolved'" }),
      }),
      note: z.string().trim().max(500, 'Catatan maksimal 500 karakter').optional().nullable(),
    })
    .refine(
      (data) => {
        if (data.to_status === 'resolved') {
          return data.note && data.note.trim().length >= 5;
        }
        return true;
      },
      {
        message: 'Catatan wajib diisi minimal 5 karakter saat status diselesaikan',
        path: ['note'],
      }
    ),
};
