import pool from '../../config/db.js';

export class DashboardRepository {
  /**
   * Ringkasan tiket untuk tenant:
   * - total_tickets
   * - status_counts (new, forwarded, assigned, in_progress, resolved)
   * - overdue_count (status != 'resolved' AND now > sla_due_at)
   * - avg_resolution_hours (rata-rata durasi resolved_at - created_at dalam jam untuk tiket resolved)
   * - sla_compliance_percentage (persentase tiket resolved dengan resolved_at <= sla_due_at)
   */
  async getSummary(tenantId) {
    const sql = `
      SELECT
        COUNT(*) AS total_tickets,
        SUM(CASE WHEN status = 'new' THEN 1 ELSE 0 END) AS count_new,
        SUM(CASE WHEN status = 'forwarded' THEN 1 ELSE 0 END) AS count_forwarded,
        SUM(CASE WHEN status = 'assigned' THEN 1 ELSE 0 END) AS count_assigned,
        SUM(CASE WHEN status = 'in_progress' THEN 1 ELSE 0 END) AS count_in_progress,
        SUM(CASE WHEN status = 'resolved' THEN 1 ELSE 0 END) AS count_resolved,
        SUM(CASE WHEN status != 'resolved' AND NOW() > sla_due_at THEN 1 ELSE 0 END) AS count_overdue,
        AVG(CASE WHEN status = 'resolved' AND resolved_at IS NOT NULL 
            THEN TIMESTAMPDIFF(SECOND, created_at, resolved_at) / 3600.0 
            ELSE NULL END) AS avg_resolution_hours,
        SUM(CASE WHEN status = 'resolved' AND resolved_at <= sla_due_at THEN 1 ELSE 0 END) AS count_sla_met,
        SUM(CASE WHEN status = 'resolved' THEN 1 ELSE 0 END) AS total_resolved
      FROM tickets
      WHERE tenant_id = ?
    `;

    const [rows] = await pool.query(sql, [tenantId]);
    const row = rows[0] || {};

    const totalResolved = parseInt(row.total_resolved || 0, 10);
    const countSlaMet = parseInt(row.count_sla_met || 0, 10);
    const slaCompliancePercentage = totalResolved > 0
      ? Math.round((countSlaMet / totalResolved) * 1000) / 10 // 1 decimal place, e.g. 85.5
      : 100.0;

    const avgResolutionHours = row.avg_resolution_hours !== null && row.avg_resolution_hours !== undefined
      ? Math.round(parseFloat(row.avg_resolution_hours) * 10) / 10
      : 0.0;

    return {
      total_tickets: parseInt(row.total_tickets || 0, 10),
      by_status: {
        new: parseInt(row.count_new || 0, 10),
        forwarded: parseInt(row.count_forwarded || 0, 10),
        assigned: parseInt(row.count_assigned || 0, 10),
        in_progress: parseInt(row.count_in_progress || 0, 10),
        resolved: parseInt(row.count_resolved || 0, 10),
      },
      overdue_count: parseInt(row.count_overdue || 0, 10),
      avg_resolution_hours: avgResolutionHours,
      sla_compliance_percentage: slaCompliancePercentage,
    };
  }

  /**
   * Rekap gangguan per area
   */
  async getByArea(tenantId) {
    const sql = `
      SELECT
        a.id AS area_id,
        a.name AS area_name,
        COUNT(t.id) AS total_tickets,
        SUM(CASE WHEN t.status = 'resolved' THEN 1 ELSE 0 END) AS resolved_tickets,
        SUM(CASE WHEN t.status != 'resolved' AND t.id IS NOT NULL THEN 1 ELSE 0 END) AS active_tickets
      FROM areas a
      LEFT JOIN tickets t ON t.area_id = a.id AND t.tenant_id = a.tenant_id
      WHERE a.tenant_id = ?
      GROUP BY a.id, a.name
      ORDER BY total_tickets DESC, a.name ASC
    `;

    const [rows] = await pool.query(sql, [tenantId]);
    return rows.map(r => ({
      area_id: r.area_id,
      area_name: r.area_name,
      total_tickets: parseInt(r.total_tickets || 0, 10),
      resolved_tickets: parseInt(r.resolved_tickets || 0, 10),
      active_tickets: parseInt(r.active_tickets || 0, 10),
    }));
  }

  /**
   * Kinerja per vendor
   */
  async getByVendor(tenantId) {
    const sql = `
      SELECT
        v.id AS vendor_id,
        v.name AS vendor_name,
        COUNT(t.id) AS total_tickets,
        SUM(CASE WHEN t.status = 'resolved' THEN 1 ELSE 0 END) AS resolved_tickets,
        AVG(CASE WHEN t.status = 'resolved' AND t.resolved_at IS NOT NULL 
            THEN TIMESTAMPDIFF(SECOND, t.created_at, t.resolved_at) / 3600.0 
            ELSE NULL END) AS avg_resolution_hours,
        SUM(CASE WHEN t.status = 'resolved' AND t.resolved_at <= t.sla_due_at THEN 1 ELSE 0 END) AS sla_met_count,
        SUM(CASE WHEN t.status = 'resolved' AND t.resolved_at > t.sla_due_at THEN 1 ELSE 0 END) AS sla_breached_count
      FROM tenant_vendors tv
      JOIN vendors v ON v.id = tv.vendor_id
      LEFT JOIN tickets t ON t.vendor_id = v.id AND t.tenant_id = tv.tenant_id
      WHERE tv.tenant_id = ? AND tv.status = 'active'
      GROUP BY v.id, v.name
      ORDER BY total_tickets DESC, v.name ASC
    `;

    const [rows] = await pool.query(sql, [tenantId]);
    return rows.map(r => {
      const resolved = parseInt(r.resolved_tickets || 0, 10);
      const slaMet = parseInt(r.sla_met_count || 0, 10);
      const slaCompliance = resolved > 0
        ? Math.round((slaMet / resolved) * 1000) / 10
        : 100.0;

      const avgHours = r.avg_resolution_hours !== null && r.avg_resolution_hours !== undefined
        ? Math.round(parseFloat(r.avg_resolution_hours) * 10) / 10
        : 0.0;

      return {
        vendor_id: r.vendor_id,
        vendor_name: r.vendor_name,
        total_tickets: parseInt(r.total_tickets || 0, 10),
        resolved_tickets: resolved,
        avg_resolution_hours: avgHours,
        sla_compliance_percentage: slaCompliance,
      };
    });
  }
}

export default new DashboardRepository();
