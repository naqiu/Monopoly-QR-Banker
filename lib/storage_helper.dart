import 'package:hive/hive.dart';
import 'player_adapter.dart';

class StorageHelper {
  static const String playerBoxName = 'players';
  static const String chanceCardBoxName = 'chanceCards';
  static const String commCardBoxName = 'commCards';

  Future<void> savePlayer(String name, double balance) async {
    final box = await Hive.openBox<Player>(playerBoxName);
    final player = Player(name, balance);
    await box.put(name, player);
  }

  Future<Map<String, double>> loadAllPlayers() async {
    final box = await Hive.openBox<Player>(playerBoxName);
    final Map<String, double> players = {};

    for (var key in box.keys) {
      final player = box.get(key);
      if (player != null) {
        players[key as String] = player.balance;
      }
    }

    return players;
  }

  Future<double?> loadPlayerBalance(String name) async {
    final box = await Hive.openBox<Player>(playerBoxName);
    final player = box.get(name);
    return player?.balance;
  }

  Future<void> removePlayer(String name) async {
    final box = await Hive.openBox<Player>(playerBoxName);
    await box.delete(name);
  }

  Future<void> saveChanceCardState(Map<String, dynamic> state) async {
    final box = await Hive.openBox<dynamic>(chanceCardBoxName);
    await box.put('currentIndex', state['currentIndex']);
    await box.put('randomNumbers', state['randomNumbers']);
  }

  Future<Map<String, dynamic>> loadChanceCardState() async {
    final box = await Hive.openBox<dynamic>(chanceCardBoxName);
    final currentIndex = box.get('currentIndex');
    final randomNumbers = box.get('randomNumbers');
    return {
      'currentIndex': currentIndex,
      'randomNumbers': randomNumbers,
    };
  }

   Future<void> saveCommCardState(Map<String, dynamic> state) async {
    final box = await Hive.openBox<dynamic>(commCardBoxName);
    await box.put('currentIndex', state['currentIndex']);
    await box.put('randomNumbers', state['randomNumbers']);
  }

  Future<Map<String, dynamic>> loadCommCardState() async {
    final box = await Hive.openBox<dynamic>(commCardBoxName);
    final currentIndex = box.get('currentIndex');
    final randomNumbers = box.get('randomNumbers');
    return {
      'currentIndex': currentIndex,
      'randomNumbers': randomNumbers,
    };
  }
}


/* import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {

  
  Future<void> savePlayer(String name, double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(name, balance);
  }


  Future<Map<String, double>> loadAllPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, double> players = {};

    for (var key in keys) {
      final balance = prefs.getDouble(key);
      if (balance != null) {
        players[key] = balance;
      }
    }
    return players;
  }

  Future<Map<String, double>> loadPlayers(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, double> players = {};

      final balance = prefs.getDouble(key);
      if (balance != null) {
        players[key] = balance;
      }
    
    return players;
  }

  Future<void> removePlayer(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(name);
  }

  Future<void> saveChanceCardState(Map<String, dynamic> state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentIndex', state['currentIndex']);
    await prefs.setStringList('randomNumbers', state['randomNumbers']?.map((e) => e.toString()).toList());
  }

  Future<Map<String, dynamic>> loadChanceCardState() async {
    final prefs = await SharedPreferences.getInstance();
    final int? currentIndex = prefs.getInt('currentIndex');
    final List<String>? randomNumbers = prefs.getStringList('randomNumbers');
    return {
      'currentIndex': currentIndex,
      'randomNumbers': randomNumbers?.map(int.parse).toList(),
    };
  }
}
 */