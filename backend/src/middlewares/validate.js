import { ZodError } from 'zod';
import { ValidationError } from '../utils/errors.js';

export function validate(schema) {
  return async (req, res, next) => {
    try {
      if (schema.params) {
        req.params = await schema.params.parseAsync(req.params);
      }
      if (schema.query) {
        req.query = await schema.query.parseAsync(req.query);
      }
      if (schema.body) {
        req.body = await schema.body.parseAsync(req.body);
      }
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const issues = error.issues || error.errors || [];
        const formattedErrors = issues.map(err => ({
          field: err.path.join('.'),
          message: err.message,
        }));
        return next(new ValidationError('Data tidak valid', formattedErrors));
      }
      next(error);
    }
  };
}
