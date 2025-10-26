import bcrypt from 'bcryptjs';
import sequelize from '../config/database.js';
import { User, Board } from '../models/index.js';

const boards = [
  { name: '뉴스게시판', slug: 'news', type: 'news', order_no: 10 },
  { name: '실험게시판', slug: 'lab', type: 'lab', order_no: 20 },
  { name: '자유게시판', slug: 'free', type: 'free', order_no: 30 },
];

const users = [
  {
    email: 'admin@example.com',
    nickname: '관리자',
    password: 'AdminPass123!@#',
  },
  {
    email: 'writer@example.com',
    nickname: '글쓴이',
    password: 'WriterPass123!@#',
  },
];

(async () => {
  try {
    await sequelize.authenticate();
    await sequelize.sync();

    for (const board of boards) {
      await Board.findOrCreate({
        where: { slug: board.slug },
        defaults: board,
      });
    }

    for (const user of users) {
      const password_hash = await bcrypt.hash(user.password, 10);
      await User.findOrCreate({
        where: { email: user.email },
        defaults: {
          email: user.email,
          nickname: user.nickname,
          password_hash,
        },
      });
    }

    console.log('Seed completed');
    process.exit(0);
  } catch (error) {
    console.error('Seed failed', error);
    process.exit(1);
  }
})();
