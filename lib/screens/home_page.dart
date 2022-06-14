import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snake/Widgets/Blank_pixel.dart';
import 'package:snake/Widgets/FoodPixel.dart';
import 'package:snake/Widgets/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  //grid Dimensions
  int rowSize = 10;
  int totalNumberofSquare = 100;
  final nameController = TextEditingController();
  int currentScore = 0;
  bool gameStarted = false;
  //snake Positiion
  List<int> SnakePos = [0, 1, 2];
  // snake positions is initially to the right
  var CurrentDirection = snake_direction.RIGHT;

  //Food Position
  int foodPos = 55;

  void startGame() {
    gameStarted = true;
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        //keep the snake moving
        moveSnake();
        if (gameOver()) {
          timer.cancel();
          // display gameover
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text('Game Over'),
                  content: Column(
                    children: [
                      Text("Your Score is: $currentScore"),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(hintText: 'Enter Name'),
                      ),
                    ],
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                        submitScore();
                        newGame();
                        gameStarted = false;
                      },
                      child: Text('Submit'),
                      color: Colors.pink,
                    )
                  ],
                );
              });
        }
      });
    });
  }

  void submitScore() {
    var database = FirebaseFirestore.instance;
    database.collection('highscores').add({
      "name": nameController,
      "score": currentScore,
    });
  }

  void newGame() {
    setState(() {
      SnakePos = [0, 1, 2];
      foodPos = 55;
      CurrentDirection = snake_direction.RIGHT;
      currentScore = 0;
    });
  }

  void eatFood() {
    currentScore++;
    while (SnakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberofSquare);
    }
  }

  void moveSnake() {
    switch (CurrentDirection) {
      case snake_direction.RIGHT:
        {
          // last column
          if (SnakePos.last % rowSize == 9) {
            SnakePos.add(SnakePos.last + 1 - rowSize);
          } else {
            SnakePos.add(SnakePos.last + 1);
          }
        }
        break;
      case snake_direction.DOWN:
        {
          if (SnakePos.last + rowSize > totalNumberofSquare) {
            SnakePos.add(SnakePos.last + rowSize - totalNumberofSquare);
          } else {
            SnakePos.add(SnakePos.last + rowSize);
          }
        }
        break;
      case snake_direction.UP:
        {
          if (SnakePos.last < rowSize) {
            SnakePos.add(SnakePos.last - rowSize + totalNumberofSquare);
          } else {
            SnakePos.add(SnakePos.last - rowSize);
          }
        }
        break;
      case snake_direction.LEFT:
        {
          if (SnakePos.last % rowSize == 0) {
            SnakePos.add(SnakePos.last - 1 + rowSize);
          } else {
            SnakePos.add(SnakePos.last - 1);
          }
        }
        break;
      default:
    }
    if (SnakePos.last == foodPos) {
      eatFood();
    } else {
      SnakePos.removeAt(0);
    }
  }

  bool gameOver() {
    //we just have to find the number of duplicate
    List<int> snakeBody = SnakePos.sublist(0, SnakePos.length - 1);
    if (snakeBody.contains(SnakePos.last)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          //high score
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // display user score
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Current Score :',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      currentScore.toString(),
                      style: TextStyle(fontSize: 36, color: Colors.white),
                    ),
                  ],
                ),

                //high score
                Text(
                  "Highscores..",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          //game screen
          Expanded(
            flex: 3,
            child: GestureDetector(
              onVerticalDragUpdate: (context) {
                if (context.delta.dy > 0 &&
                    CurrentDirection != snake_direction.UP) {
                  CurrentDirection = snake_direction.DOWN;
                } else if (context.delta.dy < 0 &&
                    CurrentDirection != snake_direction.DOWN) {
                  CurrentDirection = snake_direction.UP;
                }
              },
              onHorizontalDragUpdate: (context) {
                if (context.delta.dx > 0 &&
                    CurrentDirection != snake_direction.LEFT) {
                  CurrentDirection = snake_direction.RIGHT;
                } else if (context.delta.dx < 0 &&
                    CurrentDirection != snake_direction.RIGHT) {
                  CurrentDirection = snake_direction.LEFT;
                }
              },
              child: GridView.builder(
                  itemCount: totalNumberofSquare,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowSize),
                  itemBuilder: (context, index) {
                    if (SnakePos.contains(index)) {
                      return const SnakePixel();
                    } else if (foodPos == index) {
                      return const FoodPixel();
                    } else {
                      return const BlankPixel();
                    }
                  }),
            ),
          ),
          //playbutton
          Expanded(
            child: Container(
              child: Center(
                child: MaterialButton(
                  onPressed: gameStarted ? () {} : startGame,
                  child: const Text('PLAY'),
                  color: gameStarted ? Colors.grey : Colors.pink,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
