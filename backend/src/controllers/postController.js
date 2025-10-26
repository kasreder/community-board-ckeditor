import { fn, col, literal } from 'sequelize';
import sequelize from '../config/database.js';
import { Board, Post, User, Comment } from '../models/index.js';
import sanitizeRichText from '../utils/sanitizer.js';

const defaultPostIncludes = [
  {
    model: Board,
    as: 'board',
    attributes: ['id', 'name', 'slug', 'type', 'is_private', 'is_hidden', 'order_no'],
  },
  {
    model: User,
    as: 'author',
    attributes: ['id', 'nickname', 'score'],
  },
];

const commentInclude = {
  model: Comment,
  as: 'comments',
  include: [
    {
      model: User,
      as: 'author',
      attributes: ['id', 'nickname', 'score'],
    },
  ],
  separate: true,
  order: [['created_at', 'ASC']],
};

const viewCache = new Map();
const VIEW_CACHE_TTL_MS = 30 * 60 * 1000;
const MAX_CACHE_SIZE = 5000;

const getViewerKey = (req, postId) => {
  const ip = req.headers['x-forwarded-for']?.split(',')[0]?.trim() || req.ip || 'unknown';
  const userAgent = req.headers['user-agent'] || 'ua';
  return `${ip}:${userAgent}:${postId}`;
};

const shouldRegisterView = (req, postId) => {
  const now = Date.now();
  const key = getViewerKey(req, postId);
  const expiresAt = viewCache.get(key);

  if (expiresAt && expiresAt > now) {
    return false;
  }

  viewCache.set(key, now + VIEW_CACHE_TTL_MS);

  if (viewCache.size > MAX_CACHE_SIZE) {
    for (const [cacheKey, expiry] of viewCache.entries()) {
      if (expiry <= now) {
        viewCache.delete(cacheKey);
      }
    }
  }

  return true;
};

export const listBoardPosts = async (req, res, next) => {
  try {
    const { slug } = req.params;
    const { page = '1', limit = '10', sort = 'latest' } = req.query;

    const board = await Board.findOne({ where: { slug } });
    if (!board) {
      return res.status(404).json({ message: 'Board not found' });
    }

    const pageNumber = Math.max(parseInt(page, 10) || 1, 1);
    const pageSize = Math.max(Math.min(parseInt(limit, 10) || 10, 50), 1);
    const offset = (pageNumber - 1) * pageSize;

    const baseOrder = [[col('posts.is_pinned'), 'DESC']];
    if (sort === 'popular') {
      baseOrder.push([col('posts.view_count'), 'DESC']);
    } else if (sort === 'commented') {
      baseOrder.push([literal('comment_count'), 'DESC']);
    } else {
      baseOrder.push(['published_at', 'DESC']);
      baseOrder.push(['created_at', 'DESC']);
    }

    const posts = await Post.findAndCountAll({
      where: { board_id: board.id },
      include: [
        ...defaultPostIncludes,
        {
          model: Comment,
          as: 'comments',
          attributes: [],
        },
      ],
      attributes: {
        include: [[fn('COUNT', col('comments.id')), 'comment_count']],
      },
      group: ['posts.id', 'board.id', 'author.id'],
      limit: pageSize,
      offset,
      order: baseOrder,
      distinct: true,
      subQuery: false,
    });

    const items = Array.isArray(posts.rows) ? posts.rows : [posts.rows];
    const total = Array.isArray(posts.count) ? posts.count.length : posts.count;

    res.json({
      board,
      total,
      page: pageNumber,
      pageSize,
      items,
    });
  } catch (error) {
    next(error);
  }
};

export const createBoardPost = async (req, res, next) => {
  try {
    const { slug } = req.params;
    const board = await Board.findOne({ where: { slug } });

    if (!board) {
      return res.status(404).json({ message: 'Board not found' });
    }

    const author = await User.findByPk(req.body.author_id);
    if (!author) {
      return res.status(422).json({ message: 'Author not found' });
    }

    const sanitizedContent = sanitizeRichText(req.body.content);

    const createdPost = await sequelize.transaction(async (transaction) => {
      const post = await Post.create(
        {
          board_id: board.id,
          author_id: author.id,
          title: req.body.title,
          content: sanitizedContent,
          status: req.body.status ?? 'published',
          published_at: req.body.published_at ?? null,
          is_pinned: req.body.is_pinned ?? false,
          thumbnail_url: req.body.thumbnail_url ?? null,
          tags: req.body.tags ?? null,
        },
        { transaction }
      );

      await author.increment({ score: 10 }, { transaction });
      return post;
    });

    const post = await Post.findByPk(createdPost.id, {
      include: defaultPostIncludes,
    });

    res.status(201).json({ post });
  } catch (error) {
    next(error);
  }
};

export const getPostById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const post = await Post.findByPk(id, {
      include: [...defaultPostIncludes, commentInclude],
    });

    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    if (shouldRegisterView(req, post.id)) {
      await post.increment('view_count');
      await post.reload({ include: [...defaultPostIncludes, commentInclude] });
    }

    res.json({ post });
  } catch (error) {
    next(error);
  }
};

export const updatePost = async (req, res, next) => {
  try {
    const { id } = req.params;
    const post = await Post.findByPk(id);

    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    await post.update({
      title: req.body.title ?? post.title,
      content: req.body.content ? sanitizeRichText(req.body.content) : post.content,
      status: req.body.status ?? post.status,
      published_at: req.body.published_at ?? post.published_at,
      is_pinned: req.body.is_pinned ?? post.is_pinned,
      thumbnail_url: req.body.thumbnail_url ?? post.thumbnail_url,
      tags: req.body.tags ?? post.tags,
    });

    const updated = await Post.findByPk(id, {
      include: [...defaultPostIncludes, commentInclude],
    });

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

    await post.destroy();
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};

export default {
  listBoardPosts,
  createBoardPost,
  getPostById,
  updatePost,
  deletePost,
};
