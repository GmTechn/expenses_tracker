import 'package:uuid/uuid.dart';

/// Types possibles de notifications
enum NotificationType {
  newCard,
  transaction,
  systemAlert,
  budgetGoal,
  other,
}

/// Modèle de notification
class AppNotification {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final NotificationType type;
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.read = false,
  });

  /// Factory pour créer facilement une nouvelle notification
  factory AppNotification.create({
    required String title,
    required String description,
    required NotificationType type,
  }) {
    return AppNotification(
      id: const Uuid().v4(),
      title: title,
      description: description,
      date: DateTime.now(),
      type: type,
      read: false,
    );
  }
}
