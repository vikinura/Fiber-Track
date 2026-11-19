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

  async findByIdAndTenantId(id, tenantId) {
    const query = `
      SELECT id, tenant_id, name, description
      FROM areas
      WHERE id = ? AND tenant_id = ?
      LIMIT 1
    `;
    const [rows] = await pool.query(query, [id, tenantId]);
    return rows[0] || null;
  }

  async create(tenantId, { name, description }) {
    const query = `
      INSERT INTO areas (tenant_id, name, description)
      VALUES (?, ?, ?)
    `;
    const [result] = await pool.query(query, [tenantId, name, description || null]);
    return this.findByIdAndTenantId(result.insertId, tenantId);
  }

  async update(id, tenantId, { name, description }) {
    const query = `
      UPDATE areas
      SET name = ?, description = ?
      WHERE id = ? AND tenant_id = ?
    `;
    await pool.query(query, [name, description || null, id, tenantId]);
    return this.findByIdAndTenantId(id, tenantId);
  }

  async delete(id, tenantId) {
    const query = `
      DELETE FROM areas
      WHERE id = ? AND tenant_id = ?
    `;
    const [result] = await pool.query(query, [id, tenantId]);
    return result.affectedRows > 0;
  }

  async isUsed(id, tenantId) {
    // Cek relasi di tabel tickets, odps, dan customers
    const [ticketRows] = await pool.query(
      'SELECT id FROM tickets WHERE area_id = ? AND tenant_id = ? LIMIT 1',
      [id, tenantId]
    );
    if (ticketRows.length > 0) return true;

    const [odpRows] = await pool.query(
      'SELECT id FROM odps WHERE area_id = ? AND tenant_id = ? LIMIT 1',
      [id, tenantId]
    );
    if (odpRows.length > 0) return true;

    const [customerRows] = await pool.query(
      'SELECT id FROM customers WHERE area_id = ? AND tenant_id = ? LIMIT 1',
      [id, tenantId]
    );
    if (customerRows.length > 0) return true;

    return false;
  }
}

export default new AreaRepository();
