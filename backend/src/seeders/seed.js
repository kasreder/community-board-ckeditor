import bcrypt from 'bcryptjs';
import sequelize from '../config/database.js';
import { User, Board } from '../models/index.js';

const boards = [
  { name: 'notice', title: '공지사항', description: '중요한 소식을 전달합니다.' },
  { name: 'free', title: '자유게시판', description: '자유롭게 의견을 나눠보세요.' },
  { name: 'tech', title: '기술게시판', description: '기술 관련 주제를 토론합니다.' },
  { name: 'photo', title: '사진게시판', description: '사진을 공유해보세요.' },
];

const users = [
  {
    name: '관리자',
    email: 'admin@example.com',
    password: 'AdminPass123!@#',
    role: 'admin',
  },
  { name: '홍길동', email: 'hong@example.com', password: 'Password123!', role: 'user' },
  { name: '김영희', email: 'kim@example.com', password: 'Password123!', role: 'user' },
  { name: 'John Doe', email: 'john@example.com', password: 'Password123!', role: 'user' },
];

(async () => {
  try {
    await sequelize.authenticate();
    await sequelize.sync();

    for (const board of boards) {
      await Board.findOrCreate({ where: { name: board.name }, defaults: board });
    }

    for (const user of users) {
      const hashed = await bcrypt.hash(user.password, 10);
      await User.findOrCreate({
        where: { email: user.email },
        defaults: { ...user, password: hashed },
      });
    }

    console.log('Seed completed');
    process.exit(0);
  } catch (error) {
    console.error('Seed failed', error);
    process.exit(1);
  }
})();
