import { DataTypes } from 'sequelize';

export default (sequelize) => {
  const User = sequelize.define(
    'users',
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        autoIncrement: true,
        primaryKey: true,
      },
      email: {
        type: DataTypes.STRING(191),
        allowNull: false,
        unique: true,
      },
      nickname: {
        type: DataTypes.STRING(100),
        allowNull: false,
      },
      password_hash: {
        type: DataTypes.STRING(255),
        allowNull: false,
      },
      score: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0,
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
      tableName: 'users',
      timestamps: true,
      createdAt: 'created_at',
      updatedAt: 'updated_at',
    }
  );

  return User;
};
