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

  async findById(id) {
    const query = `
      SELECT id, tenant_id, vendor_id, name, email, phone, role, is_active, created_at, updated_at
      FROM users
      WHERE id = ?
      LIMIT 1
    `;
    const [rows] = await pool.query(query, [id]);
    return rows[0] || null;
  }
}

export default new AuthRepository();
