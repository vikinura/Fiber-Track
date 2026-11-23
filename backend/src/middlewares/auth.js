import jwt from 'jsonwebtoken';
import { UnauthorizedError } from '../utils/errors.js';
import { config } from '../config/env.js';

export function auth(req, res, next) {
  const authHeader = req.headers.authorization;
  let token = null;

  if (authHeader && authHeader.startsWith('Bearer ')) {
    token = authHeader.split(' ')[1];
  } else if (req.query && req.query.token) {
    // Dukungan token via query parameter untuk elemen HTML img / Flutter Web image tags
    token = req.query.token;
  }

  if (!token) {
    return next(new UnauthorizedError('Token otentikasi tidak ditemukan'));
  }

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
