import pool from '../../config/db.js';
import ticketRepository from './tickets.repository.js';
import { calculateSlaDueAt } from '../../utils/sla.js';
import { ValidationError, NotFoundError } from '../../utils/errors.js';

export class TicketService {
  async createTicket(auth, input) {
    const tenantId = auth.tenantId;

    // 1. Verify customer exists and belongs to tenant
    const [custRows] = await pool.query(
      'SELECT id, area_id, odp_id FROM customers WHERE id = ? AND tenant_id = ?',
      [input.customer_id, tenantId]
    );
    if (!custRows || custRows.length === 0) {
      throw new ValidationError('Pelanggan tidak valid atau tidak ditemukan pada tenant Anda', [
        { field: 'customer_id', message: 'Pelanggan tidak valid' },
      ]);
    }

    // 2. Verify area exists and belongs to tenant
    const [areaRows] = await pool.query(
      'SELECT id FROM areas WHERE id = ? AND tenant_id = ?',
      [input.area_id, tenantId]
    );
    if (!areaRows || areaRows.length === 0) {
      throw new ValidationError('Area tidak valid atau tidak ditemukan pada tenant Anda', [
        { field: 'area_id', message: 'Area tidak valid' },
      ]);
    }

    // 3. Verify ODP if provided: belongs to tenant AND located in the specified area
    if (input.odp_id) {
      const [odpRows] = await pool.query(
        'SELECT id, area_id FROM odps WHERE id = ? AND tenant_id = ?',
        [input.odp_id, tenantId]
      );
      if (!odpRows || odpRows.length === 0) {
        throw new ValidationError('ODP tidak valid atau tidak ditemukan pada tenant Anda', [
          { field: 'odp_id', message: 'ODP tidak valid' },
        ]);
      }
      if (odpRows[0].area_id !== input.area_id) {
        throw new ValidationError('ODP harus berada pada area yang dipilih', [
          { field: 'odp_id', message: 'ODP tidak berada di area yang dipilih' },
        ]);
      }
    }

    // 4. Verify issue_type belongs to tenant
    const [issueRows] = await pool.query(
      'SELECT id FROM issue_types WHERE id = ? AND tenant_id = ?',
      [input.issue_type_id, tenantId]
    );
    if (!issueRows || issueRows.length === 0) {
      throw new ValidationError('Jenis gangguan tidak valid', [
        { field: 'issue_type_id', message: 'Jenis gangguan tidak valid' },
      ]);
    }

    // 5. Verify priority belongs to tenant and get sla_hours
    const [priorityRows] = await pool.query(
      'SELECT id, sla_hours FROM priorities WHERE id = ? AND tenant_id = ?',
      [input.priority_id, tenantId]
    );
    if (!priorityRows || priorityRows.length === 0) {
      throw new ValidationError('Prioritas tidak valid', [
        { field: 'priority_id', message: 'Prioritas tidak valid' },
      ]);
    }
    const slaHours = priorityRows[0].sla_hours;

    // 6. Calculate fixed sla_due_at
    const now = new Date();
    const slaDueAt = calculateSlaDueAt(now, slaHours);

    // 7. Insert ticket with initial history in transaction
    const ticket = await ticketRepository.createTicketWithInitialHistory(
      {
        tenantId,
        customerId: input.customer_id,
        areaId: input.area_id,
        odpId: input.odp_id,
        issueTypeId: input.issue_type_id,
        priorityId: input.priority_id,
        description: input.description,
        latitude: input.latitude,
        longitude: input.longitude,
        slaDueAt,
      },
      auth.userId
    );

    return ticket;
  }
}

export default new TicketService();
