import { Router } from 'express';
import authController from './auth.controller.js';
import { validate } from '../../middlewares/validate.js';
import { loginSchema } from './auth.schema.js';

const router = Router();

router.post('/login', validate(loginSchema), authController.login);

export default router;
