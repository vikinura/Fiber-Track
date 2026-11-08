import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import pool from './config/db.js';
import { errorHandler } from './middlewares/errorHandler.js';
import authRoutes from './modules/auth/auth.routes.js';

const app = express();

// Security middlewares
app.use(helmet());
app.use(cors({
  origin: '*', // can be restricted to specific frontend origins or allow local emulator
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', async (req, res) => {
  let dbStatus = 'disconnected';
  let dbError = null;

  try {
    const [rows] = await pool.query('SELECT 1 AS connected');
    if (rows && rows[0]?.connected === 1) {
      dbStatus = 'connected';
    }
  } catch (err) {
    dbError = err.message;
  }

  const isHealthy = dbStatus === 'connected';

  res.status(isHealthy ? 200 : 503).json({
    status: isHealthy ? 'ok' : 'degraded',
    database: dbStatus,
    ...(dbError && { error: dbError }),
    timestamp: new Date().toISOString(),
  });
});

// API routes prefix /api/v1
app.use('/api/v1/auth', authRoutes);

// Centralized error handler
app.use(errorHandler);

export default app;
