import { Router } from 'express';
import authController from './auth.controller.js';
import { validate } from '../../middlewares/validate.js';
import { auth } from '../../middlewares/auth.js';
import { loginRateLimiter } from '../../middlewares/rateLimit.js';
import { loginSchema } from './auth.schema.js';

const router = Router();

router.post('/login', loginRateLimiter, validate(loginSchema), authController.login);
router.get('/me', auth, authController.me);

export default router;
