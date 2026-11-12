import pool from '../../config/db.js';

export class UserRepository {
  async findTechniciansByVendorId(vendorId) {
    const query = `
      SELECT 
        u.id, u.vendor_id, u.name, u.email, u.phone, u.role, u.is_active
      FROM users u
      WHERE u.vendor_id = ? 
        AND u.role = 'technician'
        AND u.is_active = true
      ORDER BY u.name ASC
    `;
    const [rows] = await pool.query(query, [vendorId]);
    return rows;
  }
}

export default new UserRepository();
