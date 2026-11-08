import rateLimit from 'express-rate-limit';
import { sendError } from '../utils/response.js';

export const loginRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // Limit each IP to 10 login requests per windowMs
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    return sendError(
      res,
      'Terlalu banyak percobaan login dari IP ini. Silakan coba lagi setelah 15 menit.',
      429,
      'TOO_MANY_REQUESTS'
    );
  },
});
