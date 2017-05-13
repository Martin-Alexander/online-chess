User.create(email: "martingianna@gmail.com", password: "123456")
User.create(email: "player_two@gmail.com", password: "123456")

Player.create(user_id: 1, color: "white")
Player.create(user_id: 2, color: "black")

Game.create( white_id: 1, black_id: 2)

std_board = [
  [-4, -2, -3, -5, -6, -3, -2, -4],
  [-1, -1, -1, -1, -1, -1, -1, -1],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [1, 1, 1, 1, 1, 1, 1, 1],
  [4, 2, 3, 5, 6, 3, 2, 4]
]

castling_board = [
  [-4, -2, -3, -5, -6, 0, -2, -4],
  [-1, -1, -1, -1, 0, 0, -1, -1],
  [0, 0, 0, 0, 0, -1, 0, 0],
  [0, 3, 0, 0, -1, 0, 0, 0],
  [0, -3, 0, 0, 1, 0, 0, 0],
  [0, 0, 0, 0, 0, 2, 0, 0],
  [1, 1, 1, 1, 0, 1, 1, 1],
  [4, 2, 3, 5, 6, 0, 0, 4]
]

std_board = castling_board.flatten.join(",")

Board.create(
  game_id: 1,
  ply: 1,
  board_data: test_board,
  white_to_move: true,
  castling: "1111",
  en_passant: "0000"
)
