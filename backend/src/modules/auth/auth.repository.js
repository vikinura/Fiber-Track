import pool from '../../config/db.js';

export class AuthRepository {
  async findByEmail(email) {
    const query = `
      SELECT id, tenant_id, vendor_id, name, email, password_hash, phone, role, is_active
      FROM users
      WHERE email = ?
      LIMIT 1
    `;
    const [rows] = await pool.query(query, [email.toLowerCase().trim()]);
    return rows[0] || null;
  }
}

export default new AuthRepository();
