import pool from '../../config/db.js';

export class PriorityRepository {
  async findByTenantId(tenantId) {
    const query = `
      SELECT id, tenant_id, name, sla_hours
      FROM priorities
      WHERE tenant_id = ?
      ORDER BY sla_hours ASC
    `;
    const [rows] = await pool.query(query, [tenantId]);
    return rows;
  }
}

export default new PriorityRepository();
