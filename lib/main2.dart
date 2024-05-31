import 'package:flutter/material.dart';
import 'storage_helper.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final StorageHelper _storageHelper = StorageHelper();
  Map<String, double> _players = {};

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  void _loadPlayers() async {
    final players = await _storageHelper.loadAllPlayers();
    setState(() {
      _players = players;
    });
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final String name = _nameController.text;
      final double balance = double.tryParse(_balanceController.text) ?? 0.0;
      await _storageHelper.savePlayer(name, balance);
      _nameController.clear();
      _balanceController.clear();
      _loadPlayers();
    }
  }

  void _removePlayer(String name) async {
    await _storageHelper.removePlayer(name);
    _loadPlayers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Money transferred successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Enter Player Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _balanceController,
                decoration: const InputDecoration(
                  labelText: 'Enter Account Balance',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a balance';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    final name = _players.keys.elementAt(index);
                    final balance = _players[name];
                    return ListTile(
                      title: Text('Player: $name'),
                      subtitle:
                          Text('Balance: \$${balance?.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _removePlayer(name),
                      ),
                      onTap: () {
                        final currentPlayerName =
                            _players.keys.elementAt(index);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayerAccountScreen(
                              currentPlayerName: currentPlayerName,
                              allPlayers: _players.keys.toList(),
                              onTransfer: _transferMoney,
                              currentPlayerBalance: _players[name],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ignore: must_be_immutable
class PlayerAccountScreen extends StatefulWidget {
  final String currentPlayerName;
  double? currentPlayerBalance;
  final List<String> allPlayers;
  final Function(double transferAmount, String currentPlayerName,
      String targetPlayerName) onTransfer;

  PlayerAccountScreen({
    required this.currentPlayerName,
    required this.allPlayers,
    required this.onTransfer,
    required this.currentPlayerBalance,
  });

  @override
  State<PlayerAccountScreen> createState() => _PlayerAccountScreenState();
}

class _PlayerAccountScreenState extends State<PlayerAccountScreen> {
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
              items: widget.allPlayers
                  .where((playerName) => playerName != widget.currentPlayerName)
                  .map((playerName) {
                return DropdownMenuItem<String>(
                  value: playerName,
                  child: Text(playerName),
                );
              }).toList(),
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
                    widget.currentPlayerBalance = (widget.currentPlayerBalance! - transferAmount);
                  });
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
