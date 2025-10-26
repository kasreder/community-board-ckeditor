import path from 'path';
import dotenv from 'dotenv';
import { File } from '../models/index.js';

dotenv.config();

const buildFileUrl = (filename, req) => {
  const baseUrl = process.env.APP_URL || `${req.protocol}://${req.get('host')}`;
  return `${baseUrl.replace(/\/$/, '')}/${filename}`;
};

export const uploadFile = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'File not provided' });
    }

    const publicPath = path.posix.join('uploads', req.file.filename);
    const file = await File.create({
      file_url: publicPath,
      file_type: req.file.mimetype,
      size: req.file.size,
    });

    res.status(201).json({
      id: file.id,
      url: buildFileUrl(publicPath, req),
    });
  } catch (error) {
    next(error);
  }
};

export default {
  uploadFile,
};
