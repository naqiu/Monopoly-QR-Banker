import 'dart:math';
import 'package:flutter/material.dart';
import 'storage_helper.dart';

class ChanceCardLst {
  final String statement;
  final double? amount; // Amount can be null
  final String? operator;

  ChanceCardLst({required this.statement, this.amount, this.operator});
}

class ChanceCard extends StatefulWidget {
  final String currentPlayerName;
  final Function(double amount, String plusMinus, String currentPlayerName)
      changeBalance;

  const ChanceCard(
      {super.key,
      required this.currentPlayerName,
      required this.changeBalance});

  @override
  _ChanceCardState createState() => _ChanceCardState();
}

class _ChanceCardState extends State<ChanceCard> {
  List<int> randomNumbers = [];
  int currentIndex = 0;
  late StorageHelper _storageHelper;

  final Map<int, ChanceCardLst> chanceCardMapping = {
    0: ChanceCardLst(
        statement: 'Tech Grant Approved! The government recognizes your potential. Receive a Research & Development (R&D) voucher worth \$400.',
        amount: 400,
        operator: 'plus'),
    1: ChanceCardLst(
        statement: 'Patent Approved! Congratulations! Your invention receives a patent. Choose any unowned patent card and claim it for free.'),
    2: ChanceCardLst(
        statement: 'Patent Dispute! A legal battle arises. Pay \$200 to the Bank.', amount: 200, operator: 'minus'),
    3: ChanceCardLst(
        statement:
            'Product Recall! A safety issue forces a recall. Pay \$400 to the Bank.', amount: 400, operator: 'minus'),
    4: ChanceCardLst(
        statement:
            'Breach of Data Privacy Policy - Go to jail - Go directly to jail - Do not pass Go, do not collect \$200'),
    5: ChanceCardLst(
        statement: 'It is your birthday – Collect \$10 from each player',
        amount: 10,
        operator: 'col'),
    6: ChanceCardLst(
        statement:
            'Tech Demo Night - Collect \$50 from every attendee for tickets to the exclusive tech demo event.',
        amount: 50,
        operator: 'col'),
    7: ChanceCardLst(
        statement: 'Income Tax refund – Collect \$50',
        amount: 20,
        operator: 'plus'),
    8: ChanceCardLst(
        statement: 'Life insurance matures – Collect \$100',
        amount: 100,
        operator: 'plus'),
    9: ChanceCardLst(
        statement: 'Security Breach! Hackers target your server. Discard a random Item card'),
  };

  @override
  void initState() {
    super.initState();
    _storageHelper = StorageHelper();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    final state = await _storageHelper.loadChanceCardState();
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
    await _storageHelper.saveChanceCardState({
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

  void showChanceCardDialog(int number) {
    ChanceCardLst card = chanceCardMapping[number]!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chance Card'),
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
      appBar: AppBar(title: Text('Chance Card')),
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
                showChanceCardDialog(randomNumbers[currentIndex]);
              },
              child: Text('Chance Card'),
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
