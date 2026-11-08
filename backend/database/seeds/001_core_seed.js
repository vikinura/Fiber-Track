import bcrypt from 'bcrypt';

export async function seedCore(connection) {
  console.log('[SEED] Seeding tenants, vendors, relations, and users...');

  // Tenants
  await connection.query(`
    INSERT INTO tenants (id, name, code, status, created_at)
    VALUES 
      (1, 'Nusa Fiber Prima', 'NUSA', 'active', NOW()),
      (2, 'Lintas Data Nusantara', 'LDN', 'active', NOW())
    ON DUPLICATE KEY UPDATE 
      name = VALUES(name),
      code = VALUES(code),
      status = VALUES(status);
  `);

  // Vendors
  await connection.query(`
    INSERT INTO vendors (id, name, contact_person, phone, status, created_at)
    VALUES 
      (1, 'PT Mitra Solusi Optik', 'Budi Santoso', '081234567890', 'active', NOW()),
      (2, 'PT Cepat Tanggap Jaringan', 'Siti Rahma', '081987654321', 'active', NOW())
    ON DUPLICATE KEY UPDATE 
      name = VALUES(name),
      contact_person = VALUES(contact_person),
      phone = VALUES(phone),
      status = VALUES(status);
  `);

  // Tenant Vendors relation
  await connection.query(`
    INSERT INTO tenant_vendors (id, tenant_id, vendor_id, status, created_at)
    VALUES 
      (1, 1, 1, 'active', NOW()),
      (2, 1, 2, 'active', NOW()),
      (3, 2, 2, 'active', NOW())
    ON DUPLICATE KEY UPDATE 
      status = VALUES(status);
  `);

  // Password hashing: 'Password123!'
  const defaultPassword = 'Password123!';
  const passwordHash = await bcrypt.hash(defaultPassword, 10);

  // Users:
  // 1: Super Admin (no tenant, no vendor)
  // 2: Tenant Admin (Tenant 1)
  // 3: Tenant Admin (Tenant 2)
  // 4: Vendor Admin (Vendor 1)
  // 5: Technician (Vendor 1)
  // 6: Vendor Admin (Vendor 2)
  // 7: Technician (Vendor 2)
  await connection.query(`
    INSERT INTO users (id, tenant_id, vendor_id, name, email, password_hash, phone, role, is_active, created_at)
    VALUES
      (1, NULL, NULL, 'Super Admin', 'superadmin@fibertrack.id', ?, '0811111111', 'super_admin', true, NOW()),
      (2, 1, NULL, 'Admin Nusa Fiber', 'admin.nusa@fibertrack.id', ?, '0822222222', 'tenant_admin', true, NOW()),
      (3, 2, NULL, 'Admin Lintas Data', 'admin.ldn@fibertrack.id', ?, '0833333333', 'tenant_admin', true, NOW()),
      (4, NULL, 1, 'Vendor Admin MSO', 'vendor.mso@fibertrack.id', ?, '0844444444', 'vendor_admin', true, NOW()),
      (5, NULL, 1, 'Teknisi Doni MSO', 'teknisi.doni@fibertrack.id', ?, '0855555555', 'technician', true, NOW()),
      (6, NULL, 2, 'Vendor Admin CTJ', 'vendor.ctj@fibertrack.id', ?, '0866666666', 'vendor_admin', true, NOW()),
      (7, NULL, 2, 'Teknisi Bayu CTJ', 'teknisi.bayu@fibertrack.id', ?, '0877777777', 'technician', true, NOW())
    ON DUPLICATE KEY UPDATE
      name = VALUES(name),
      password_hash = VALUES(password_hash),
      phone = VALUES(phone),
      role = VALUES(role),
      is_active = VALUES(is_active);
  `, [
    passwordHash, passwordHash, passwordHash,
    passwordHash, passwordHash, passwordHash, passwordHash
  ]);

  console.log('[SEED] Core seed completed successfully.');
}
