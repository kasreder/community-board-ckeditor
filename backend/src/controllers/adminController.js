import { User, Post, Comment, Board } from '../models/index.js';

export const dashboardStats = async (_req, res, next) => {
  try {
    const [userCount, postCount, commentCount, boardCount] = await Promise.all([
      User.count(),
      Post.count(),
      Comment.count(),
      Board.count(),
    ]);

    res.json({
      users: userCount,
      posts: postCount,
      comments: commentCount,
      boards: boardCount,
    });
  } catch (error) {
    next(error);
  }
};

export const listUsers = async (_req, res, next) => {
  try {
    const users = await User.findAll({
      attributes: ['id', 'name', 'email', 'role', 'avatar_url', 'created_at'],
      order: [['created_at', 'DESC']],
    });
    res.json({ users });
  } catch (error) {
    next(error);
  }
};

export const updateUserRole = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { role } = req.body;
    const user = await User.findByPk(id);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.role = role;
    await user.save();
    res.json({ user });
  } catch (error) {
    next(error);
  }
};

export const deleteUser = async (req, res, next) => {
  try {
    const { id } = req.params;
    const user = await User.findByPk(id);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    await user.destroy();
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};

export default {
  dashboardStats,
  listUsers,
  updateUserRole,
  deleteUser,
};
