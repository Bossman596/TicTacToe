import 'package:flutter/material.dart';
import '../models/reinforcement_bot.dart';
import '../models/game_logic.dart';
import '../widgets/board.dart';

class GameScreen extends StatefulWidget {
  final ReinforcementBot bot1;
  final ReinforcementBot bot2;

  const GameScreen({required this.bot1, required this.bot2, super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  late GameLogic _gameLogic;

  @override
  void initState() {
    super.initState();
    _gameLogic =
        GameLogic(widget.bot1, widget.bot2); // Pass trained bots to GameLogic
    _gameLogic.resetGame(setStateCallback: () => setState(() {}));
  }

  void handleHumanMove(int row, int col) {
    _gameLogic.handleHumanMove(row, col,
        setStateCallback: () => setState(() {}));
  }

  String getCurrentPlayerTurnText() {
    if (_gameLogic.currentPlayer == 'H') {
      return "Human's Turn";
    } else {
      return "Bot's Turn";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic-Tac-Toe - Play against Bot'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display whose turn it is
          Text(
            getCurrentPlayerTurnText(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Display the game board
          Board(
            board: _gameLogic.board,
            onTileTap: handleHumanMove,
          ),
          const SizedBox(height: 20),
          // If the game is over, display the winner and a "Play Again" button
          if (_gameLogic.gameOver) ...[
            Text(_gameLogic.winner, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _gameLogic.resetGame(setStateCallback: () => setState(() {}));
                });
              },
              child: const Text('Play Again'),
            ),
          ],
        ],
      ),
    );
  }
}
