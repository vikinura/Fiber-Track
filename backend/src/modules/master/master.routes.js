import { Router } from 'express';
import masterController from './master.controller.js';
import { auth } from '../../middlewares/auth.js';

const router = Router();

// Routes are protected by auth middleware; tenantId is extracted from req.auth
router.use(auth);

router.get('/areas', masterController.getAreas);
router.get('/odps', masterController.getOdps);
router.get('/issue-types', masterController.getIssueTypes);
router.get('/priorities', masterController.getPriorities);

export default router;
