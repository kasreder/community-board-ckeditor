import { Router } from 'express';
import { body, param } from 'express-validator';
import { createComment } from '../controllers/commentController.js';
import validateRequest from '../middleware/validateRequest.js';

const router = Router({ mergeParams: true });

router.post(
  '/',
  [
    param('postId').isInt().withMessage('postId must be an integer'),
    body('author_id').isInt().withMessage('author_id is required'),
    body('content').notEmpty().withMessage('content is required'),
  ],
  validateRequest,
  createComment
);

export default router;
