import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path; // For handling file paths

class ReinforcementBot {
  final String symbol;
  static final Random random = Random();

  // Q-table: Stores state-action pairs with their Q-values
  Map<String, Map<int, double>> qTable = {};
  double learningRate = 0.2;
  double discountFactor = 0.9; // Bellman equation's discount factor γ
  double epsilon = 0.2;
  double epsilonDecay = 0.9999; // Less aggressive epsilon decay
  String lastState = ""; // Track last state for learning
  int lastAction = -1; // Track last action for learning
  List<String> stateHistory = []; // Stores state history for reward propagation

  ReinforcementBot(this.symbol);

  // Make a move using epsilon-greedy strategy
  void makeMove(List<List<String>> board, {bool allowExploration = true}) {
    String state = _getStateString(board);

    // Choose action using epsilon-greedy strategy
    double currentEpsilon = allowExploration ? epsilon : 0.0;
    int action;
    if (random.nextDouble() < currentEpsilon) {
      // Explore
      action = _getRandomAction(board);
    } else {
      // Exploit
      action = _getBestAction(state, board);
    }

    // Apply the move to the board
    _applyMove(board, action);

    // Record the state for learning
    stateHistory.add(state);

    // Decay epsilon after each move only during training
    if (allowExploration) {
      epsilon *= epsilonDecay;
      if (epsilon < 0.01) {
        epsilon = 0.01; // Prevent epsilon from becoming too small
      }
    }
  }

  // Update Q-values after the game ends
  void learn(double reward) {
    for (int i = stateHistory.length - 1; i >= 0; i--) {
      String state = stateHistory[i];
      if (!qTable.containsKey(state)) {
        qTable[state] = {};
      }
      int action = _getActionFromState(state);
      double qValue = qTable[state]?[action] ?? 0.0;
      qValue += learningRate * (reward - qValue);
      qTable[state]?[action] = qValue;
      reward *= discountFactor; // Decay reward for previous states
    }
    stateHistory.clear(); // Clear history after learning
  }

  int _getBestAction(String state, List<List<String>> board) {
    if (!qTable.containsKey(state)) {
      qTable[state] = {};
    }

    Map<int, double> actions = qTable[state]!;
    List<int> validActions = _getEmptySpots(board);
    double maxQValue = double.negativeInfinity;
    int bestAction = validActions[0];

    for (int action in validActions) {
      double qValue = actions[action] ?? 0.0;
      if (qValue > maxQValue) {
        maxQValue = qValue;
        bestAction = action;
      }
    }
    return bestAction;
  }

  int _getRandomAction(List<List<String>> board) {
    List<int> emptySpots = _getEmptySpots(board);
    return emptySpots[random.nextInt(emptySpots.length)];
  }

  void _applyMove(List<List<String>> board, int action) {
    int row = action ~/ 3;
    int col = action % 3;
    board[row][col] = symbol;
  }

  String _getStateString(List<List<String>> board) {
    return board.expand((row) => row).join();
  }

  int _getActionFromState(String state) {
    // Assuming the action is the index where the symbol differs
    for (int i = 0; i < state.length; i++) {
      if (state[i] != ' ' && state[i] != symbol) {
        return i;
      }
    }
    return -1; // Should not reach here
  }

  List<int> _getEmptySpots(List<List<String>> board) {
    List<int> emptySpots = [];
    for (int i = 0; i < 9; i++) {
      int row = i ~/ 3;
      int col = i % 3;
      if (board[row][col] == ' ') emptySpots.add(i);
    }
    return emptySpots;
  }

  bool checkWinner(List<List<String>> board, String playerSymbol) {
    for (int i = 0; i < 3; i++) {
      if ((board[i][0] == playerSymbol &&
              board[i][1] == playerSymbol &&
              board[i][2] == playerSymbol) ||
          (board[0][i] == playerSymbol &&
              board[1][i] == playerSymbol &&
              board[2][i] == playerSymbol)) {
        return true;
      }
    }
    return (board[0][0] == playerSymbol &&
            board[1][1] == playerSymbol &&
            board[2][2] == playerSymbol) ||
        (board[0][2] == playerSymbol &&
            board[1][1] == playerSymbol &&
            board[2][0] == playerSymbol);
  }

  bool isBoardFull(List<List<String>> board) {
    return !board.any((row) => row.contains(' '));
  }
}
