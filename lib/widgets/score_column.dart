import 'package:flutter/material.dart';

class ScoreColumn extends StatelessWidget {
  final String teamName;
  final int score;
  final int sets;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onNameTap;
  final Color color;
  final Color fontColor;
  final int timeouts;
  final VoidCallback onTimeout;

  const ScoreColumn({
    super.key,
    required this.teamName,
    required this.score,
    required this.sets,
    required this.onIncrement,
    required this.onDecrement,
    this.onNameTap,
    required this.color,
    required this.fontColor,
    required this.timeouts,
    required this.onTimeout,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onIncrement,
      onLongPress: onDecrement,
      child: Container(
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: GestureDetector(
                onTap: onNameTap,
                child: Text(
                  teamName,
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: fontColor,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(sets, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    Icons.sports_volleyball,
                    color: fontColor,
                    size: 24,
                  ),
                );
              }),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    '$score',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: fontColor,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: onTimeout,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(timeouts, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(Icons.timer, color: fontColor, size: 24),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
