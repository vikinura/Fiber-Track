import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import pool from '../src/config/db.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const migrationsDir = path.join(__dirname, 'migrations');

async function migrate() {
  console.log('--- Starting Migration Runner ---');
  let connection;
  try {
    connection = await pool.getConnection();

    // Create schema_migrations table if not exists
    await connection.query(`
      CREATE TABLE IF NOT EXISTS schema_migrations (
        id INT AUTO_INCREMENT PRIMARY KEY,
        migration_name VARCHAR(255) NOT NULL UNIQUE,
        executed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    // Get executed migrations
    const [rows] = await connection.query('SELECT migration_name FROM schema_migrations');
    const executedMigrations = new Set(rows.map(r => r.migration_name));

    // Read migration files
    const files = fs.readdirSync(migrationsDir)
      .filter(f => f.endsWith('.sql'))
      .sort();

    for (const file of files) {
      if (executedMigrations.has(file)) {
        console.log(`[SKIPPED] ${file} (already executed)`);
        continue;
      }

      console.log(`[EXECUTING] ${file}...`);
      const filePath = path.join(migrationsDir, file);
      const sqlContent = fs.readFileSync(filePath, 'utf8');

      // Split queries safely by semicolon (excluding empty lines or pure whitespace)
      // Note: we can execute individual statements or multi-statements if configured
      // Or split by semicolon while ignoring comments
      const statements = sqlContent
        .replace(/--.*$/gm, '') // Remove single line comments
        .split(';')
        .map(s => s.trim())
        .filter(s => s.length > 0);

      await connection.beginTransaction();
      try {
        for (const statement of statements) {
          await connection.query(statement);
        }
        await connection.query('INSERT INTO schema_migrations (migration_name) VALUES (?)', [file]);
        await connection.commit();
        console.log(`[SUCCESS] ${file} applied.`);
      } catch (err) {
        await connection.rollback();
        console.error(`[ERROR] Failed to execute ${file}:`, err);
        throw err;
      }
    }

    console.log('--- All migrations finished successfully ---');
  } catch (error) {
    console.error('Migration failed:', error.message);
    process.exit(1);
  } finally {
    if (connection) connection.release();
    await pool.end();
  }
}

migrate();
