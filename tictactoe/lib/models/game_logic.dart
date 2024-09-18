import 'dart:math';
import '../models/reinforcement_bot.dart';

class GameLogic {
  List<List<String>> board =
      List.generate(3, (_) => List.generate(3, (_) => ' '));
  String currentPlayer = 'H'; // 'H' for Human, 'X' for Bot1, 'O' for Bot2
  bool gameOver = false;
  String winner = '';
  final ReinforcementBot bot1; // Bot1 is always 'X'
  final ReinforcementBot bot2; // Bot2 is always 'O'
  final Random random = Random();
  bool humanGoesFirst = true;

  GameLogic(this.bot1, this.bot2);

  // Determine which bot the human is playing against
  void botMove({required Function() setStateCallback}) {
    if (gameOver) return;

    // Bot1 (X) or Bot2 (O) makes a move based on whether human goes first or second
    if (!humanGoesFirst && currentPlayer == 'X') {
      bot1.makeMove(board, allowExploration: false); // Bot1 makes its move
    } else if (humanGoesFirst && currentPlayer == 'O') {
      bot2.makeMove(board, allowExploration: false); // Bot2 makes its move
    }

    // Check game status after the bot's move
    checkGameStatus(currentPlayer);

    // Switch back to human's turn if the game is not over
    if (!gameOver) {
      currentPlayer = 'H';
    }

    // Update the UI after the bot's move
    setStateCallback();
  }

  // Handle human move
  void handleHumanMove(int row, int col,
      {required Function() setStateCallback}) {
    if (board[row][col] == ' ' && !gameOver && currentPlayer == 'H') {
      // Human makes a move
      board[row][col] = 'H';

      // Check game status after human move
      checkGameStatus('H');

      // If the game is not over, it's either Bot1's or Bot2's turn depending on who is playing
      if (!gameOver) {
        currentPlayer = humanGoesFirst ? 'O' : 'X';
        botMove(setStateCallback: setStateCallback); // Bot makes its move
      }

      // Update the UI after the human's move
      setStateCallback();
    } else {
      print('Invalid move by human at ($row, $col) or game is already over.');
    }
  }

  // Check if the game has a winner or is a draw
  void checkGameStatus(String playerSymbol) {
    if (checkWinner(playerSymbol)) {
      winner = '$playerSymbol wins!';
      gameOver = true;
    } else if (isBoardFull()) {
      winner = 'It\'s a draw!';
      gameOver = true;
    }
  }

  // Check if the board is full
  bool isBoardFull() {
    return !board.any((row) => row.contains(' '));
  }

  // Check if the player has won the game
  bool checkWinner(String player) {
    for (int i = 0; i < 3; i++) {
      if (board[i][0] == player &&
          board[i][1] == player &&
          board[i][2] == player) return true;
      if (board[0][i] == player &&
          board[1][i] == player &&
          board[2][i] == player) return true;
    }
    return (board[0][0] == player &&
            board[1][1] == player &&
            board[2][2] == player) ||
        (board[0][2] == player &&
            board[1][1] == player &&
            board[2][0] == player);
  }

  // Reset the game state
  void resetGame({required Function() setStateCallback}) {
    // Reset the board and other game states
    board = List.generate(3, (_) => List.generate(3, (_) => ' '));
    gameOver = false;
    winner = '';

    // Randomly decide if the human goes first
    humanGoesFirst = random.nextBool();
    currentPlayer = humanGoesFirst ? 'H' : 'X';

    // If Bot1 goes first, let Bot1 make the first move
    if (!humanGoesFirst) {
      botMove(setStateCallback: setStateCallback);
    }

    // Update the UI after resetting the game
    setStateCallback();
  }
}
