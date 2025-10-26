import sequelize from '../config/database.js';
import UserModel from './user.js';
import BoardModel from './board.js';
import PostModel from './post.js';
import CommentModel from './comment.js';
import FileModel from './file.js';

export const User = UserModel(sequelize);
export const Board = BoardModel(sequelize);
export const Post = PostModel(sequelize);
export const Comment = CommentModel(sequelize);
export const File = FileModel(sequelize);

User.hasMany(Post, { foreignKey: 'author_id', as: 'posts' });
Post.belongsTo(User, { foreignKey: 'author_id', as: 'author' });

User.hasMany(Comment, { foreignKey: 'author_id', as: 'comments' });
Comment.belongsTo(User, { foreignKey: 'author_id', as: 'author' });

Board.hasMany(Post, { foreignKey: 'board_id', as: 'posts' });
Post.belongsTo(Board, { foreignKey: 'board_id', as: 'board' });

Post.hasMany(Comment, { foreignKey: 'post_id', as: 'comments', onDelete: 'CASCADE' });
Comment.belongsTo(Post, { foreignKey: 'post_id', as: 'post' });

Post.hasMany(File, { foreignKey: 'post_id', as: 'attachments' });
File.belongsTo(Post, { foreignKey: 'post_id', as: 'post' });

export default {
  sequelize,
  User,
  Board,
  Post,
  Comment,
  File,
};
