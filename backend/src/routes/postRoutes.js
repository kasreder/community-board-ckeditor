import { Router } from 'express';
import { body, param, query } from 'express-validator';
import {
  listPosts,
  getPostById,
  createPost,
  updatePost,
  deletePost,
  toggleLike,
} from '../controllers/postController.js';
import { authenticate } from '../middleware/auth.js';
import validateRequest from '../middleware/validateRequest.js';

const router = Router();

router.get(
  '/',
  [
    query('page').optional().isInt({ min: 1 }),
    query('limit').optional().isInt({ min: 1, max: 50 }),
  ],
  validateRequest,
  listPosts
);

router.get('/:id', [param('id').isInt()], validateRequest, getPostById);

router.post(
  '/',
  authenticate,
  [
    body('board_id').isInt().withMessage('board_id is required'),
    body('title').notEmpty().withMessage('Title is required'),
    body('content').notEmpty().withMessage('Content is required'),
  ],
  validateRequest,
  createPost
);

router.put(
  '/:id',
  authenticate,
  [
    param('id').isInt(),
    body('title').notEmpty().withMessage('Title is required'),
    body('content').notEmpty().withMessage('Content is required'),
  ],
  validateRequest,
  updatePost
);

router.delete('/:id', authenticate, [param('id').isInt()], validateRequest, deletePost);

router.post(
  '/:id/like',
  authenticate,
  [param('id').isInt()],
  validateRequest,
  toggleLike
);

export default router;
