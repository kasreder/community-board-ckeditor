import { Router } from 'express';
import { uploadFile } from '../controllers/fileController.js';
import { authenticate } from '../middleware/auth.js';
import upload from '../config/multer.js';

const router = Router();

router.post('/upload', authenticate, upload.single('upload'), uploadFile);

export default router;
