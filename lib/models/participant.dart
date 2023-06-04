class Participant {
  String username;
  int doneToday;
  int doneInAll;

  Participant(
      {required this.username, this.doneToday = 0, required this.doneInAll});
}
