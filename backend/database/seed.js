import pool from '../src/config/db.js';
import { seedCore } from './seeds/001_core_seed.js';

async function runSeed() {
  console.log('--- Starting Database Seeder ---');
  let connection;
  try {
    connection = await pool.getConnection();
    await connection.beginTransaction();

    await seedCore(connection);

    // If seedMaster exists, run it
    try {
      const { seedMaster } = await import('./seeds/002_master_seed.js');
      if (typeof seedMaster === 'function') {
        await seedMaster(connection);
      }
    } catch (e) {
      // 002_master_seed might not exist yet during T08
      if (e.code !== 'ERR_MODULE_NOT_FOUND') {
        throw e;
      }
    }

    await connection.commit();
    console.log('--- Database Seeding Completed Successfully ---');
  } catch (error) {
    if (connection) await connection.rollback();
    console.error('Seeding failed:', error);
    process.exit(1);
  } finally {
    if (connection) connection.release();
    await pool.end();
  }
}

runSeed();
