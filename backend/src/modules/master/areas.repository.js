import pool from '../../config/db.js';

export class AreaRepository {
  async findByTenantId(tenantId) {
    const query = `
      SELECT id, tenant_id, name, description
      FROM areas
      WHERE tenant_id = ?
      ORDER BY name ASC
    `;
    const [rows] = await pool.query(query, [tenantId]);
    return rows;
  }
}

export default new AreaRepository();
