import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';

dotenv.config();

const {
  DATABASE_HOST,
  DATABASE_PORT,
  DATABASE_NAME,
  DATABASE_USER,
  DATABASE_PASSWORD,
  NODE_ENV,
} = process.env;

export const sequelize = new Sequelize(
  DATABASE_NAME || 'community_board',
  DATABASE_USER || 'root',
  DATABASE_PASSWORD || '',
  {
    host: DATABASE_HOST || 'localhost',
    port: DATABASE_PORT ? Number(DATABASE_PORT) : 3306,
    dialect: 'mysql',
    logging: NODE_ENV === 'development' ? console.log : false,
    define: {
      underscored: true,
      freezeTableName: true,
    },
  }
);

export default sequelize;
