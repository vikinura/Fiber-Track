/**
 * Standard API Response Helpers based on CONTEXT.md Section 14
 */

export function sendSuccess(res, data = {}, statusCode = 200, meta = null) {
  const responseBody = {
    success: true,
    data,
  };

  if (meta) {
    responseBody.meta = meta;
  }

  return res.status(statusCode).json(responseBody);
}

export function sendCreated(res, data = {}, meta = null) {
  return sendSuccess(res, data, 201, meta);
}

export function sendError(res, message, statusCode = 500, code = 'INTERNAL_ERROR', errors = null) {
  const responseBody = {
    success: false,
    code,
    message,
  };

  if (errors && Array.isArray(errors) && errors.length > 0) {
    responseBody.errors = errors;
  }

  return res.status(statusCode).json(responseBody);
}
