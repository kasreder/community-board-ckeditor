import { Op, fn, col } from 'sequelize';
import { Post, Board, User, Comment, File } from '../models/index.js';
import sanitizeRichText from '../utils/sanitizer.js';

const includeDefaults = [
  {
    model: User,
    attributes: ['id', 'name', 'avatar_url', 'role'],
  },
  {
    model: Board,
    attributes: ['id', 'name', 'title'],
  },
];

export const listPosts = async (req, res, next) => {
  try {
    const {
      board: boardName,
      sort = 'latest',
      search,
      page = 1,
      limit = 10,
    } = req.query;

    const where = {};

    if (boardName) {
      const board = await Board.findOne({ where: { name: boardName } });
      if (!board) {
        return res.json({ total: 0, page: Number(page), pageSize: Number(limit), items: [] });
      }
      where.board_id = board.id;
    }

    if (search) {
      where[Op.or] = [
        { title: { [Op.like]: `%${search}%` } },
        { content: { [Op.like]: `%${search}%` } },
      ];
    }

    let order;
    switch (sort) {
      case 'popular':
        order = [[col('like_count'), 'DESC']];
        break;
      case 'commented':
        order = [[fn('COUNT', col('comments.id')), 'DESC']];
        break;
      default:
        order = [['created_at', 'DESC']];
    }

    const offset = (Number(page) - 1) * Number(limit);

    const posts = await Post.findAndCountAll({
      where,
      include: [
        ...includeDefaults,
        {
          model: Comment,
          attributes: [],
        },
      ],
      attributes: {
        include: [[fn('COUNT', col('comments.id')), 'comment_count']],
      },
      group: ['posts.id', 'user.id', 'board.id'],
      limit: Number(limit),
      offset,
      order,
      distinct: true,
    });

    const rows = Array.isArray(posts.rows) ? posts.rows : [posts.rows];
    const total = Array.isArray(posts.count) ? posts.count.length : posts.count;

    res.json({
      total,
      page: Number(page),
      pageSize: Number(limit),
      items: rows,
    });
  } catch (error) {
    next(error);
  }
};

export const getPostById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const post = await Post.findByPk(id, {
      include: [
        ...includeDefaults,
        {
          model: Comment,
          include: [
            {
              model: User,
              attributes: ['id', 'name', 'avatar_url'],
            },
          ],
          order: [['created_at', 'ASC']],
        },
        {
          model: File,
        },
      ],
    });

    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    await post.increment('view_count');
    res.json({ post });
  } catch (error) {
    next(error);
  }
};

export const createPost = async (req, res, next) => {
  try {
    const { board_id, title, content, attachments = [] } = req.body;
    const sanitizedContent = sanitizeRichText(content);

    const post = await Post.create({
      board_id,
      user_id: req.user.id,
      title,
      content: sanitizedContent,
    });

    if (attachments.length) {
      await File.update({ post_id: post.id }, { where: { id: attachments } });
    }

    const created = await Post.findByPk(post.id, { include: includeDefaults });
    res.status(201).json({ post: created });
  } catch (error) {
    next(error);
  }
};

export const updatePost = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { title, content, attachments = [] } = req.body;
    const post = await Post.findByPk(id);

    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    if (post.user_id !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Forbidden' });
    }

    await post.update({
      title,
      content: sanitizeRichText(content),
    });

    if (attachments.length) {
      await File.update({ post_id: post.id }, { where: { id: attachments } });
    }

    const updated = await Post.findByPk(id, { include: includeDefaults });
    res.json({ post: updated });
  } catch (error) {
    next(error);
  }
};

export const deletePost = async (req, res, next) => {
  try {
    const { id } = req.params;
    const post = await Post.findByPk(id);

    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    if (post.user_id !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Forbidden' });
    }

    await post.destroy();
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};

export const toggleLike = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { action } = req.body;
    const post = await Post.findByPk(id);

    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    const increment = action === 'decrease' ? -1 : 1;
    await post.increment('like_count', { by: increment });
    await post.reload();
    res.json({ like_count: post.like_count });
  } catch (error) {
    next(error);
  }
};

export default {
  listPosts,
  getPostById,
  createPost,
  updatePost,
  deletePost,
  toggleLike,
};
