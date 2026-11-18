import { Router } from 'express';
import dashboardController from './dashboard.controller.js';
import { auth } from '../../middlewares/auth.js';
import { requireRole } from '../../middlewares/requireRole.js';

const router = Router();

router.use(auth);
router.use(requireRole('tenant_admin'));

// GET /dashboard/summary — ringkasan status, overdue, rata-rata durasi, persentase SLA
router.get('/summary', dashboardController.getSummary);

// GET /dashboard/by-area — sebaran gangguan per area
router.get('/by-area', dashboardController.getByArea);

// GET /dashboard/by-vendor — performa tiket per vendor
router.get('/by-vendor', dashboardController.getByVendor);

export default router;
