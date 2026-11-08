-- Migration 002: Create master tables (areas, odps, customers, issue_types, priorities)

CREATE TABLE IF NOT EXISTS areas (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  CONSTRAINT fk_areas_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS odps (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  area_id BIGINT NOT NULL,
  code VARCHAR(50) NOT NULL,
  latitude DECIMAL(10,7),
  longitude DECIMAL(10,7),
  UNIQUE KEY uq_tenant_odp_code (tenant_id, code),
  CONSTRAINT fk_odps_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  CONSTRAINT fk_odps_area FOREIGN KEY (area_id) REFERENCES areas(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customers (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  area_id BIGINT NULL,
  odp_id BIGINT NULL,
  name VARCHAR(150) NOT NULL,
  address VARCHAR(255),
  phone VARCHAR(30),
  CONSTRAINT fk_customers_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  CONSTRAINT fk_customers_area FOREIGN KEY (area_id) REFERENCES areas(id) ON DELETE SET NULL,
  CONSTRAINT fk_customers_odp FOREIGN KEY (odp_id) REFERENCES odps(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS issue_types (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  name VARCHAR(100) NOT NULL,
  CONSTRAINT fk_issue_types_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS priorities (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  name VARCHAR(50) NOT NULL,
  sla_hours INT NOT NULL,
  CONSTRAINT fk_priorities_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
