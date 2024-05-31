import 'dart:math';
import 'package:flutter/material.dart';
import 'storage_helper.dart';

class CommCardLst {
  final String statement;
  final double? amount; // Amount can be null
  final String? operator;

  CommCardLst({required this.statement, this.amount, this.operator});
}

class CommCard extends StatefulWidget {
  final String currentPlayerName;
  final Function(double amount, String plusMinus, String currentPlayerName)
      changeBalance;

  const CommCard(
      {super.key,
      required this.currentPlayerName,
      required this.changeBalance});

  @override
  _CommCardState createState() => _CommCardState();
}

class _CommCardState extends State<CommCard> {
  List<int> randomNumbers = [];
  int currentIndex = 0;
  late StorageHelper _storageHelper;

  final Map<int, CommCardLst> chanceCardMapping = {
    0: CommCardLst(
        statement: 'Green Initiative Award! Your sustainable practices are rewarded. Advance to Go (Collect \$200)',
        amount: 200,
        operator: 'plus'),
    1: CommCardLst(
        statement: 'Office Rent Hike! Your landlord raises the rent. Pay \$50 to the Bank.',
        amount: 50,
        operator: 'minus'),
    2: CommCardLst(
        statement: 'Networking Event! Expand your connections. Pay \$150 to the Bank, but gain the ability to trade one Item card with Item that you want.', amount: 150, operator: 'minus'),
    3: CommCardLst(
        statement:
            'University Partnership! Collaborate with a prestigious university. Choose one Item card from any players hand '),
    4: CommCardLst(
        statement:
            'Mentor Match! A seasoned entrepreneur offers guidance. Draw an additional Chance card'),
    5: CommCardLst(
        statement: 'Community Crowdfunding! Your pitch resonates with the community. Collect \$50 donations from each player',
        amount: 50,
        operator: 'col'),
    6: CommCardLst(
        statement:
            'Employee Strike! Production is halted. Lose your next turn.'),
    7: CommCardLst(
        statement: 'Hackathon Hero! Your coding skills shine. Win a "Program" Item card '),
    8: CommCardLst(
        statement: 'Cybersecurity Training Required! Your team needs to be updated. Pay \$30 to the Bank and discard a "Program" Item card ',
        amount: 30,
        operator: 'minus'),
    9: CommCardLst(
        statement: 'Team Building Retreat! Strengthen your team spirit. Pay \$200 to the Bank, But take 1 Item card that you want.',
        amount: 200,
        operator: 'minus'),
  };

  @override
  void initState() {
    super.initState();
    _storageHelper = StorageHelper();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    final state = await _storageHelper.loadCommCardState();
    if (state['randomNumbers'] != null && state['randomNumbers'].isNotEmpty) {
      setState(() {
        currentIndex = state['currentIndex'] ?? 0;
        randomNumbers = List<int>.from(state['randomNumbers']);
        showNext();
      });
    } else {
      generateUniqueRandomNumbers();
    }
  }

  Future<void> _saveData() async {
    await _storageHelper.saveCommCardState({
      'currentIndex': currentIndex,
      'randomNumbers': randomNumbers,
    });
  }

  void generateUniqueRandomNumbers() {
    List<int> numbers = List.generate(10, (index) => index);
    numbers.shuffle(Random());
    setState(() {
      randomNumbers = numbers;
      currentIndex = 0;
    });
    _saveData();
  }

  void showNext() {
    setState(() {
      currentIndex = (currentIndex + 1) % randomNumbers.length;
    });
    _saveData();
  }

  void showCardDialog(int number) {
    CommCardLst card = chanceCardMapping[number]!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Community Chest Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(card.statement),
              if (card.amount != null && card.operator != null)
                Text(
                  '${card.operator == 'plus' || card.operator == 'col' ? '+' : '-'}${card.amount}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          actions: <Widget>[
            if (card.amount != null && card.operator != null)
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: Text('Apply'),
                onPressed: () {
                  String op = '';
                  if (card.operator == 'plus') {
                    op = 'p';
                  } else if (card.operator == 'minus') {
                    op = 'm';
                  } else if (card.operator == 'col') {
                    op = 'c';
                  }
                  Navigator.of(context)
                    ..pop()
                    ..pop('${op}${card.amount}');
                },
              ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Community Chest Card')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: generateUniqueRandomNumbers,
              child: Text('Reshuffle'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showCardDialog(randomNumbers[currentIndex]);
              },
              child: Text('Community Chest Card'),
            ),
            SizedBox(height: 10),
            /* Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: randomNumbers.map((number) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '$number',
                    style: TextStyle(fontSize: 20),
                  ),
                );
              }).toList(),
            ), */
            /* if (randomNumbers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Current Number: ${randomNumbers[currentIndex]}',
                  style: TextStyle(fontSize: 24),
                ),
              ), */
          ],
        ),
      ),
    );
  }
}
