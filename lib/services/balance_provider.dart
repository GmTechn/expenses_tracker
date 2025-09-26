import 'package:expenses_tracker/models/cards.dart';
import 'package:flutter/material.dart';
import '../models/transactions.dart';

class BalanceProvider extends ChangeNotifier {
  int? _defaultCardId;
  List<CardModel> _cards = [];
  Map<int, List<TransactionModel>> _cardTransactions = {};

  // --- Getters ---
  int? get defaultCardId => _defaultCardId;

  List<CardModel> get cards => _cards;

  double get currentBalance {
    if (_defaultCardId == null) return 0.0;
    final transactions = _cardTransactions[_defaultCardId!] ?? [];
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  // --- Setters / actions ---
  void setDefaultCard(int cardId) {
    _defaultCardId = cardId;
    notifyListeners();
  }

  void setCards(List<CardModel> cards) {
    _cards = cards;
    notifyListeners();
  }

  void setTransactionsForCard(int cardId, List<TransactionModel> transactions) {
    _cardTransactions[cardId] = transactions;
    notifyListeners();
  }

  void addTransaction(int cardId, TransactionModel transaction) {
    _cardTransactions[cardId] ??= [];
    // Ajouter au début de la liste pour que ça apparaisse en haut
    _cardTransactions[cardId]!.insert(0, transaction);
    notifyListeners();
  }

  void updateTransaction(int cardId, TransactionModel transaction) {
    final transactions = _cardTransactions[cardId];
    if (transactions == null) return;
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      notifyListeners();
    }
  }

  void removeTransaction(int cardId, TransactionModel transaction) {
    final transactions = _cardTransactions[cardId];
    if (transactions == null) return;
    transactions.removeWhere((t) => t.id == transaction.id);
    notifyListeners();
  }

  List<TransactionModel> transactionsForCard(int cardId) {
    return _cardTransactions[cardId] ?? [];
  }

  double totalBalance(int cardId) {
    final card = _cards.firstWhere(
      (c) => c.id == cardId,
      orElse: () => CardModel.empty(),
    );

    final baseAmount = card.amount;
    final transactions = _cardTransactions[cardId] ?? [];
    final transactionsSum = transactions.fold(0.0, (sum, t) => sum + t.amount);

    return baseAmount + transactionsSum;
  }
}
