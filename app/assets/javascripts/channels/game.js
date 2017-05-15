App.game = App.cable.subscriptions.create("GameChannel", {
  connected: function() {},
  disconnected: function() {},
  received: function(data) {
   	if (gameId == data.game_id) {
	    drawBoard(data.board_data.split(","));
	    white_to_move = data.white_to_move;
  	}
  }
});