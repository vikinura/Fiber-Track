import { Router } from 'express';
import notificationController from './notifications.controller.js';
import { auth } from '../../middlewares/auth.js';

const router = Router();

router.use(auth);

// GET /notifications — ambil notifikasi milik user
router.get('/', notificationController.getNotifications);

// PATCH /notifications/:id/read — tandai notifikasi telah dibaca
router.patch('/:id/read', notificationController.markAsRead);

export default router;
