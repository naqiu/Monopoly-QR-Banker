import 'package:flutter/material.dart';
import 'storage_helper.dart';
import 'QR2.dart';
import 'chance.dart';
import 'comm.dart';

class Acc extends StatefulWidget {
  const Acc({super.key, required this.P});
  final String P;

  @override
  State<Acc> createState() => _AccState();
}

class _AccState extends State<Acc> {
  final StorageHelper _storageHelper = StorageHelper();
  Map<String, double> _players = {};

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  void _changeBalance(
      double amount, String plusMinus, String currentPlayerName) {
    if (_players.containsKey(currentPlayerName)) {
      if (plusMinus == 'plus') {
        _players[currentPlayerName] =
            (_players[currentPlayerName] ?? 0) + amount;
        _storageHelper.savePlayer(
            currentPlayerName, _players[currentPlayerName]!);
      } else if (plusMinus == 'minus') {
        _players[currentPlayerName] =
            (_players[currentPlayerName] ?? 0) - amount;
        _storageHelper.savePlayer(
            currentPlayerName, _players[currentPlayerName]!);
      } else {}
    }
  }

  void _transferMoney(double transferAmount, String currentPlayerName,
      String targetPlayerName) {
    setState(() {
      // Ensure that currentPlayerName exists in _players and its balance is not null before updating
      if (_players.containsKey(currentPlayerName)) {
        _players[currentPlayerName] =
            (_players[currentPlayerName] ?? 0) - transferAmount;
        _storageHelper.savePlayer(
            currentPlayerName, _players[currentPlayerName]!);
      }

      // Ensure that targetPlayerName exists in _players and its balance is not null before updating
      if (_players.containsKey(targetPlayerName)) {
        _players[targetPlayerName] =
            (_players[targetPlayerName] ?? 0) + transferAmount;
        _storageHelper.savePlayer(
            targetPlayerName, _players[targetPlayerName]!);
      }
    });
  }

  void _loadPlayers() async {
    final players = await _storageHelper.loadAllPlayers();
    setState(() {
      _players = players;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player Account - ${widget.P}'),
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            Navigator.of(context)
              ..pop()
              ..pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card.outlined(
                child:
                    _SampleCard(name: widget.P, balance: _players[widget.P])),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                // Navigate to SecondScreen and wait for the result
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => testQR(mode: 'GO'),
                  ),
                );

                // Handle the result
                if (result == 'GO') {
                  _changeBalance(200, 'plus', widget.P);
                  _loadPlayers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Received \$200')),
                  );
                }
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('GO'),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => transfer(
                      currentPlayerName: widget.P,
                      allPlayers: _players.keys.toList(),
                      onTransfer: _transferMoney,
                      currentPlayerBalance: _players[widget.P],
                    ),
                  ),
                ).then((value) {
                  _loadPlayers();
                });
              },
              icon: const Icon(Icons.payment),
              label: const Text('Transfer'),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Receive(
                      onTransfer: _transferMoney,
                      currentPlayerName: widget.P,
                      changeBalance: _changeBalance,
                    ),
                  ),
                ).then((value) {
                  _loadPlayers();
                });
              },
              icon: const Icon(Icons.attach_money),
              label: const Text('Receive'),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                // Navigate to SecondScreen and wait for the result
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => testQR(mode: 'QR'),
                  ),
                );
                // Handle the result
                if (result != null) {
                  String op = result.substring(0, 1);
                  double amount = double.tryParse(result.substring(1)) ?? 0.0;
                  if (op == 'p') {
                    op = 'plus';
                  } else if (op == 'm') {
                    op = 'minus';
                  }
                  _changeBalance(amount, op, widget.P);
                  _loadPlayers();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$op: $amount')),
                  );
                }
              },
              icon: const Icon(Icons.qr_code),
              label: const Text('QRCard'),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                // Navigate to SecondScreen and wait for the result
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChanceCard(
                      currentPlayerName: widget.P,
                      changeBalance: _changeBalance,
                    ),
                  ),
                );
                // Handle the result
                if (result != null) {
                  String op = result.substring(0, 1);
                  double amount = double.tryParse(result.substring(1)) ?? 0.0;
                  if (op == 'p') {
                    op = 'plus';
                    _changeBalance(amount, op, widget.P);
                  } else if (op == 'm') {
                    op = 'minus';
                    _changeBalance(amount, op, widget.P);
                  } else if (op == 'c') {
                    List<String> otherPlayerNames = ['P1', 'P2', 'P3', 'P4'];
                    otherPlayerNames.remove(widget.P);

                    for (String other in otherPlayerNames) {
                      _transferMoney(amount, other, widget.P);
                    }
                    
                  }

                  _loadPlayers();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$op: $amount')),
                  );
                }
              },
              icon: const Icon(Icons.question_mark),
              label: const Text('Chance'),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                // Navigate to SecondScreen and wait for the result
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommCard(
                      currentPlayerName: widget.P,
                      changeBalance: _changeBalance,
                    ),
                  ),
                );
                // Handle the result
                if (result != null) {
                  String op = result.substring(0, 1);
                  double amount = double.tryParse(result.substring(1)) ?? 0.0;
                  if (op == 'p') {
                    op = 'plus';
                    _changeBalance(amount, op, widget.P);
                  } else if (op == 'm') {
                    op = 'minus';
                    _changeBalance(amount, op, widget.P);
                  } else if (op == 'c') {
                    List<String> otherPlayerNames = ['P1', 'P2', 'P3', 'P4'];
                    otherPlayerNames.remove(widget.P);

                    for (String other in otherPlayerNames) {
                      _transferMoney(amount, other, widget.P);
                    }
                    
                  }

                  _loadPlayers();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$op: $amount')),
                  );
                }
              },
              icon: const Icon(Icons.inbox),
              label: const Text('Community Chest'),
            )
          ],
        ),
      ),
    );
  }
}

class _SampleCard extends StatelessWidget {
  const _SampleCard({this.name, this.balance});
  final name;
  final balance;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 16, 16, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 24.0),
                const SizedBox(width: 8.0),
                Text(
                  name ?? 'Unknown',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              balance != null
                  ? 'Balance: \$${balance!.toStringAsFixed(2)}'
                  : 'Balance: N/A',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class transfer extends StatefulWidget {
  final String currentPlayerName;
  double? currentPlayerBalance;
  final List<String> allPlayers;
  final Function(double transferAmount, String currentPlayerName,
      String targetPlayerName) onTransfer;

  transfer(
      {super.key,
      required this.currentPlayerName,
      required this.currentPlayerBalance,
      required this.allPlayers,
      required this.onTransfer});

  @override
  State<transfer> createState() => _transferState();
}

class _transferState extends State<transfer> {
  final TextEditingController amountController = TextEditingController();
  String? selectedPlayerName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player Account - ${widget.currentPlayerName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Balance: \$${widget.currentPlayerBalance}'),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedPlayerName,
              onChanged: (playerName) {
                setState(() {
                  selectedPlayerName = playerName;
                });
              },
              items: [
                DropdownMenuItem<String>(
                  value: 'Banker',
                  child: Text('Banker'),
                ),
                ...widget.allPlayers
                    .where(
                        (playerName) => playerName != widget.currentPlayerName)
                    .map((playerName) {
                  return DropdownMenuItem<String>(
                    value: playerName,
                    child: Text(playerName),
                  );
                }).toList(),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Amount to Transfer',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                final transferAmount =
                    double.tryParse(amountController.text) ?? 0.0;
                if (transferAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid transfer amount')),
                  );
                } else if (selectedPlayerName == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Please select a player to transfer money to'),
                    ),
                  );
                } else {
                  widget.onTransfer(transferAmount, widget.currentPlayerName,
                      selectedPlayerName!);
                  setState(() {
                    widget.currentPlayerBalance =
                        (widget.currentPlayerBalance! - transferAmount);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Transfer Success')),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Transfer Money'),
            ),
          ],
        ),
      ),
    );
  }
}

class Receive extends StatefulWidget {
  final String currentPlayerName;
  final Function(double transferAmount, String currentPlayerName,
      String targetPlayerName) onTransfer;
  final Function(double amount, String plusMinus, String currentPlayerName)
      changeBalance;

  const Receive(
      {super.key,
      required this.onTransfer,
      required this.currentPlayerName,
      required this.changeBalance});

  @override
  State<Receive> createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Player Account - ${widget.currentPlayerName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Amount to Receive',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final transferAmount =
                    double.tryParse(amountController.text) ?? 0.0;
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => testQR(mode: 'receive'),
                  ),
                );

                if (transferAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid transfer amount')),
                  );
                } else if (result == 'BK') {
                  widget.changeBalance(
                      transferAmount, 'plus', widget.currentPlayerName);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Transfer Success')),
                  );
                  Navigator.pop(context);
                } else if (result == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Scan QR player to receive from'),
                    ),
                  );
                } else {
                  widget.onTransfer(
                      transferAmount, result, widget.currentPlayerName);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Received ${transferAmount.toString()} from $result')),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Receive From'),
            ),
          ],
        ),
      ),
    );
  }
}
