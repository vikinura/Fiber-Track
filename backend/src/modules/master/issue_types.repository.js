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

  async findByIdAndTenantId(id, tenantId) {
    const query = `
      SELECT id, tenant_id, name
      FROM issue_types
      WHERE id = ? AND tenant_id = ?
      LIMIT 1
    `;
    const [rows] = await pool.query(query, [id, tenantId]);
    return rows[0] || null;
  }

  async create(tenantId, { name }) {
    const query = `
      INSERT INTO issue_types (tenant_id, name)
      VALUES (?, ?)
    `;
    const [result] = await pool.query(query, [tenantId, name]);
    return this.findByIdAndTenantId(result.insertId, tenantId);
  }

  async update(id, tenantId, { name }) {
    const query = `
      UPDATE issue_types
      SET name = ?
      WHERE id = ? AND tenant_id = ?
    `;
    await pool.query(query, [name, id, tenantId]);
    return this.findByIdAndTenantId(id, tenantId);
  }

  async delete(id, tenantId) {
    const query = `
      DELETE FROM issue_types
      WHERE id = ? AND tenant_id = ?
    `;
    const [result] = await pool.query(query, [id, tenantId]);
    return result.affectedRows > 0;
  }

  async isUsed(id, tenantId) {
    const [ticketRows] = await pool.query(
      'SELECT id FROM tickets WHERE issue_type_id = ? AND tenant_id = ? LIMIT 1',
      [id, tenantId]
    );
    return ticketRows.length > 0;
  }
}

export default new IssueTypeRepository();
