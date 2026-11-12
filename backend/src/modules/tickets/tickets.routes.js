import { Router } from 'express';
import ticketController from './tickets.controller.js';
import { auth } from '../../middlewares/auth.js';
import { requireRole } from '../../middlewares/requireRole.js';
import { validate } from '../../middlewares/validate.js';
import { createTicketSchema } from './tickets.schema.js';

const router = Router();

router.use(auth);

// Hanya tenant_admin yang dapat membuat tiket
router.post(
  '/',
  requireRole('tenant_admin'),
  validate(createTicketSchema),
  ticketController.createTicket
);

export default router;
