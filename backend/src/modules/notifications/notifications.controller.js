import notificationService from './notifications.service.js';
import { sendSuccess } from '../../utils/response.js';

export class NotificationController {
  async getNotifications(req, res, next) {
    try {
      const result = await notificationService.getNotifications(req.auth.userId);
      return sendSuccess(res, result);
    } catch (error) {
      next(error);
    }
  }

  async markAsRead(req, res, next) {
    try {
      const id = parseInt(req.params.id, 10);
      const result = await notificationService.markAsRead(id, req.auth.userId);
      return sendSuccess(res, result);
    } catch (error) {
      next(error);
    }
  }
}

export default new NotificationController();
