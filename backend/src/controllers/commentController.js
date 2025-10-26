import sequelize from '../config/database.js';
import { Comment, Post, User } from '../models/index.js';
import sanitizeRichText from '../utils/sanitizer.js';

export const createComment = async (req, res, next) => {
  try {
    const { postId } = req.params;
    const { author_id, content } = req.body;

    const post = await Post.findByPk(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    const author = await User.findByPk(author_id);
    if (!author) {
      return res.status(422).json({ message: 'Author not found' });
    }

    const sanitized = sanitizeRichText(content);

    const createdComment = await sequelize.transaction(async (transaction) => {
      const comment = await Comment.create(
        {
          post_id: post.id,
          author_id: author.id,
          content: sanitized,
        },
        { transaction }
      );

      await author.increment({ score: 1 }, { transaction });
      return comment;
    });

    const comment = await Comment.findByPk(createdComment.id, {
      include: [
        {
          model: User,
          as: 'author',
          attributes: ['id', 'nickname', 'score'],
        },
      ],
    });

    res.status(201).json({ comment });
  } catch (error) {
    next(error);
  }
};

export default {
  createComment,
};
