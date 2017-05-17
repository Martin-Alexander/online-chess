User.create(email: "martin", password: "123456", human: true)
User.create(email: "player_two", password: "123456", human: true)

User.create(email: "babyBurger", password: "qwerty", human: false)
User.create(email: "teenBurger", password: "qwerty", human: false)

Game.create( white_id: 1, black_id: 2)

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

test_board = castling_board.flatten.join(",")

Board.create(game_id: 1)
