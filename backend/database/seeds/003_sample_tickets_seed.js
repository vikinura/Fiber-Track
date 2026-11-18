export async function seedSampleTickets(connection) {
  console.log('[SEED] Seeding sample tickets in various statuses and SLAs...');

  // Sample tickets for Tenant 1 (Nusa Fiber) and Tenant 2
  // We use fixed dates relative to CURRENT_TIMESTAMP or fixed offsets to guarantee SLA conditions:
  // Ticket 101: status 'new', on_track (created recently, critical 4h SLA)
  // Ticket 102: status 'forwarded', at_risk (created 7 hours ago with 8h SLA -> remaining 1h <= 25%)
  // Ticket 103: status 'assigned', overdue (created 10 hours ago with 8h SLA -> overdue by 2h)
  // Ticket 104: status 'in_progress', at_risk (created 3 hours ago with 4h SLA -> remaining 1h = 25%)
  // Ticket 105: status 'resolved', met (created 5 hours ago, 8h SLA, resolved at 2 hours ago -> resolved in 3h <= 8h)
  // Ticket 106: status 'resolved', breached (created 20 hours ago, 8h SLA, resolved at 2 hours ago -> resolved in 18h > 8h)
  // Ticket 107: Tenant 1, Area 2, status 'in_progress', on_track
  // Ticket 108: Tenant 2, Area 3, status 'new', on_track

  await connection.query(`
    INSERT INTO tickets (
      id, tenant_id, ticket_no, customer_id, area_id, odp_id, issue_type_id,
      priority_id, vendor_id, technician_id, created_by, status,
      description, latitude, longitude, sla_due_at, resolved_at, created_at
    ) VALUES
      (
        101, 1, 'TKT-20261118-0101', 1, 1, 1, 1,
        1, NULL, NULL, 2, 'new',
        'Kabel dropcore putus tertimpa dahan pohon di depan kantor',
        -7.2625000, 112.7483000,
        DATE_ADD(NOW(), INTERVAL 3 HOUR), NULL, DATE_SUB(NOW(), INTERVAL 1 HOUR)
      ),
      (
        102, 1, 'TKT-20261118-0102', 2, 1, 2, 2,
        2, 1, NULL, 2, 'forwarded',
        'Redaman optik naik drastis menjadi -29 dBm, koneksi sering putus-nyambung',
        -7.2650000, 112.7510000,
        DATE_ADD(NOW(), INTERVAL 1 HOUR), NULL, DATE_SUB(NOW(), INTERVAL 7 HOUR)
      ),
      (
        103, 1, 'TKT-20261118-0103', 1, 1, 1, 3,
        2, 1, 5, 2, 'assigned',
        'Perangkat ONT mati total setelah tersambar petir semalam',
        -7.2625000, 112.7483000,
        DATE_SUB(NOW(), INTERVAL 2 HOUR), NULL, DATE_SUB(NOW(), INTERVAL 10 HOUR)
      ),
      (
        104, 1, 'TKT-20261118-0104', 3, 2, 3, 1,
        1, 1, 5, 2, 'in_progress',
        'Indikator LOS merah berkedip sejak pagi, pelanggan butuh penanganan segera',
        -7.2800000, 112.7850000,
        DATE_ADD(NOW(), INTERVAL 45 MINUTE), NULL, DATE_SUB(NOW(), INTERVAL 3 HOUR)
      ),
      (
        105, 1, 'TKT-20261118-0105', 2, 1, 2, 2,
        2, 1, 5, 2, 'resolved',
        'Splicing ulang konektor pigtail di OTB pelanggan',
        -7.2650000, 112.7510000,
        DATE_SUB(NOW(), INTERVAL 4 HOUR), DATE_SUB(NOW(), INTERVAL 6 HOUR), DATE_SUB(NOW(), INTERVAL 12 HOUR)
      ),
      (
        106, 1, 'TKT-20261118-0106', 3, 2, 3, 1,
        2, 2, 7, 2, 'resolved',
        'Penarikan kabel baru melintasi jalan raya utama memerlukan izin dinas',
        -7.2800000, 112.7850000,
        DATE_SUB(NOW(), INTERVAL 16 HOUR), DATE_SUB(NOW(), INTERVAL 2 HOUR), DATE_SUB(NOW(), INTERVAL 24 HOUR)
      ),
      (
        107, 1, 'TKT-20261118-0107', 3, 2, 3, 2,
        3, 2, 7, 2, 'in_progress',
        'Pengecekan redaman tinggi sepanjang 500 meter segmen Galaxy',
        -7.2800000, 112.7850000,
        DATE_ADD(NOW(), INTERVAL 18 HOUR), NULL, DATE_SUB(NOW(), INTERVAL 6 HOUR)
      ),
      (
        108, 2, 'TKT-20261118-0108', 4, 3, 4, 4,
        6, 2, NULL, 3, 'new',
        'Laporan gangguan kabel putus di kawasan industri Waru',
        -7.3600000, 112.7300000,
        DATE_ADD(NOW(), INTERVAL 10 HOUR), NULL, DATE_SUB(NOW(), INTERVAL 2 HOUR)
      )
    ON DUPLICATE KEY UPDATE
      tenant_id = VALUES(tenant_id),
      ticket_no = VALUES(ticket_no),
      customer_id = VALUES(customer_id),
      area_id = VALUES(area_id),
      odp_id = VALUES(odp_id),
      issue_type_id = VALUES(issue_type_id),
      priority_id = VALUES(priority_id),
      vendor_id = VALUES(vendor_id),
      technician_id = VALUES(technician_id),
      status = VALUES(status),
      description = VALUES(description),
      sla_due_at = VALUES(sla_due_at),
      resolved_at = VALUES(resolved_at),
      created_at = VALUES(created_at);
  `);

  // Histori sampel
  await connection.query(`
    INSERT INTO ticket_histories (id, ticket_id, user_id, from_status, to_status, note, created_at)
    VALUES
      (101, 101, 2, NULL, 'new', 'Tiket dibuat', DATE_SUB(NOW(), INTERVAL 1 HOUR)),
      (102, 102, 2, NULL, 'new', 'Tiket dibuat', DATE_SUB(NOW(), INTERVAL 7 HOUR)),
      (103, 102, 2, 'new', 'forwarded', 'Tiket diteruskan ke PT Mitra Solusi Optik', DATE_SUB(NOW(), INTERVAL 6 HOUR)),
      (104, 103, 2, 'new', 'forwarded', 'Tiket diteruskan ke PT Mitra Solusi Optik', DATE_SUB(NOW(), INTERVAL 9 HOUR)),
      (105, 103, 4, 'forwarded', 'assigned', 'Tiket ditugaskan ke Teknisi Doni MSO', DATE_SUB(NOW(), INTERVAL 8 HOUR)),
      (106, 104, 5, 'assigned', 'in_progress', 'Teknisi tiba di lokasi pelanggan', DATE_SUB(NOW(), INTERVAL 2 HOUR)),
      (107, 105, 5, 'in_progress', 'resolved', 'Penyambungan kabel selesai, redaman -18 dBm', DATE_SUB(NOW(), INTERVAL 6 HOUR)),
      (108, 106, 7, 'in_progress', 'resolved', 'Pekerjaan selesai setelah penarikan kabel pengganti', DATE_SUB(NOW(), INTERVAL 2 HOUR))
    ON DUPLICATE KEY UPDATE
      ticket_id = VALUES(ticket_id),
      user_id = VALUES(user_id),
      from_status = VALUES(from_status),
      to_status = VALUES(to_status),
      note = VALUES(note),
      created_at = VALUES(created_at);
  `);

  console.log('[SEED] Sample tickets seeded successfully.');
}
