import { Comment, Post, User } from '../models/index.js';
import sanitizeRichText from '../utils/sanitizer.js';

export const listComments = async (req, res, next) => {
  try {
    const { postId } = req.params;
    const comments = await Comment.findAll({
      where: { post_id: postId },
      order: [['created_at', 'ASC']],
      include: [
        {
          model: User,
          attributes: ['id', 'name', 'avatar_url'],
        },
      ],
    });
    res.json({ comments });
  } catch (error) {
    next(error);
  }
};

export const createComment = async (req, res, next) => {
  try {
    const { postId } = req.params;
    const { content } = req.body;

    const post = await Post.findByPk(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    const comment = await Comment.create({
      post_id: postId,
      user_id: req.user.id,
      content: sanitizeRichText(content),
    });

    const created = await Comment.findByPk(comment.id, {
      include: [
        {
          model: User,
          attributes: ['id', 'name', 'avatar_url'],
        },
      ],
    });

    res.status(201).json({ comment: created });
  } catch (error) {
    next(error);
  }
};

export const deleteComment = async (req, res, next) => {
  try {
    const { id } = req.params;
    const comment = await Comment.findByPk(id);

    if (!comment) {
      return res.status(404).json({ message: 'Comment not found' });
    }

    if (comment.user_id !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Forbidden' });
    }

    await comment.destroy();
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};

export default {
  listComments,
  createComment,
  deleteComment,
};
