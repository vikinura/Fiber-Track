import pool from '../../config/db.js';

/**
 * Generator nomor tiket unik per tenant
 * Format: TKT-YYYYMMDD-XXXX (mis. TKT-20261112-0001)
 */
export async function generateTicketNo(connection, tenantId, date = new Date()) {
  const yyyy = date.getFullYear();
  const mm = String(date.getMonth() + 1).padStart(2, '0');
  const dd = String(date.getDate()).padStart(2, '0');
  const prefix = `TKT-${yyyy}${mm}${dd}-`;

  const query = `
    SELECT ticket_no 
    FROM tickets 
    WHERE tenant_id = ? AND ticket_no LIKE ? 
    ORDER BY id DESC 
    LIMIT 1 
    FOR UPDATE
  `;
  const [rows] = await connection.query(query, [tenantId, `${prefix}%`]);

  let nextSequence = 1;
  if (rows && rows.length > 0) {
    const lastNo = rows[0].ticket_no;
    const parts = lastNo.split('-');
    const lastSeq = parseInt(parts[2], 10);
    if (!isNaN(lastSeq)) {
      nextSequence = lastSeq + 1;
    }
  }

  return `${prefix}${String(nextSequence).padStart(4, '0')}`;
}

export class TicketRepository {
  /**
   * Daftar tiket dengan scoping peran, filter, dan paginasi
   * @param {{ role: string, tenantId?: number, vendorId?: number, userId?: number }} auth
   * @param {{ page?: number, limit?: number, status?: string, area_id?: number, vendor_id?: number, q?: string }} filters
   */
  async findTickets(auth, { page = 1, limit = 10, status, area_id, vendor_id, q } = {}) {
    const offset = (page - 1) * limit;
    const conditions = [];
    const params = [];

    // Role-based scoping
    if (auth.role === 'tenant_admin') {
      conditions.push('t.tenant_id = ?');
      params.push(auth.tenantId);

      // tenant_admin can filter by vendor_id
      if (vendor_id) {
        conditions.push('t.vendor_id = ?');
        params.push(Number(vendor_id));
      }
    } else if (auth.role === 'vendor_admin') {
      conditions.push('t.vendor_id = ?');
      params.push(auth.vendorId);
    } else if (auth.role === 'technician') {
      conditions.push('t.technician_id = ? AND t.vendor_id = ?');
      params.push(auth.userId, auth.vendorId);
    } else {
      // Role lain (misal super_admin) tidak memiliki akses tiket
      return { data: [], meta: { page, limit, total: 0 } };
    }

    // Additional filters
    if (status) {
      conditions.push('t.status = ?');
      params.push(status);
    }
    if (area_id) {
      conditions.push('t.area_id = ?');
      params.push(Number(area_id));
    }
    if (q && q.trim()) {
      const search = `%${q.trim()}%`;
      conditions.push('(t.ticket_no LIKE ? OR c.name LIKE ?)');
      params.push(search, search);
    }

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

    const dataSql = `
      SELECT
        t.id,
        t.ticket_no,
        t.status,
        t.description,
        t.latitude,
        t.longitude,
        t.sla_due_at,
        t.resolved_at,
        t.created_at,
        t.updated_at,
        t.customer_id,
        c.name  AS customer_name,
        t.area_id,
        a.name  AS area_name,
        t.odp_id,
        o.code  AS odp_code,
        t.issue_type_id,
        it.name AS issue_type_name,
        t.priority_id,
        p.name  AS priority_name,
        p.sla_hours,
        t.vendor_id,
        v.name  AS vendor_name,
        t.technician_id,
        u.name  AS technician_name,
        t.created_by
      FROM tickets t
      LEFT JOIN customers  c  ON c.id  = t.customer_id
      LEFT JOIN areas      a  ON a.id  = t.area_id
      LEFT JOIN odps       o  ON o.id  = t.odp_id
      LEFT JOIN issue_types it ON it.id = t.issue_type_id
      LEFT JOIN priorities p  ON p.id  = t.priority_id
      LEFT JOIN vendors    v  ON v.id  = t.vendor_id
      LEFT JOIN users      u  ON u.id  = t.technician_id
      ${whereClause}
      ORDER BY t.created_at DESC
      LIMIT ? OFFSET ?
    `;

    const countSql = `
      SELECT COUNT(*) AS total
      FROM tickets t
      LEFT JOIN customers c ON c.id = t.customer_id
      ${whereClause}
    `;

    const [rows] = await pool.query(dataSql, [...params, limit, offset]);
    const [[{ total }]] = await pool.query(countSql, params);

    return {
      data: rows,
      meta: { page, limit, total: Number(total) },
    };
  }

  /**
   * Cari detail tiket berdasarkan ID dengan scoping peran
   * @param {number} ticketId
   * @param {{ role: string, tenantId?: number, vendorId?: number, userId?: number }} auth
   */
  async findById(ticketId, auth) {
    const conditions = ['t.id = ?'];
    const params = [ticketId];

    if (auth.role === 'tenant_admin') {
      conditions.push('t.tenant_id = ?');
      params.push(auth.tenantId);
    } else if (auth.role === 'vendor_admin') {
      conditions.push('t.vendor_id = ?');
      params.push(auth.vendorId);
    } else if (auth.role === 'technician') {
      conditions.push('t.technician_id = ? AND t.vendor_id = ?');
      params.push(auth.userId, auth.vendorId);
    } else {
      return null;
    }

    const sql = `
      SELECT
        t.id,
        t.ticket_no,
        t.status,
        t.description,
        t.latitude,
        t.longitude,
        t.sla_due_at,
        t.resolved_at,
        t.created_at,
        t.updated_at,
        t.customer_id,
        c.name    AS customer_name,
        c.address AS customer_address,
        c.phone   AS customer_phone,
        t.area_id,
        a.name    AS area_name,
        t.odp_id,
        o.code    AS odp_code,
        t.issue_type_id,
        it.name   AS issue_type_name,
        t.priority_id,
        p.name    AS priority_name,
        p.sla_hours,
        t.vendor_id,
        v.name    AS vendor_name,
        t.technician_id,
        u.name    AS technician_name,
        t.created_by,
        creator.name AS creator_name
      FROM tickets t
      LEFT JOIN customers  c  ON c.id  = t.customer_id
      LEFT JOIN areas      a  ON a.id  = t.area_id
      LEFT JOIN odps       o  ON o.id  = t.odp_id
      LEFT JOIN issue_types it ON it.id = t.issue_type_id
      LEFT JOIN priorities p  ON p.id  = t.priority_id
      LEFT JOIN vendors    v  ON v.id  = t.vendor_id
      LEFT JOIN users      u  ON u.id  = t.technician_id
      LEFT JOIN users      creator ON creator.id = t.created_by
      WHERE ${conditions.join(' AND ')}
      LIMIT 1
    `;

    const [rows] = await pool.query(sql, params);
    if (!rows || rows.length === 0) return null;

    const ticket = rows[0];

    // Ambil foto tiket beserta info pengunggah
    const [photos] = await pool.query(
      `SELECT 
         tp.id, 
         tp.ticket_id, 
         tp.uploaded_by, 
         u.name AS uploader_name,
         u.role AS uploader_role,
         tp.file_path, 
         tp.caption, 
         tp.created_at 
       FROM ticket_photos tp
       LEFT JOIN users u ON u.id = tp.uploaded_by
       WHERE tp.ticket_id = ? 
       ORDER BY tp.created_at ASC`,
      [ticketId]
    );
    ticket.photos = photos;

    return ticket;
  }

  /**
   * Ambil riwayat tiket berdasarkan ticketId
   */
  async findHistoriesByTicketId(ticketId) {
    const sql = `
      SELECT
        h.id,
        h.ticket_id,
        h.user_id,
        u.name AS user_name,
        u.role AS user_role,
        h.from_status,
        h.to_status,
        h.note,
        h.created_at
      FROM ticket_histories h
      LEFT JOIN users u ON u.id = h.user_id
      WHERE h.ticket_id = ?
      ORDER BY h.created_at ASC
    `;
    const [rows] = await pool.query(sql, [ticketId]);
    return rows;
  }

  /**
   * Alias lama untuk backward compatibility
   */
  async findByTenantId(tenantId, opts = {}) {
    return this.findTickets({ role: 'tenant_admin', tenantId }, opts);
  }

  /**
   * Update status tiket oleh teknisi dalam transaksi DB
   */
  async updateTicketStatus(ticketId, vendorId, technicianId, fromStatus, toStatus, note, userId) {
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      const isResolved = toStatus === 'resolved';

      const updateSql = `
        UPDATE tickets
        SET
          status = ?,
          resolved_at = ${isResolved ? 'NOW()' : 'resolved_at'},
          updated_at = NOW()
        WHERE id = ? AND vendor_id = ? AND technician_id = ? AND status = ?
      `;

      const [updateResult] = await connection.query(updateSql, [
        toStatus,
        ticketId,
        vendorId,
        technicianId,
        fromStatus,
      ]);

      if (updateResult.affectedRows === 0) {
        throw new Error('TICKET_NOT_FOUND_OR_INVALID_STATUS');
      }

      // Catat riwayat
      const historySql = `
        INSERT INTO ticket_histories (
          ticket_id, user_id, from_status, to_status, note, created_at
        ) VALUES (?, ?, ?, ?, ?, NOW())
      `;
      await connection.query(historySql, [
        ticketId,
        userId,
        fromStatus,
        toStatus,
        note || (isResolved ? 'Tiket diselesaikan oleh teknisi' : 'Tiket mulai dikerjakan'),
      ]);

      // Jika resolved -> buat notifikasi untuk semua tenant_admin dari tenant pemilik tiket
      if (isResolved) {
        const [ticketRow] = await connection.query(
          'SELECT tenant_id, ticket_no FROM tickets WHERE id = ?',
          [ticketId]
        );
        if (ticketRow && ticketRow.length > 0) {
          const tenantId = ticketRow[0].tenant_id;
          const ticketNo = ticketRow[0].ticket_no;

          const [taRows] = await connection.query(
            `SELECT id FROM users WHERE tenant_id = ? AND role = 'tenant_admin' AND is_active = 1`,
            [tenantId]
          );

          if (taRows && taRows.length > 0) {
            const notifValues = taRows.map(ta => [
              ta.id,
              ticketId,
              `Tiket ${ticketNo} telah selesai dikerjakan (resolved)`,
            ]);
            await connection.query(
              `INSERT INTO notifications (user_id, ticket_id, message, created_at) VALUES ?`,
              [notifValues.map(v => [...v, new Date()])]
            );
          }
        }
      }

      await connection.commit();
      return true;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  /**
   * Assign ticket ke teknisi dalam transaksi DB
   */
  async assignTicket(ticketId, vendorId, technicianId, userId) {
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // 1. Update status tiket -> 'assigned' & set technician_id
      const updateSql = `
        UPDATE tickets
        SET
          status = 'assigned',
          technician_id = ?,
          updated_at = NOW()
        WHERE id = ? AND vendor_id = ? AND status = 'forwarded'
      `;
      const [updateResult] = await connection.query(updateSql, [
        technicianId,
        ticketId,
        vendorId,
      ]);

      if (updateResult.affectedRows === 0) {
        throw new Error('TICKET_NOT_FOUND_OR_INVALID_STATUS');
      }

      // 2. Ambil nama teknisi untuk catatan riwayat
      const [uRows] = await connection.query(
        'SELECT name FROM users WHERE id = ?',
        [technicianId]
      );
      const techName = uRows?.[0]?.name ?? 'Teknisi';

      // 3. Catat riwayat perubahan status
      const historySql = `
        INSERT INTO ticket_histories (
          ticket_id, user_id, from_status, to_status, note, created_at
        ) VALUES (?, ?, 'forwarded', 'assigned', ?, NOW())
      `;
      await connection.query(historySql, [
        ticketId,
        userId,
        `Tiket ditugaskan ke ${techName}`,
      ]);

      // 4. Buat notifikasi untuk teknisi yang ditugaskan
      const [ticketRow] = await connection.query(
        'SELECT ticket_no FROM tickets WHERE id = ?',
        [ticketId]
      );
      const ticketNo = ticketRow?.[0]?.ticket_no ?? `#${ticketId}`;
      await connection.query(
        `INSERT INTO notifications (user_id, ticket_id, message, created_at)
         VALUES (?, ?, ?, NOW())`,
        [technicianId, ticketId, `Anda ditugaskan untuk mengerjakan tiket ${ticketNo}`]
      );

      await connection.commit();
      return true;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  /**
   * Forward ticket ke vendor dalam transaksi DB
   */
  async forwardTicket(ticketId, tenantId, vendorId, userId) {
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // 1. Update status tiket -> 'forwarded' & set vendor_id
      const updateSql = `
        UPDATE tickets
        SET
          status = 'forwarded',
          vendor_id = ?,
          updated_at = NOW()
        WHERE id = ? AND tenant_id = ? AND status = 'new'
      `;
      const [updateResult] = await connection.query(updateSql, [
        vendorId,
        ticketId,
        tenantId,
      ]);

      if (updateResult.affectedRows === 0) {
        throw new Error('TICKET_NOT_FOUND_OR_INVALID_STATUS');
      }

      // 2. Ambil nama vendor untuk catatan riwayat
      const [vRows] = await connection.query(
        'SELECT name FROM vendors WHERE id = ?',
        [vendorId]
      );
      const vendorName = vRows?.[0]?.name ?? 'Vendor';

      // 3. Catat riwayat perubahan status
      const historySql = `
        INSERT INTO ticket_histories (
          ticket_id, user_id, from_status, to_status, note, created_at
        ) VALUES (?, ?, 'new', 'forwarded', ?, NOW())
      `;
      await connection.query(historySql, [
        ticketId,
        userId,
        `Tiket diteruskan ke ${vendorName}`,
      ]);

      // 4. Buat notifikasi untuk semua vendor_admin dari vendor tujuan
      const [vaRows] = await connection.query(
        `SELECT id FROM users WHERE vendor_id = ? AND role = 'vendor_admin' AND is_active = 1`,
        [vendorId]
      );
      if (vaRows && vaRows.length > 0) {
        const [ticketRow] = await connection.query(
          'SELECT ticket_no FROM tickets WHERE id = ?',
          [ticketId]
        );
        const ticketNo = ticketRow?.[0]?.ticket_no ?? `#${ticketId}`;
        const notifValues = vaRows.map(va => [
          va.id,
          ticketId,
          `Tiket baru ${ticketNo} telah diteruskan ke vendor Anda`,
        ]);
        await connection.query(
          `INSERT INTO notifications (user_id, ticket_id, message, created_at) VALUES ?`,
          [notifValues.map(v => [...v, new Date()])]
        );
      }

      await connection.commit();
      return true;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  /**
   * Update tiket (hanya saat status new)
   */
  async updateTicket(ticketId, tenantId, updateData) {
    const sql = `
      UPDATE tickets
      SET
        customer_id = ?,
        area_id = ?,
        odp_id = ?,
        issue_type_id = ?,
        priority_id = ?,
        description = ?,
        latitude = ?,
        longitude = ?,
        updated_at = NOW()
      WHERE id = ? AND tenant_id = ? AND status = 'new'
    `;

    const [result] = await pool.query(sql, [
      updateData.customerId,
      updateData.areaId,
      updateData.odpId || null,
      updateData.issueTypeId,
      updateData.priorityId,
      updateData.description,
      updateData.latitude || null,
      updateData.longitude || null,
      ticketId,
      tenantId,
    ]);

    return result.affectedRows > 0;
  }

  /**
   * Insert ticket and initial history in a database transaction
   */
  async createTicketWithInitialHistory(ticketData, userId) {
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      const ticketNo = await generateTicketNo(connection, ticketData.tenantId);

      const insertTicketSql = `
        INSERT INTO tickets (
          tenant_id, ticket_no, customer_id, area_id, odp_id,
          issue_type_id, priority_id, created_by, status,
          description, latitude, longitude, sla_due_at, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'new', ?, ?, ?, ?, NOW())
      `;

      const [ticketResult] = await connection.query(insertTicketSql, [
        ticketData.tenantId,
        ticketNo,
        ticketData.customerId,
        ticketData.areaId,
        ticketData.odpId || null,
        ticketData.issueTypeId,
        ticketData.priorityId,
        userId,
        ticketData.description,
        ticketData.latitude || null,
        ticketData.longitude || null,
        ticketData.slaDueAt,
      ]);

      const ticketId = ticketResult.insertId;

      // Insert initial history
      const insertHistorySql = `
        INSERT INTO ticket_histories (
          ticket_id, user_id, from_status, to_status, note, created_at
        ) VALUES (?, ?, NULL, 'new', 'Tiket dibuat', NOW())
      `;

      await connection.query(insertHistorySql, [ticketId, userId]);

      await connection.commit();

      // Retrieve created ticket
      const [rows] = await connection.query(
        `SELECT * FROM tickets WHERE id = ? AND tenant_id = ?`,
        [ticketId, ticketData.tenantId]
      );
      return rows[0];
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  /**
   * Hitung jumlah foto tiket
   */
  async countPhotosByTicketId(ticketId) {
    const [rows] = await pool.query(
      `SELECT COUNT(*) AS total FROM ticket_photos WHERE ticket_id = ?`,
      [ticketId]
    );
    return rows[0]?.total || 0;
  }

  /**
   * Simpan foto tiket baru
   */
  async addPhoto(ticketId, userId, filePath, caption = null) {
    const [result] = await pool.query(
      `INSERT INTO ticket_photos (ticket_id, uploaded_by, file_path, caption, created_at)
       VALUES (?, ?, ?, ?, NOW())`,
      [ticketId, userId, filePath, caption]
    );

    const [rows] = await pool.query(
      `SELECT id, ticket_id, uploaded_by, file_path, caption, created_at
       FROM ticket_photos
       WHERE id = ?`,
      [result.insertId]
    );
    return rows[0];
  }

  /**
   * Ambil detail satu foto tiket berdasarkan id foto beserta ticket info
   */
  async findPhotoById(photoId) {
    const [rows] = await pool.query(
      `SELECT 
         tp.id, 
         tp.ticket_id, 
         tp.uploaded_by, 
         tp.file_path, 
         tp.caption, 
         tp.created_at,
         t.tenant_id,
         t.vendor_id,
         t.technician_id
       FROM ticket_photos tp
       JOIN tickets t ON t.id = tp.ticket_id
       WHERE tp.id = ?`,
      [photoId]
    );
    return rows[0] || null;
  }
}

export default new TicketRepository();
