class Participant {
  String username;
  int doneInAll;
  int doneToday = 0;
  bool connected = false;

  Participant({required this.username, required this.doneInAll});

  static Participant deserialize(map) =>
      Participant(username: map['username'], doneInAll: map['sessionDone']);

  Map<String, dynamic> serialize() => {
        'username': username,
        'sessionDone': doneInAll,
      };
}
