import 'package:flutter/material.dart';
import 'storage_helper.dart';
//import 'main2.dart';
import 'QR2.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'player_adapter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PlayerAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Poly Banker',
      theme: ThemeData(
        //colorSchemeSeed: Color.fromARGB(255, 39, 35, 45),
        colorScheme: const ColorScheme.dark(
          primary: Color.fromARGB(255, 39, 35, 45),
          background: Color.fromARGB(255, 39, 35, 45),
          surface: Color.fromARGB(255, 39, 35, 45),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 110, 103, 123),
          foregroundColor: Color.fromARGB(255, 255, 255, 255),
          // Set the app bar color here
        ),
        //scaffoldBackgroundColor: Color(0xff19181c),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 110, 103, 123),
            foregroundColor: Color.fromARGB(255, 255, 255, 255),
          ),
        ),

        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageHelper _storageHelper = StorageHelper();
  Map<String, double> _players = {};

  @override
  void initState() {
    super.initState();
    _initializePlayers();
  }

  void _initializePlayers() async {
    final players = await _storageHelper.loadAllPlayers();
    if (players.isEmpty) {
      await _storageHelper.savePlayer('P1', 2000.0);
      await _storageHelper.savePlayer('P2', 2000.0);
      await _storageHelper.savePlayer('P3', 2000.0);
      await _storageHelper.savePlayer('P4', 2000.0);
    }
    _loadPlayers();
  }

  void _newGame() async {
    await _storageHelper.savePlayer('P1', 2000.0);
    await _storageHelper.savePlayer('P2', 2000.0);
    await _storageHelper.savePlayer('P3', 2000.0);
    await _storageHelper.savePlayer('P4', 2000.0);
    _loadPlayers();
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
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet), // Wallet icon
            SizedBox(
                width: 8), // Add some space between the icon and the title text
            Text('InnoPoly Banker'), // Title text
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            Card.outlined(
                child: _SampleCard(name: 'P1', balance: _players['P1'])),
            Card.outlined(
                child: _SampleCard(name: 'P2', balance: _players['P2'])),
            Card.outlined(
                child: _SampleCard(name: 'P3', balance: _players['P3'])),
            Card.outlined(
                child: _SampleCard(name: 'P4', balance: _players['P4'])),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const testQR(mode: 'acc'),
                  ),
                ).then((value) {
                  _loadPlayers();
                });
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Icon(Icons.qr_code),
            ),
            const SizedBox(height: 10),
            /* ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(),
                  ),
                ).then((value) {
                  _loadPlayers();
                });
              },
              child: const Text('Player Info'),
            ), */
            ElevatedButton.icon(
              onPressed: () {
                _showConfirmationDialog(context);
              },
              icon: const Icon(
                  Icons.autorenew), // You can change this icon as needed
              label: const Text('New Game'),
            )
          ]),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to start a new game?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey, // Background color
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey, // Background color
              ),
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _newGame(); // Call your method to start a new game
              },
            ),
          ],
        );
      },
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
