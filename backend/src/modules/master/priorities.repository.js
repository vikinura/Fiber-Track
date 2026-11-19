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

  async findByIdAndTenantId(id, tenantId) {
    const query = `
      SELECT id, tenant_id, name, sla_hours
      FROM priorities
      WHERE id = ? AND tenant_id = ?
      LIMIT 1
    `;
    const [rows] = await pool.query(query, [id, tenantId]);
    return rows[0] || null;
  }

  async create(tenantId, { name, sla_hours }) {
    const query = `
      INSERT INTO priorities (tenant_id, name, sla_hours)
      VALUES (?, ?, ?)
    `;
    const [result] = await pool.query(query, [tenantId, name, sla_hours]);
    return this.findByIdAndTenantId(result.insertId, tenantId);
  }

  async update(id, tenantId, { name, sla_hours }) {
    const query = `
      UPDATE priorities
      SET name = ?, sla_hours = ?
      WHERE id = ? AND tenant_id = ?
    `;
    await pool.query(query, [name, sla_hours, id, tenantId]);
    return this.findByIdAndTenantId(id, tenantId);
  }

  async delete(id, tenantId) {
    const query = `
      DELETE FROM priorities
      WHERE id = ? AND tenant_id = ?
    `;
    const [result] = await pool.query(query, [id, tenantId]);
    return result.affectedRows > 0;
  }

  async isUsed(id, tenantId) {
    const [ticketRows] = await pool.query(
      'SELECT id FROM tickets WHERE priority_id = ? AND tenant_id = ? LIMIT 1',
      [id, tenantId]
    );
    return ticketRows.length > 0;
  }
}

export default new PriorityRepository();
