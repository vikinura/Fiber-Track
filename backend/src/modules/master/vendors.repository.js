import pool from '../../config/db.js';

export class VendorRepository {
  async findActiveByTenantId(tenantId) {
    const query = `
      SELECT 
        v.id, v.name, v.contact_person, v.phone, v.status
      FROM vendors v
      INNER JOIN tenant_vendors tv ON v.id = tv.vendor_id
      WHERE tv.tenant_id = ? 
        AND tv.status = 'active'
        AND v.status = 'active'
      ORDER BY v.name ASC
    `;
    const [rows] = await pool.query(query, [tenantId]);
    return rows;
  }
}

export default new VendorRepository();
