import userService from './users.service.js';
import { sendSuccess } from '../../utils/response.js';

export class UserController {
  async getUsers(req, res, next) {
    try {
      const { role } = req.query;
      if (role === 'technician') {
        const technicians = await userService.getTechnicians(req.auth);
        return sendSuccess(res, technicians);
      }
      return sendSuccess(res, []);
    } catch (error) {
      next(error);
    }
  }
}

export default new UserController();
