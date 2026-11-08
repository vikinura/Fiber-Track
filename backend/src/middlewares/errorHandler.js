import { AppError } from '../utils/errors.js';
import { sendError } from '../utils/response.js';

export function errorHandler(err, req, res, next) {
  if (err instanceof AppError) {
    return sendError(res, err.message, err.statusCode, err.code, err.errors);
  }

  // Handle syntax error (invalid JSON in body)
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return sendError(res, 'Format JSON request tidak valid', 400, 'BAD_REQUEST');
  }

  // Internal unexpected error (do not leak stack trace or internal messages to client)
  console.error('[UNHANDLED_ERROR]:', err);
  return sendError(res, 'Terjadi kesalahan pada server', 500, 'INTERNAL_SERVER_ERROR');
}
