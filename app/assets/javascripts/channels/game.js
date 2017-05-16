App.game = App.cable.subscriptions.create("GameChannel", {
  connected: function() {},
  disconnected: function() {},
  received: function(data) {
   	if (gameId == data.game_id) {
	    drawBoard(data.board_data.split(","));
	    whiteToMove = data.white_to_move;
  	}
  }
});