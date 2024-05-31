import 'package:hive/hive.dart';

class Player {
  final String name;
  final double balance;

  Player(this.name, this.balance);
}

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 0;

  @override
  Player read(BinaryReader reader) {
    final name = reader.readString();
    final balance = reader.readDouble();
    return Player(name, balance);
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer.writeString(obj.name);
    writer.writeDouble(obj.balance);
  }
}
