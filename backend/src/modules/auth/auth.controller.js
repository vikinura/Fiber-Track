import authService from './auth.service.js';
import { sendSuccess } from '../../utils/response.js';

export class AuthController {
  async login(req, res, next) {
    try {
      const { email, password } = req.body;
      const result = await authService.login(email, password);
      return sendSuccess(res, result, 200);
    } catch (error) {
      next(error);
    }
  }
}

export default new AuthController();
