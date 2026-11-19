import pool from '../../config/db.js';

export class CustomerRepository {
  async findByTenantId(tenantId, { search = '', page = 1, limit = 10 } = {}) {
    const offset = (page - 1) * limit;
    let whereClause = `WHERE c.tenant_id = ?`;
    const params = [tenantId];

    if (search && search.trim() !== '') {
      whereClause += ` AND (c.name LIKE ? OR c.phone LIKE ? OR c.address LIKE ?)`;
      const searchParam = `%${search.trim()}%`;
      params.push(searchParam, searchParam, searchParam);
    }

    // Count total query
    const countQuery = `
      SELECT COUNT(*) AS total
      FROM customers c
      ${whereClause}
    `;
    const [countRows] = await pool.query(countQuery, params);
    const total = countRows[0]?.total || 0;

    // Data query with area and odp joins
    const dataQuery = `
      SELECT 
        c.id, c.tenant_id, c.area_id, c.odp_id, c.name, c.address, c.phone,
        a.name AS area_name,
        o.code AS odp_code
      FROM customers c
      LEFT JOIN areas a ON c.area_id = a.id
      LEFT JOIN odps o ON c.odp_id = o.id
      ${whereClause}
      ORDER BY c.name ASC
      LIMIT ? OFFSET ?
    `;
    const [rows] = await pool.query(dataQuery, [...params, limit, offset]);

    return {
      data: rows,
      meta: {
        page,
        limit,
        total,
      },
    };
  }

  async findByIdAndTenantId(id, tenantId) {
    const query = `
      SELECT 
        c.id, c.tenant_id, c.area_id, c.odp_id, c.name, c.address, c.phone,
        a.name AS area_name,
        o.code AS odp_code
      FROM customers c
      LEFT JOIN areas a ON c.area_id = a.id
      LEFT JOIN odps o ON c.odp_id = o.id
      WHERE c.id = ? AND c.tenant_id = ?
      LIMIT 1
    `;
    const [rows] = await pool.query(query, [id, tenantId]);
    return rows[0] || null;
  }

  async create(tenantId, { name, phone, address, area_id, odp_id }) {
    const query = `
      INSERT INTO customers (tenant_id, name, phone, address, area_id, odp_id)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    const [result] = await pool.query(query, [
      tenantId,
      name,
      phone || null,
      address || null,
      area_id || null,
      odp_id || null,
    ]);
    return this.findByIdAndTenantId(result.insertId, tenantId);
  }

  async update(id, tenantId, { name, phone, address, area_id, odp_id }) {
    const query = `
      UPDATE customers
      SET name = ?, phone = ?, address = ?, area_id = ?, odp_id = ?
      WHERE id = ? AND tenant_id = ?
    `;
    await pool.query(query, [
      name,
      phone || null,
      address || null,
      area_id || null,
      odp_id || null,
      id,
      tenantId,
    ]);
    return this.findByIdAndTenantId(id, tenantId);
  }

  async delete(id, tenantId) {
    const query = `
      DELETE FROM customers
      WHERE id = ? AND tenant_id = ?
    `;
    const [result] = await pool.query(query, [id, tenantId]);
    return result.affectedRows > 0;
  }

  async isUsed(id, tenantId) {
    const [ticketRows] = await pool.query(
      'SELECT id FROM tickets WHERE customer_id = ? AND tenant_id = ? LIMIT 1',
      [id, tenantId]
    );
    return ticketRows.length > 0;
  }
}

export default new CustomerRepository();
