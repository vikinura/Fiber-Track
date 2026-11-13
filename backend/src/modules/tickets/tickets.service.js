import pool from '../../config/db.js';
import ticketRepository from './tickets.repository.js';
import { calculateSlaDueAt, getSlaStatus } from '../../utils/sla.js';
import { ValidationError, NotFoundError, ConflictError } from '../../utils/errors.js';

export class TicketService {
  /**
   * Tugaskan teknisi ke tiket (hanya vendor_admin, tiket status 'forwarded', teknisi aktif milik vendor yang sama)
   */
  async assignTicket(auth, ticketId, technicianId) {
    const vendorId = auth.vendorId;

    // 1. Cek keberadaan tiket milik vendor
    const [tRows] = await pool.query(
      'SELECT id, status FROM tickets WHERE id = ? AND vendor_id = ?',
      [ticketId, vendorId]
    );

    if (!tRows || tRows.length === 0) {
      throw new NotFoundError('Tiket tidak ditemukan');
    }

    if (tRows[0].status !== 'forwarded') {
      throw new ConflictError(
        `Tiket berstatus '${tRows[0].status}' tidak dapat ditugaskan (hanya tiket berstatus 'forwarded')`
      );
    }

    // 2. Cek apakah teknisi aktif, role technician, dan milik vendor yang sama
    const [techRows] = await pool.query(
      `SELECT id, name 
       FROM users 
       WHERE id = ? AND vendor_id = ? AND role = 'technician' AND is_active = 1`,
      [technicianId, vendorId]
    );

    if (!techRows || techRows.length === 0) {
      throw new ValidationError(
        'Teknisi tidak valid, tidak aktif, atau bukan anggota dari vendor Anda',
        [{ field: 'technician_id', message: 'Teknisi tidak valid untuk vendor Anda' }]
      );
    }

    // 3. Jalankan transaksi di repository
    try {
      await ticketRepository.assignTicket(ticketId, vendorId, technicianId, auth.userId);
    } catch (err) {
      if (err.message === 'TICKET_NOT_FOUND_OR_INVALID_STATUS') {
        throw new ConflictError('Tiket tidak dalam status valid untuk ditugaskan');
      }
      throw err;
    }

    return this.getTicketById(auth, ticketId);
  }

  /**
   * Teruskan tiket ke vendor (hanya tenant_admin, hanya saat new, vendor harus relasi aktif)
   */
  async forwardTicket(auth, ticketId, vendorId) {
    const tenantId = auth.tenantId;

    // 1. Cek keberadaan tiket milik tenant
    const [tRows] = await pool.query(
      'SELECT id, status FROM tickets WHERE id = ? AND tenant_id = ?',
      [ticketId, tenantId]
    );

    if (!tRows || tRows.length === 0) {
      throw new NotFoundError('Tiket tidak ditemukan');
    }

    if (tRows[0].status !== 'new') {
      throw new ConflictError(
        `Tiket berstatus '${tRows[0].status}' tidak dapat diteruskan ke vendor (hanya tiket berstatus 'new')`
      );
    }

    // 2. Cek apakah vendor aktif dan memiliki relasi aktif di tenant_vendors
    const [tvRows] = await pool.query(
      `SELECT tv.vendor_id 
       FROM tenant_vendors tv
       JOIN vendors v ON v.id = tv.vendor_id
       WHERE tv.tenant_id = ? AND tv.vendor_id = ? AND tv.status = 'active' AND v.status = 'active'`,
      [tenantId, vendorId]
    );

    if (!tvRows || tvRows.length === 0) {
      throw new ValidationError(
        'Vendor tidak valid, tidak aktif, atau tidak bermitra dengan tenant Anda',
        [{ field: 'vendor_id', message: 'Vendor tidak memiliki kerja sama aktif' }]
      );
    }

    // 3. Jalankan transaksi di repository
    try {
      await ticketRepository.forwardTicket(ticketId, tenantId, vendorId, auth.userId);
    } catch (err) {
      if (err.message === 'TICKET_NOT_FOUND_OR_INVALID_STATUS') {
        throw new ConflictError('Tiket tidak dalam status valid untuk diteruskan');
      }
      throw err;
    }

    return this.getTicketById(auth, ticketId);
  }

  /**
   * Update tiket (hanya role tenant_admin, hanya saat status 'new')
   */
  async updateTicket(auth, ticketId, input) {
    const tenantId = auth.tenantId;

    // 1. Cek keberadaan tiket milik tenant ini
    const [existing] = await pool.query(
      'SELECT id, status FROM tickets WHERE id = ? AND tenant_id = ?',
      [ticketId, tenantId]
    );

    if (!existing || existing.length === 0) {
      throw new NotFoundError('Tiket tidak ditemukan');
    }

    if (existing[0].status !== 'new') {
      throw new ConflictError('Tiket hanya dapat diubah saat berstatus new');
    }

    // 2. Validasi customer
    const [custRows] = await pool.query(
      'SELECT id FROM customers WHERE id = ? AND tenant_id = ?',
      [input.customer_id, tenantId]
    );
    if (!custRows || custRows.length === 0) {
      throw new ValidationError('Pelanggan tidak valid atau tidak ditemukan pada tenant Anda', [
        { field: 'customer_id', message: 'Pelanggan tidak valid' },
      ]);
    }

    // 3. Validasi area
    const [areaRows] = await pool.query(
      'SELECT id FROM areas WHERE id = ? AND tenant_id = ?',
      [input.area_id, tenantId]
    );
    if (!areaRows || areaRows.length === 0) {
      throw new ValidationError('Area tidak valid atau tidak ditemukan pada tenant Anda', [
        { field: 'area_id', message: 'Area tidak valid' },
      ]);
    }

    // 4. Validasi ODP jika diisi
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

    // 5. Validasi issue_type
    const [issueRows] = await pool.query(
      'SELECT id FROM issue_types WHERE id = ? AND tenant_id = ?',
      [input.issue_type_id, tenantId]
    );
    if (!issueRows || issueRows.length === 0) {
      throw new ValidationError('Jenis gangguan tidak valid', [
        { field: 'issue_type_id', message: 'Jenis gangguan tidak valid' },
      ]);
    }

    // 6. Validasi priority
    const [priorityRows] = await pool.query(
      'SELECT id FROM priorities WHERE id = ? AND tenant_id = ?',
      [input.priority_id, tenantId]
    );
    if (!priorityRows || priorityRows.length === 0) {
      throw new ValidationError('Prioritas tidak valid', [
        { field: 'priority_id', message: 'Prioritas tidak valid' },
      ]);
    }

    // 7. Update tiket (sla_due_at TIDAK dihitung ulang per CONTEXT.md)
    await ticketRepository.updateTicket(ticketId, tenantId, {
      customerId: input.customer_id,
      areaId: input.area_id,
      odpId: input.odp_id,
      issueTypeId: input.issue_type_id,
      priorityId: input.priority_id,
      description: input.description,
      latitude: input.latitude,
      longitude: input.longitude,
    });

    return this.getTicketById(auth, ticketId);
  }

  /**
   * Detail tiket dicakup per peran
   */
  async getTicketById(auth, ticketId) {
    const ticket = await ticketRepository.findById(ticketId, auth);
    if (!ticket) {
      throw new NotFoundError('Tiket tidak ditemukan');
    }

    const slaInfo = getSlaStatus({
      createdAt: ticket.created_at,
      slaDueAt: ticket.sla_due_at,
      resolvedAt: ticket.resolved_at,
    });

    return {
      ...ticket,
      sla_status: slaInfo.status,
      sla_remaining_seconds: slaInfo.remainingSeconds,
    };
  }

  /**
   * Riwayat tiket (hanya jika tiket dapat diakses oleh peran ini)
   */
  async getTicketHistories(auth, ticketId) {
    const ticket = await ticketRepository.findById(ticketId, auth);
    if (!ticket) {
      throw new NotFoundError('Tiket tidak ditemukan');
    }

    return ticketRepository.findHistoriesByTicketId(ticketId);
  }

  /**
   * Daftar tiket untuk tenant_admin, vendor_admin, atau technician dengan filter & SLA
   */
  async getTickets(auth, query) {
    const page  = Math.max(1, parseInt(query.page  ?? 1,  10));
    const limit = Math.min(50, Math.max(1, parseInt(query.limit ?? 10, 10)));
    const { status, area_id, vendor_id, sla, q } = query;

    const result = await ticketRepository.findTickets(auth, {
      page,
      limit,
      status,
      area_id,
      vendor_id,
      q,
    });

    // Hitung status SLA untuk setiap tiket
    const dataWithSla = result.data.map(ticket => {
      const slaInfo = getSlaStatus({
        createdAt: ticket.created_at,
        slaDueAt: ticket.sla_due_at,
        resolvedAt: ticket.resolved_at,
      });
      return {
        ...ticket,
        sla_status: slaInfo.status,
        sla_remaining_seconds: slaInfo.remainingSeconds,
      };
    });

    // Jika filter sla disediakan (misal 'at_risk', 'overdue', 'on_track')
    if (sla) {
      const filtered = dataWithSla.filter(t => t.sla_status === sla);
      return {
        data: filtered,
        meta: {
          page,
          limit,
          total: filtered.length,
        },
      };
    }

    return {
      data: dataWithSla,
      meta: result.meta,
    };
  }

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
