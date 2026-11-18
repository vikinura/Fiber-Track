import pool from '../../config/db.js';

export class OdpRepository {
  async findByTenantId(tenantId, areaId = null) {
    let query = `
      SELECT o.id, o.tenant_id, o.area_id, o.code, o.latitude, o.longitude, a.name AS area_name
      FROM odps o
      LEFT JOIN areas a ON o.area_id = a.id
      WHERE o.tenant_id = ?
    `;
    const params = [tenantId];

    if (areaId) {
      query += ` AND o.area_id = ?`;
      params.push(areaId);
    }

    query += ` ORDER BY o.code ASC`;

    const [rows] = await pool.query(query, params);
    return rows;
  }

  async findByIdAndTenantId(id, tenantId) {
    const query = `
      SELECT o.id, o.tenant_id, o.area_id, o.code, o.latitude, o.longitude, a.name AS area_name
      FROM odps o
      LEFT JOIN areas a ON o.area_id = a.id
      WHERE o.id = ? AND o.tenant_id = ?
      LIMIT 1
    `;
    const [rows] = await pool.query(query, [id, tenantId]);
    return rows[0] || null;
  }

  async findByCodeAndTenantId(code, tenantId) {
    const query = `
      SELECT id, tenant_id, area_id, code
      FROM odps
      WHERE code = ? AND tenant_id = ?
      LIMIT 1
    `;
    const [rows] = await pool.query(query, [code, tenantId]);
    return rows[0] || null;
  }

  async create(tenantId, { area_id, code, latitude, longitude }) {
    const query = `
      INSERT INTO odps (tenant_id, area_id, code, latitude, longitude)
      VALUES (?, ?, ?, ?, ?)
    `;
    const [result] = await pool.query(query, [
      tenantId,
      area_id,
      code,
      latitude || null,
      longitude || null,
    ]);
    return this.findByIdAndTenantId(result.insertId, tenantId);
  }

  async update(id, tenantId, { area_id, code, latitude, longitude }) {
    const query = `
      UPDATE odps
      SET area_id = ?, code = ?, latitude = ?, longitude = ?
      WHERE id = ? AND tenant_id = ?
    `;
    await pool.query(query, [
      area_id,
      code,
      latitude || null,
      longitude || null,
      id,
      tenantId,
    ]);
    return this.findByIdAndTenantId(id, tenantId);
  }

  async delete(id, tenantId) {
    const query = `
      DELETE FROM odps
      WHERE id = ? AND tenant_id = ?
    `;
    const [result] = await pool.query(query, [id, tenantId]);
    return result.affectedRows > 0;
  }

  async isUsed(id, tenantId) {
    const [ticketRows] = await pool.query(
      'SELECT id FROM tickets WHERE odp_id = ? AND tenant_id = ? LIMIT 1',
      [id, tenantId]
    );
    if (ticketRows.length > 0) return true;

    const [customerRows] = await pool.query(
      'SELECT id FROM customers WHERE odp_id = ? AND tenant_id = ? LIMIT 1',
      [id, tenantId]
    );
    if (customerRows.length > 0) return true;

    return false;
  }
}

export default new OdpRepository();
