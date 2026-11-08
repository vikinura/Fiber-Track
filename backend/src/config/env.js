import dotenv from 'dotenv';

dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || '3000', 10),
  db: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306', 10),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'fibertrack',
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'default-secret-key',
    expiresIn: process.env.JWT_EXPIRES_IN || '1d',
  },
  upload: {
    dir: process.env.UPLOAD_DIR || 'uploads',
    maxSizeMb: parseInt(process.env.MAX_UPLOAD_MB || '5', 10),
  },
};
