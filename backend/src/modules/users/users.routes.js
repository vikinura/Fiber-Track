import { Router } from 'express';
import userController from './users.controller.js';
import { auth } from '../../middlewares/auth.js';
import { requireRole } from '../../middlewares/requireRole.js';

const router = Router();

router.use(auth);
// GET /users?role=technician hanya untuk vendor_admin
router.use(requireRole('vendor_admin'));

router.get('/', userController.getUsers);

export default router;
