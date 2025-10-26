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

// Associations
User.hasMany(Post, { foreignKey: 'user_id' });
Post.belongsTo(User, { foreignKey: 'user_id' });

User.hasMany(Comment, { foreignKey: 'user_id' });
Comment.belongsTo(User, { foreignKey: 'user_id' });

Board.hasMany(Post, { foreignKey: 'board_id' });
Post.belongsTo(Board, { foreignKey: 'board_id' });

Post.hasMany(Comment, { foreignKey: 'post_id', onDelete: 'CASCADE' });
Comment.belongsTo(Post, { foreignKey: 'post_id' });

Post.hasMany(File, { foreignKey: 'post_id' });
File.belongsTo(Post, { foreignKey: 'post_id' });

export default {
  sequelize,
  User,
  Board,
  Post,
  Comment,
  File,
};
