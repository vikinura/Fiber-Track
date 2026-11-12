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
}

export default new TicketRepository();
