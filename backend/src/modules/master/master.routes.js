import { Router } from 'express';
import masterController from './master.controller.js';
import { auth } from '../../middlewares/auth.js';
import { requireRole } from '../../middlewares/requireRole.js';

const router = Router();

// Endpoint master hanya untuk role tenant_admin
router.use(auth);
router.use(requireRole('tenant_admin'));

router.get('/areas', masterController.getAreas);
router.get('/odps', masterController.getOdps);
router.get('/issue-types', masterController.getIssueTypes);
router.get('/priorities', masterController.getPriorities);
router.get('/customers', masterController.getCustomers);
router.get('/vendors', masterController.getVendors);

export default router;
