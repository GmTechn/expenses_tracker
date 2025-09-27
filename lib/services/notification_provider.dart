import 'package:flutter/material.dart';

import 'package:expenses_tracker/models/notifications.dart';

class NotificationProvider extends ChangeNotifier {
//list of notifications
  final List<AppNotification> _notifications = [];

//sorting notifications by date to display from recent
//to oldest

  List<AppNotification> get allNotifications =>
      _notifications..sort((a, b) => b.date.compareTo(a.date));

//counting the unread notifications
//so when a notification has a status of
  /// "not read !read", it means count it
  /// so we know how many we have that are not
  /// read yet

  int get unreadCount => _notifications.where((notif) => !notif.read).length;

//---- ADD NOTIF----
  ///adding a notification by creating an instance
  ///of a notification model to the list of the
  ///unread ones
  void addNotification(AppNotification notification) {
    _notifications.add(notification);
    notifyListeners();
  }

//----- MARK AS READ NOTIF -----

  ///changing the status of a specific notif
  ///with its id, to read and then notify the
  ///listener so the status is updated
  void markAsRead(String id) {
    final notif = _notifications.firstWhere((n) => n.id == id);
    notif.read = true;
    notifyListeners();
  }

//---- MARK ALL AS READ -----

  ///setting all the variables status to read
  ///setting it to true and notifying listeners
  void markAllAsRead() {
    for (var n in _notifications) {
      n.read = true;
    }

    notifyListeners();
  }

//---- DELETING NOTIFICATIONS -----

  ///find the notification by the id and
  ///delete it by notifying the listener

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
