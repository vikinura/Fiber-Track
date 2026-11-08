export async function seedMaster(connection) {
  console.log('[SEED] Seeding master data (areas, odps, issue_types, priorities, customers)...');

  // Areas
  // Tenant 1 (Nusa Fiber)
  // Tenant 2 (Lintas Data)
  await connection.query(`
    INSERT INTO areas (id, tenant_id, name, description)
    VALUES
      (1, 1, 'Surabaya Pusat', 'Area pusat bisnis dan komersial Surabaya'),
      (2, 1, 'Surabaya Timur', 'Area perumahan dan kampus Surabaya Timur'),
      (3, 2, 'Sidoarjo Utara', 'Area industri dan perumahan Waru - Gedangan')
    ON DUPLICATE KEY UPDATE
      tenant_id = VALUES(tenant_id),
      name = VALUES(name),
      description = VALUES(description);
  `);

  // ODPs
  await connection.query(`
    INSERT INTO odps (id, tenant_id, area_id, code, latitude, longitude)
    VALUES
      (1, 1, 1, 'ODP-SBP-01', -7.2625000, 112.7483000),
      (2, 1, 1, 'ODP-SBP-02', -7.2650000, 112.7510000),
      (3, 1, 2, 'ODP-SBT-01', -7.2800000, 112.7850000),
      (4, 2, 3, 'ODP-SDU-01', -7.3600000, 112.7300000)
    ON DUPLICATE KEY UPDATE
      tenant_id = VALUES(tenant_id),
      area_id = VALUES(area_id),
      code = VALUES(code),
      latitude = VALUES(latitude),
      longitude = VALUES(longitude);
  `);

  // Issue Types
  await connection.query(`
    INSERT INTO issue_types (id, tenant_id, name)
    VALUES
      (1, 1, 'Kabel Putus / LOS'),
      (2, 1, 'Redaman Tinggi'),
      (3, 1, 'Modem / ONT Rusak'),
      (4, 2, 'Kabel Putus / LOS'),
      (5, 2, 'Koneksi Lambat')
    ON DUPLICATE KEY UPDATE
      tenant_id = VALUES(tenant_id),
      name = VALUES(name);
  `);

  // Priorities with SLA hours
  await connection.query(`
    INSERT INTO priorities (id, tenant_id, name, sla_hours)
    VALUES
      (1, 1, 'Kritis', 4),
      (2, 1, 'Tinggi', 8),
      (3, 1, 'Sedang', 24),
      (4, 1, 'Rendah', 48),
      (5, 2, 'Kritis', 4),
      (6, 2, 'Tinggi', 12),
      (7, 2, 'Normal', 24)
    ON DUPLICATE KEY UPDATE
      tenant_id = VALUES(tenant_id),
      name = VALUES(name),
      sla_hours = VALUES(sla_hours);
  `);

  // Customers
  await connection.query(`
    INSERT INTO customers (id, tenant_id, area_id, odp_id, name, address, phone)
    VALUES
      (1, 1, 1, 1, 'PT Megah Informatika', 'Jl. Pemuda No. 45, Surabaya', '081211112222'),
      (2, 1, 1, 2, 'Cafe Kopi Senja', 'Jl. Basuki Rahmat No. 12, Surabaya', '081233334444'),
      (3, 1, 2, 3, 'Bapak Hendra Setiawan', 'Perumahan Galaxy Bumi Permai F-15, Surabaya', '081255556666'),
      (4, 2, 3, 4, 'CV Maju Jaya Logistik', 'Jl. Raya Waru No. 88, Sidoarjo', '081277778888')
    ON DUPLICATE KEY UPDATE
      tenant_id = VALUES(tenant_id),
      area_id = VALUES(area_id),
      odp_id = VALUES(odp_id),
      name = VALUES(name),
      address = VALUES(address),
      phone = VALUES(phone);
  `);

  console.log('[SEED] Master data seed completed successfully.');
}
