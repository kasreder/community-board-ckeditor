import { DataTypes } from 'sequelize';

export default (sequelize) => {
  const Board = sequelize.define(
    'boards',
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        autoIncrement: true,
        primaryKey: true,
      },
      name: {
        type: DataTypes.STRING(191),
        allowNull: false,
      },
      slug: {
        type: DataTypes.STRING(191),
        allowNull: false,
        unique: true,
      },
      type: {
        type: DataTypes.ENUM('news', 'lab', 'free', 'custom'),
        allowNull: false,
        defaultValue: 'custom',
      },
      is_private: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
      is_hidden: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
      order_no: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0,
      },
      settings: {
        type: DataTypes.JSON,
        allowNull: true,
      },
      created_by: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: true,
      },
      created_at: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
      updated_at: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      tableName: 'boards',
      timestamps: true,
      createdAt: 'created_at',
      updatedAt: 'updated_at',
    }
  );

  return Board;
};
