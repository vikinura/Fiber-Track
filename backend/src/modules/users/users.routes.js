import { Router } from 'express';
import userController from './users.controller.js';
import { auth } from '../../middlewares/auth.js';

const router = Router();

router.use(auth);

router.get('/users', userController.getUsers);

export default router;
