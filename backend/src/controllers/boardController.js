import { Board } from '../models/index.js';

export const listBoards = async (_req, res, next) => {
  try {
    const boards = await Board.findAll({ order: [['id', 'ASC']] });
    res.json({ boards });
  } catch (error) {
    next(error);
  }
};

export const createBoard = async (req, res, next) => {
  try {
    const { name, title, description } = req.body;
    const board = await Board.create({ name, title, description });
    res.status(201).json({ board });
  } catch (error) {
    next(error);
  }
};

export const updateBoard = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { name, title, description } = req.body;
    const board = await Board.findByPk(id);

    if (!board) {
      return res.status(404).json({ message: 'Board not found' });
    }

    await board.update({ name, title, description });
    res.json({ board });
  } catch (error) {
    next(error);
  }
};

export const deleteBoard = async (req, res, next) => {
  try {
    const { id } = req.params;
    const board = await Board.findByPk(id);

    if (!board) {
      return res.status(404).json({ message: 'Board not found' });
    }

    await board.destroy();
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};

export default {
  listBoards,
  createBoard,
  updateBoard,
  deleteBoard,
};
