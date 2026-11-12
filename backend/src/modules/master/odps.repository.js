import pool from '../../config/db.js';

export class OdpRepository {
  async findByTenantId(tenantId, areaId = null) {
    let query = `
      SELECT id, tenant_id, area_id, code, latitude, longitude
      FROM odps
      WHERE tenant_id = ?
    `;
    const params = [tenantId];

    if (areaId) {
      query += ` AND area_id = ?`;
      params.push(areaId);
    }

    query += ` ORDER BY code ASC`;

    const [rows] = await pool.query(query, params);
    return rows;
  }
}

export default new OdpRepository();
