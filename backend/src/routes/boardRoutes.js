import { Router } from 'express';
import { body, param } from 'express-validator';
import {
  listBoards,
  createBoard,
  updateBoard,
  deleteBoard,
} from '../controllers/boardController.js';
import { authenticate, requireRole } from '../middleware/auth.js';
import validateRequest from '../middleware/validateRequest.js';

const router = Router();

router.get('/', listBoards);

router.post(
  '/',
  authenticate,
  requireRole('admin'),
  [
    body('name').notEmpty().withMessage('Name is required'),
    body('title').notEmpty().withMessage('Title is required'),
  ],
  validateRequest,
  createBoard
);

router.put(
  '/:id',
  authenticate,
  requireRole('admin'),
  [param('id').isInt().withMessage('Board id must be an integer')],
  validateRequest,
  updateBoard
);

router.delete(
  '/:id',
  authenticate,
  requireRole('admin'),
  [param('id').isInt().withMessage('Board id must be an integer')],
  validateRequest,
  deleteBoard
);

export default router;
