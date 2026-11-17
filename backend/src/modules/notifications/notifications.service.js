import notificationRepository from './notifications.repository.js';
import { NotFoundError } from '../../utils/errors.js';

export class NotificationService {
  async getNotifications(userId) {
    const list = await notificationRepository.findByUserId(userId);
    const unreadCount = await notificationRepository.countUnreadByUserId(userId);
    return {
      notifications: list,
      unread_count: unreadCount,
    };
  }

  async markAsRead(id, userId) {
    const success = await notificationRepository.markAsRead(id, userId);
    if (!success) {
      throw new NotFoundError('Notifikasi tidak ditemukan');
    }
    return { id, is_read: true };
  }
}

export default new NotificationService();
