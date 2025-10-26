import sequelize from '../config/database.js';
import '../models/index.js';

(async () => {
  try {
    await sequelize.sync({ force: true });
    console.log('Database synchronized');
    process.exit(0);
  } catch (error) {
    console.error('Sync failed', error);
    process.exit(1);
  }
})();
