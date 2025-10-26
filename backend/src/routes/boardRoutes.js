import { Router } from 'express';
import { body, param, query } from 'express-validator';
import {
  listBoards,
  createBoard,
  updateBoard,
  deleteBoard,
} from '../controllers/boardController.js';
import { listBoardPosts, createBoardPost } from '../controllers/postController.js';
import validateRequest from '../middleware/validateRequest.js';

const router = Router();

router.get('/', listBoards);

router.post(
  '/',
  [
    body('name').notEmpty().withMessage('name is required'),
    body('slug').notEmpty().withMessage('slug is required'),
    body('type')
      .optional()
      .isIn(['news', 'lab', 'free', 'custom'])
      .withMessage('type must be one of news, lab, free, custom'),
    body('is_private').optional().isBoolean(),
    body('is_hidden').optional().isBoolean(),
    body('order_no').optional().isInt(),
    body('settings').optional().isObject(),
    body('created_by').optional().isInt(),
  ],
  validateRequest,
  createBoard
);

router.put(
  '/:id',
  [
    param('id').isInt().withMessage('id must be an integer'),
    body('type')
      .optional()
      .isIn(['news', 'lab', 'free', 'custom'])
      .withMessage('type must be one of news, lab, free, custom'),
    body('is_private').optional().isBoolean(),
    body('is_hidden').optional().isBoolean(),
    body('order_no').optional().isInt(),
    body('settings').optional().isObject(),
  ],
  validateRequest,
  updateBoard
);

router.delete('/:id', [param('id').isInt().withMessage('id must be an integer')], validateRequest, deleteBoard);

router.get(
  '/:slug/posts',
  [
    param('slug').notEmpty().withMessage('slug is required'),
    query('page').optional().isInt({ min: 1 }),
    query('limit').optional().isInt({ min: 1, max: 50 }),
    query('sort')
      .optional()
      .isIn(['latest', 'popular', 'commented'])
      .withMessage('sort must be latest, popular or commented'),
  ],
  validateRequest,
  listBoardPosts
);

router.post(
  '/:slug/posts',
  [
    param('slug').notEmpty().withMessage('slug is required'),
    body('author_id').isInt().withMessage('author_id is required'),
    body('title').notEmpty().withMessage('title is required'),
    body('content').notEmpty().withMessage('content is required'),
    body('status')
      .optional()
      .isIn(['draft', 'published', 'archived'])
      .withMessage('status must be draft, published or archived'),
    body('is_pinned').optional().isBoolean(),
    body('published_at').optional().isISO8601(),
    body('tags').optional(),
  ],
  validateRequest,
  createBoardPost
);

export default router;
