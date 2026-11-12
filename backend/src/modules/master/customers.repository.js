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
}

export default new CustomerRepository();
