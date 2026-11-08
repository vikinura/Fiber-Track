import { ForbiddenError } from '../utils/errors.js';

export function requireRole(...allowedRoles) {
  return (req, res, next) => {
    if (!req.auth || !req.auth.role) {
      return next(new ForbiddenError('Akses ditolak: identitas peran tidak ditemukan'));
    }

    if (!allowedRoles.includes(req.auth.role)) {
      return next(new ForbiddenError('Akses ditolak: peran tidak memiliki izin'));
    }

    next();
  };
}
