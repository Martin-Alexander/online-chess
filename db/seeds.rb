User.create(email: "martingianna@gmail.com", password: "123456")
User.create(email: "player_two@gmail.com", password: "123456")

Player.create(user_id: 1, color: "white")
Player.create(user_id: 2, color: "black")

Game.create( white_id: 1, black_id: 2)

board = [
  [-4, -2, -3, -5, -6, -3, -2, -4],
  [-1, -1, -1, -1, -1, -1, -1, -1],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [1, 1, 1, 1, 1, 1, 1, 1],
  [4, 2, 3, 5, 6, 3, 2, 4]
]

test_board = ""

board = board.flatten

board.each { |i| test_board << "#{i.to_s}," }

test_board[-1] = ""

Board.create(
  game_id: 1,
  ply: 1,
  board_data: test_board,
  white_to_move: true,
  castling: "0000",
  en_passant: "0000"
)
