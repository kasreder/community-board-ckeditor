import dotenv from 'dotenv';
import app from './app.js';
import sequelize from './config/database.js';

dotenv.config();

const PORT = process.env.PORT ? Number(process.env.PORT) : 4000;

(async () => {
  try {
    await sequelize.authenticate();
    console.log('Database connection established');
    await sequelize.sync();

    app.listen(PORT, () => {
      console.log(`Server listening on port ${PORT}`);
    });
  } catch (error) {
    console.error('Unable to start server', error);
    process.exit(1);
  }
})();
