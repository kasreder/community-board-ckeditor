import { Router } from 'express';
import { body, param } from 'express-validator';
import { getPostById, updatePost, deletePost } from '../controllers/postController.js';
import validateRequest from '../middleware/validateRequest.js';

const router = Router();

router.get('/:id', [param('id').isInt().withMessage('id must be an integer')], validateRequest, getPostById);

router.put(
  '/:id',
  [
    param('id').isInt().withMessage('id must be an integer'),
    body('title').optional().isString(),
    body('content').optional().isString(),
    body('status')
      .optional()
      .isIn(['draft', 'published', 'archived'])
      .withMessage('status must be draft, published or archived'),
    body('is_pinned').optional().isBoolean(),
    body('published_at').optional().isISO8601(),
  ],
  validateRequest,
  updatePost
);

router.delete('/:id', [param('id').isInt().withMessage('id must be an integer')], validateRequest, deletePost);

export default router;
