import 'package:flutter/material.dart';
import 'package:expenses_tracker/models/notifications.dart';

class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _notifications = [];

  /// Notifications triées par date (récente d’abord)
  List<AppNotification> get allNotifications =>
      _notifications..sort((a, b) => b.date.compareTo(a.date));

  /// Nombre de notifications non lues
  int get unreadCount => _notifications.where((n) => !n.read).length;

  /// Ajouter une notification
  void addNotification(AppNotification notification) {
    _notifications.add(notification);
    notifyListeners();
  }

  /// Marquer une notification spécifique comme lue
  void markAsRead(String id) {
    final notif = _notifications.firstWhere((n) => n.id == id);
    notif.read = true;
    notifyListeners();
  }

  /// Tout marquer comme lu
  void markAllAsRead() {
    for (var n in _notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  /// Supprimer une notification
  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  /// Helpers — types de notifs rapides
  void addNewCardNotification() {
    addNotification(AppNotification.create(
      title: "New Card Added!",
      description: "Your new debit card has been successfully added.",
      type: NotificationType.newCard,
    ));
  }

  void addTransactionNotification(double amount) {
    addNotification(AppNotification.create(
      title: "Transaction Recorded",
      description:
          "A new transaction of \$${amount.toStringAsFixed(2)} has been added to your account.",
      type: NotificationType.transaction,
    ));
  }

  void addBudgetGoalReachedNotification() {
    addNotification(AppNotification.create(
      title: "Budget Goal Reached!",
      description: "Congratulations! You've reached your budget goal.",
      type: NotificationType.budgetGoal,
    ));
  }
}
