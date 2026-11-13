import { Router } from 'express';
import ticketController from './tickets.controller.js';
import { auth } from '../../middlewares/auth.js';
import { requireRole } from '../../middlewares/requireRole.js';
import { validate } from '../../middlewares/validate.js';
import { createTicketSchema } from './tickets.schema.js';

const router = Router();

router.use(auth);

// GET /tickets — daftar tiket (hanya tenant_admin untuk T40; diperluas di T41)
router.get(
  '/',
  requireRole('tenant_admin'),
  ticketController.getTickets
);

// POST /tickets — buat tiket baru
router.post(
  '/',
  requireRole('tenant_admin'),
  validate(createTicketSchema),
  ticketController.createTicket
);

export default router;
