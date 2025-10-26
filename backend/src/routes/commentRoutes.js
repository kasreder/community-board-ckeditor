import { Router } from 'express';
import { body, param } from 'express-validator';
import {
  listComments,
  createComment,
  deleteComment,
} from '../controllers/commentController.js';
import { authenticate } from '../middleware/auth.js';
import validateRequest from '../middleware/validateRequest.js';

const router = Router({ mergeParams: true });

router.get('/', [param('postId').isInt()], validateRequest, listComments);

router.post(
  '/',
  authenticate,
  [
    param('postId').isInt(),
    body('content').notEmpty().withMessage('Content is required'),
  ],
  validateRequest,
  createComment
);

router.delete(
  '/:id',
  authenticate,
  [param('postId').isInt(), param('id').isInt()],
  validateRequest,
  deleteComment
);

export default router;
