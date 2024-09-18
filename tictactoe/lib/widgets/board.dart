import 'package:flutter/material.dart';

class Board extends StatelessWidget {
  final List<List<String>> board;
  final Function(int, int) onTileTap;

  const Board({super.key, required this.board, required this.onTileTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (col) {
            return GestureDetector(
              onTap: () => onTileTap(row, col),
              child: Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: _getTileColor(board[row][col]), // Set tile color
                ),
                child: Center(
                  child: Text(
                    board[row][col],
                    style: TextStyle(
                      fontSize: 36,
                      color: _getTextColor(board[row][col]), // Set text color
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  // Method to get the color of the tile based on the symbol
  Color _getTileColor(String symbol) {
    switch (symbol) {
      case 'X':
        return Colors.blue.shade200; // Blue for Bot1 (X)
      case 'O':
        return Colors.red.shade200; // Red for Bot2 (O)
      case 'H':
        return Colors.green.shade200; // Green for Human (H)
      default:
        return Colors.white; // White for empty tiles
    }
  }

  // Method to get the text color based on the symbol
  Color _getTextColor(String symbol) {
    switch (symbol) {
      case 'X':
        return Colors.blue.shade800; // Darker blue for 'X'
      case 'O':
        return Colors.red.shade800; // Darker red for 'O'
      case 'H':
        return Colors.green.shade800; // Darker green for 'H'
      default:
        return Colors.black; // Black for empty tiles
    }
  }
}
