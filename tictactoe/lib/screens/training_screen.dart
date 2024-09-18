import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/reinforcement_bot.dart';
import '../widgets/board.dart';
import 'game_screen.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  int round = 0;
  int bot1Wins = 0;
  int bot2Wins = 0;
  int draws = 0;
  bool trainingComplete = false;
  bool isTrainingStarted = false;

  late ReinforcementBot bot1;
  late ReinforcementBot bot2;
  List<List<String>> board =
      List.generate(3, (_) => List.generate(3, (_) => ' ')); // Current board

  final TextEditingController _roundsController = TextEditingController();
  int totalGames = 0;
  final int batchUpdateFrequency = 1000; // Increased batch size for performance

  // Data for plotting
  List<FlSpot> bot1WinData = [];
  List<FlSpot> bot2WinData = [];
  List<FlSpot> drawData = [];

  @override
  void initState() {
    super.initState();
    bot1 = ReinforcementBot('X');
    bot2 = ReinforcementBot('O');
  }

  void trainBots() async {
    for (int i = 1; i <= totalGames; i++) {
      if (i % batchUpdateFrequency == 0) {
        setState(() => round = i);
      }

      String result = playGame();

      // Backpropagate final rewards after the game
      if (result == 'X') {
        bot1Wins++;
        bot1.learn(1); // Bot1 wins
        bot2.learn(-1); // Bot2 loses
      } else if (result == 'O') {
        bot2Wins++;
        bot1.learn(-1); // Bot1 loses
        bot2.learn(1); // Bot2 wins
      } else {
        draws++;
        bot1.learn(0); // Draw
        bot2.learn(0); // Draw
      }

      // Update plotting data every batch
      if (i % batchUpdateFrequency == 0 || i == totalGames) {
        double bot1WinRate = bot1Wins / i;
        double bot2WinRate = bot2Wins / i;
        double drawRate = draws / i;

        bot1WinData.add(FlSpot(i.toDouble(), bot1WinRate));
        bot2WinData.add(FlSpot(i.toDouble(), bot2WinRate));
        drawData.add(FlSpot(i.toDouble(), drawRate));

        setState(() {});
      }

      if (i == totalGames) {
        setState(() => trainingComplete = true);
      }
    }
  }

  String playGame() {
    board =
        List.generate(3, (_) => List.generate(3, (_) => ' ')); // Reset board

    while (true) {
      // Bot1's move
      bot1.makeMove(board);
      if (bot1.checkWinner(board, bot1.symbol)) {
        return bot1.symbol;
      }
      if (bot1.isBoardFull(board)) break;

      // Bot2's move
      bot2.makeMove(board);
      if (bot2.checkWinner(board, bot2.symbol)) {
        return bot2.symbol;
      }
      if (bot2.isBoardFull(board)) break;
    }

    return 'draw';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bot Training')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            // Added to prevent overflow
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isTrainingStarted)
                  Column(
                    children: [
                      const Text('Enter the number of rounds for training:',
                          style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _roundsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Number of rounds',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          final enteredRounds =
                              int.tryParse(_roundsController.text);
                          if (enteredRounds != null && enteredRounds > 0) {
                            setState(() {
                              totalGames = enteredRounds;
                              isTrainingStarted = true;
                            });
                            // Start training in a separate isolate
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              trainBots();
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please enter a valid number of rounds')),
                            );
                          }
                        },
                        child: const Text('Start Training'),
                      ),
                    ],
                  ),
                if (isTrainingStarted) ...[
                  Text('Training - Round $round'),
                  const SizedBox(height: 20),
                  Text('Bot1 Wins: $bot1Wins',
                      style: const TextStyle(fontSize: 18, color: Colors.blue)),
                  Text('Bot2 Wins: $bot2Wins',
                      style: const TextStyle(fontSize: 18, color: Colors.red)),
                  Text('Draws: $draws'),
                  const SizedBox(height: 20),
                  if (bot1WinData.isNotEmpty &&
                      bot2WinData.isNotEmpty &&
                      drawData.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: bot1WinData,
                              isCurved: false,
                              barWidth: 2,
                              color: Colors.blue,
                              dotData: const FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: bot2WinData,
                              isCurved: false,
                              barWidth: 2,
                              color: Colors.red,
                              dotData: const FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: drawData,
                              isCurved: false,
                              barWidth: 2,
                              color: Colors.green,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                          minY: 0,
                          maxY: 1,
                          minX: 0,
                          maxX: totalGames.toDouble(),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: 0.2,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                      '${(value * 100).toStringAsFixed(0)}%');
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: (totalGames / 5).toDouble(),
                                getTitlesWidget: (value, meta) {
                                  return Text(value.toInt().toString());
                                },
                              ),
                            ),
                          ),
                          gridData: const FlGridData(show: true),
                          borderData: FlBorderData(show: true),
                        ),
                      ),
                    )
                  else
                    const Text('Gathering data, please wait...'),
                  const SizedBox(height: 20),
                  Board(
                    board: board,
                    onTileTap: (_, __) {}, // Disable tapping during training
                  ),
                  const SizedBox(height: 20),
                ],
                if (trainingComplete)
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GameScreen(bot1: bot1, bot2: bot2)),
                    ),
                    child: const Text('Let\'s Play!'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
