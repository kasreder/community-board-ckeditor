import { Board } from '../models/index.js';

const boardAttributes = [
  'id',
  'name',
  'slug',
  'type',
  'is_private',
  'is_hidden',
  'order_no',
  'settings',
  'created_by',
  'created_at',
  'updated_at',
];

export const listBoards = async (_req, res, next) => {
  try {
    const boards = await Board.findAll({
      attributes: boardAttributes,
      order: [
        ['is_hidden', 'ASC'],
        ['order_no', 'ASC'],
        ['id', 'ASC'],
      ],
    });
    res.json({ boards });
  } catch (error) {
    next(error);
  }
};

export const createBoard = async (req, res, next) => {
  try {
    const payload = {
      name: req.body.name,
      slug: req.body.slug,
      type: req.body.type ?? 'custom',
      is_private: req.body.is_private ?? false,
      is_hidden: req.body.is_hidden ?? false,
      order_no: req.body.order_no ?? 0,
      settings: req.body.settings ?? null,
      created_by: req.body.created_by ?? null,
    };

    const board = await Board.create(payload);
    res.status(201).json({ board });
  } catch (error) {
    next(error);
  }
};

export const updateBoard = async (req, res, next) => {
  try {
    const { id } = req.params;
    const board = await Board.findByPk(id);

    if (!board) {
      return res.status(404).json({ message: 'Board not found' });
    }

    await board.update({
      name: req.body.name ?? board.name,
      slug: req.body.slug ?? board.slug,
      type: req.body.type ?? board.type,
      is_private: req.body.is_private ?? board.is_private,
      is_hidden: req.body.is_hidden ?? board.is_hidden,
      order_no: req.body.order_no ?? board.order_no,
      settings: req.body.settings ?? board.settings,
    });

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
