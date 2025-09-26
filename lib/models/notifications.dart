class AppNotification {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.read = false,
  });
}
