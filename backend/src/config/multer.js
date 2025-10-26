import multer from 'multer';
import path from 'path';
import fs from 'fs';
import dotenv from 'dotenv';

dotenv.config();

const uploadDir = path.resolve(process.env.UPLOAD_DIR || path.join(process.cwd(), 'backend', 'uploads'));

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, uploadDir);
  },
  filename: (_req, file, cb) => {
    const timestamp = Date.now();
    const sanitizedOriginal = file.originalname.replace(/[^a-zA-Z0-9.\-_]/g, '_');
    cb(null, `${timestamp}-${sanitizedOriginal}`);
  },
});

const fileFilter = (_req, file, cb) => {
  const allowedTypes = (process.env.ALLOWED_IMAGE_TYPES || '').split(',').filter(Boolean);
  if (allowedTypes.length && !allowedTypes.includes(file.mimetype)) {
    cb(new Error('Unsupported file type'));
    return;
  }
  cb(null, true);
};

export const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: process.env.MAX_UPLOAD_SIZE
      ? Number(process.env.MAX_UPLOAD_SIZE)
      : 5 * 1024 * 1024,
  },
});

export default upload;
