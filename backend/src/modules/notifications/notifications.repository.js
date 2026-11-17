import pool from '../../config/db.js';

export class NotificationRepository {
  /**
   * Ambil daftar notifikasi untuk pengguna tertentu, diurutkan terbaru dulu
   */
  async findByUserId(userId, limit = 50) {
    const sql = `
      SELECT
        n.id,
        n.user_id,
        n.ticket_id,
        t.ticket_no,
        n.message,
        n.is_read,
        n.created_at
      FROM notifications n
      LEFT JOIN tickets t ON t.id = n.ticket_id
      WHERE n.user_id = ?
      ORDER BY n.created_at DESC
      LIMIT ?
    `;
    const [rows] = await pool.query(sql, [userId, limit]);
    return rows;
  }

  /**
   * Hitung jumlah notifikasi belum dibaca untuk pengguna tertentu
   */
  async countUnreadByUserId(userId) {
    const sql = `
      SELECT COUNT(*) AS unread_count
      FROM notifications
      WHERE user_id = ? AND is_read = 0
    `;
    const [rows] = await pool.query(sql, [userId]);
    return rows[0]?.unread_count || 0;
  }

  /**
   * Tandai satu notifikasi sebagai telah dibaca
   */
  async markAsRead(id, userId) {
    const sql = `
      UPDATE notifications
      SET is_read = 1
      WHERE id = ? AND user_id = ?
    `;
    const [result] = await pool.query(sql, [id, userId]);
    return result.affectedRows > 0;
  }
}

export default new NotificationRepository();
