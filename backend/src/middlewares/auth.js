import jwt from 'jsonwebtoken';
import { UnauthorizedError } from '../utils/errors.js';
import { config } from '../config/env.js';

export function auth(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(new UnauthorizedError('Token otentikasi tidak ditemukan'));
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, config.jwt.secret);
    // Bind identity strictly from verified JWT
    req.auth = {
      userId: decoded.userId,
      role: decoded.role,
      tenantId: decoded.tenantId,
      vendorId: decoded.vendorId,
    };
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return next(new UnauthorizedError('Token otentikasi telah kedaluwarsa'));
    }
    return next(new UnauthorizedError('Token otentikasi tidak valid'));
  }
}
