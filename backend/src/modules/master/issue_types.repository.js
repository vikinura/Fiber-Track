import pool from '../../config/db.js';

export class IssueTypeRepository {
  async findByTenantId(tenantId) {
    const query = `
      SELECT id, tenant_id, name
      FROM issue_types
      WHERE tenant_id = ?
      ORDER BY name ASC
    `;
    const [rows] = await pool.query(query, [tenantId]);
    return rows;
  }
}

export default new IssueTypeRepository();
