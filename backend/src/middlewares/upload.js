import multer from 'multer';
import path from 'path';
import crypto from 'crypto';
import fs from 'fs';
import { config } from '../config/env.js';
import { ValidationError } from '../utils/errors.js';

// Pastikan folder uploads tersedia
const uploadDir = path.resolve(process.cwd(), config.upload.dir);
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    let ext = path.extname(file.originalname).toLowerCase();
    if (!ext) {
      if (file.mimetype === 'image/png') ext = '.png';
      else if (file.mimetype === 'image/jpeg' || file.mimetype === 'image/jpg') ext = '.jpg';
      else ext = '.png'; // Default fallback untuk flutter web blob upload
    }
    const randomName = crypto.randomUUID();
    cb(null, `${randomName}${ext}`);
  },
});

const fileFilter = (req, file, cb) => {
  const allowedExtensions = ['.jpg', '.jpeg', '.png'];
  const ext = path.extname(file.originalname).toLowerCase();
  const mime = (file.mimetype || '').toLowerCase();

  // Validasi:
  // 1. Jika ada ekstensi, pastikan jpg/jpeg/png
  // 2. Jika tidak ada ekstensi (misal upload blob Chrome Web: nama 'blob'), izinkan selama mime image/* atau octet-stream
  const isValidExt = allowedExtensions.includes(ext);
  const isValidMime =
    mime.startsWith('image/') ||
    mime === 'application/octet-stream' ||
    mime === '';

  // Tolak hanya jika ada ekstensi tapi bukan gambar (misal .exe, .pdf) ATAU mime jelas bukan gambar (misal text/plain)
  if (ext && !isValidExt) {
    return cb(
      new ValidationError('Format file foto harus berupa JPG, JPEG, atau PNG', [
        { field: 'photo', message: 'Hanya file JPG, JPEG, dan PNG yang diizinkan' },
      ]),
      false
    );
  }

  if (mime && !isValidMime) {
    return cb(
      new ValidationError('Format file foto harus berupa JPG, JPEG, atau PNG', [
        { field: 'photo', message: 'Hanya file JPG, JPEG, dan PNG yang diizinkan' },
      ]),
      false
    );
  }

  cb(null, true);
};

const maxSizeBytes = config.upload.maxSizeMb * 1024 * 1024;

export const uploadPhotoMiddleware = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: maxSizeBytes,
    files: 1,
  },
});

export function handleMulterError(err, req, res, next) {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return next(
        new ValidationError(`Ukuran file melebihi batas maksimum ${config.upload.maxSizeMb} MB`, [
          { field: 'photo', message: `Maksimal ukuran foto adalah ${config.upload.maxSizeMb} MB` },
        ])
      );
    }
    return next(new ValidationError(err.message, [{ field: 'photo', message: err.message }]));
  }
  next(err);
}
