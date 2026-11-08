-- Migration 003: Create ticket tables (tickets, ticket_histories, ticket_photos, notifications)

CREATE TABLE IF NOT EXISTS tickets (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  ticket_no VARCHAR(30) NOT NULL,
  customer_id BIGINT NOT NULL,
  area_id BIGINT NOT NULL,
  odp_id BIGINT NULL,
  issue_type_id BIGINT NOT NULL,
  priority_id BIGINT NOT NULL,
  vendor_id BIGINT NULL,
  technician_id BIGINT NULL,
  created_by BIGINT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'new',
  description TEXT,
  latitude DECIMAL(10,7),
  longitude DECIMAL(10,7),
  sla_due_at DATETIME NOT NULL,
  resolved_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tenant_ticket_no (tenant_id, ticket_no),
  INDEX idx_tenant_status (tenant_id, status),
  INDEX idx_tenant_vendor (tenant_id, vendor_id),
  CONSTRAINT fk_tickets_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  CONSTRAINT fk_tickets_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT,
  CONSTRAINT fk_tickets_area FOREIGN KEY (area_id) REFERENCES areas(id) ON DELETE RESTRICT,
  CONSTRAINT fk_tickets_odp FOREIGN KEY (odp_id) REFERENCES odps(id) ON DELETE SET NULL,
  CONSTRAINT fk_tickets_issue_type FOREIGN KEY (issue_type_id) REFERENCES issue_types(id) ON DELETE RESTRICT,
  CONSTRAINT fk_tickets_priority FOREIGN KEY (priority_id) REFERENCES priorities(id) ON DELETE RESTRICT,
  CONSTRAINT fk_tickets_vendor FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE SET NULL,
  CONSTRAINT fk_tickets_technician FOREIGN KEY (technician_id) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_tickets_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ticket_histories (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  ticket_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  from_status VARCHAR(20) NULL,
  to_status VARCHAR(20) NOT NULL,
  note TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_th_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
  CONSTRAINT fk_th_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ticket_photos (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  ticket_id BIGINT NOT NULL,
  uploaded_by BIGINT NOT NULL,
  file_path VARCHAR(255) NOT NULL,
  caption VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_tp_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
  CONSTRAINT fk_tp_user FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS notifications (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  ticket_id BIGINT NULL,
  message VARCHAR(255) NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_notif_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
