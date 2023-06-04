class Participant {
  String username;
  int doneToday;
  int doneInAll;

  Participant(
      {required this.username, this.doneToday = 0, required this.doneInAll});

  static Participant deserialize(map) =>
      Participant(username: map['username'], doneInAll: map['sessionDone']);

  Map<String, dynamic> serialize() => {
        'username': username,
        'sessionDone': doneInAll,
      };
}
