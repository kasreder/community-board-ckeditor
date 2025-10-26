import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import path from 'path';
import dotenv from 'dotenv';
import boardRoutes from './routes/boardRoutes.js';
import postRoutes from './routes/postRoutes.js';
import commentRoutes from './routes/commentRoutes.js';
import errorHandler from './middleware/errorHandler.js';

dotenv.config();

const app = express();
app.use(cors({ origin: true, credentials: true }));
app.use(helmet());
app.use(express.json({ limit: '5mb' }));
app.use(express.urlencoded({ extended: true }));

const uploadsPath = path.resolve(process.env.UPLOAD_DIR || path.join(process.cwd(), 'backend', 'uploads'));
app.use('/uploads', express.static(uploadsPath));

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

app.use('/api/boards', boardRoutes);
app.use('/api/posts', postRoutes);
app.use('/api/posts/:postId/comments', commentRoutes);

app.use(errorHandler);

export default app;
