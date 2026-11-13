import { Router } from 'express';
import ticketController from './tickets.controller.js';
import { auth } from '../../middlewares/auth.js';
import { requireRole } from '../../middlewares/requireRole.js';
import { validate } from '../../middlewares/validate.js';
import {
  createTicketSchema,
  updateTicketSchema,
  forwardTicketSchema,
  assignTicketSchema,
} from './tickets.schema.js';

const router = Router();

router.use(auth);

// GET /tickets — daftar tiket dicakup per peran (tenant_admin, vendor_admin, technician)
router.get(
  '/',
  requireRole('tenant_admin', 'vendor_admin', 'technician'),
  ticketController.getTickets
);

// GET /tickets/:id/histories — riwayat perubahan tiket
router.get(
  '/:id/histories',
  requireRole('tenant_admin', 'vendor_admin', 'technician'),
  ticketController.getTicketHistories
);

// GET /tickets/:id — detail tiket
router.get(
  '/:id',
  requireRole('tenant_admin', 'vendor_admin', 'technician'),
  ticketController.getTicketById
);

// PUT /tickets/:id — update tiket (hanya tenant_admin, hanya saat new)
router.put(
  '/:id',
  requireRole('tenant_admin'),
  validate(updateTicketSchema),
  ticketController.updateTicket
);

// PATCH /tickets/:id/forward — teruskan tiket ke vendor (hanya tenant_admin, saat new)
router.patch(
  '/:id/forward',
  requireRole('tenant_admin'),
  validate(forwardTicketSchema),
  ticketController.forwardTicket
);

// PATCH /tickets/:id/assign — tugaskan teknisi (hanya vendor_admin, saat forwarded)
router.patch(
  '/:id/assign',
  requireRole('vendor_admin'),
  validate(assignTicketSchema),
  ticketController.assignTicket
);

// POST /tickets — buat tiket baru
router.post(
  '/',
  requireRole('tenant_admin'),
  validate(createTicketSchema),
  ticketController.createTicket
);

export default router;
