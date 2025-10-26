import { Router } from 'express';
import { body, param } from 'express-validator';
import {
  dashboardStats,
  listUsers,
  updateUserRole,
  deleteUser,
} from '../controllers/adminController.js';
import { authenticate, requireRole } from '../middleware/auth.js';
import validateRequest from '../middleware/validateRequest.js';

const router = Router();

router.use(authenticate, requireRole('admin'));

router.get('/stats', dashboardStats);
router.get('/users', listUsers);
router.put(
  '/users/:id/role',
  [param('id').isInt(), body('role').isIn(['user', 'admin'])],
  validateRequest,
  updateUserRole
);
router.delete('/users/:id', [param('id').isInt()], validateRequest, deleteUser);

export default router;
