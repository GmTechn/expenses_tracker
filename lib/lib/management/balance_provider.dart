import 'package:flutter/material.dart';
import '../models/cards.dart';
import '../models/transactions.dart';

class BalanceProvider extends ChangeNotifier {
  List<CardModel> _cards = [];
  Map<int, List<TransactionModel>> _transactionsPerCard = {}; // key = cardId
  int? _defaultCardId;

  // Set all user cards
  void setCards(List<CardModel> cards) {
    _cards = cards;
    // initialize empty lists if not already
    for (var card in cards) {
      _transactionsPerCard.putIfAbsent(card.id!, () => []);
    }
    notifyListeners();
  }

  List<CardModel> get cards => _cards;

  void setDefaultCard(int cardId) {
    _defaultCardId = cardId;
    notifyListeners();
  }

  int? get defaultCardId => _defaultCardId;

  // Set transactions for a specific card
  void setTransactionsForCard(int cardId, List<TransactionModel> txs) {
    _transactionsPerCard[cardId] = txs;
    notifyListeners();
  }

  // Add a new transaction to a specific card
  void addTransaction(int cardId, TransactionModel tx) {
    _transactionsPerCard[cardId]?.add(tx);
    notifyListeners();
  }

  // Get transactions for a card
  List<TransactionModel> transactionsForCard(int cardId) {
    return _transactionsPerCard[cardId] ?? [];
  }

  // Total balance for a specific card
  double totalBalance(int cardId) {
    final txs = _transactionsPerCard[cardId] ?? [];
    return txs.fold(0.0, (sum, t) => sum + t.amount);
  }

  // Total income for a card
  double totalIncome(int cardId) {
    final txs = _transactionsPerCard[cardId] ?? [];
    return txs
        .where((t) => t.amount >= 0)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Total expense for a card
  double totalExpense(int cardId) {
    final txs = _transactionsPerCard[cardId] ?? [];
    return txs
        .where((t) => t.amount < 0)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }

  // Current balance for default card
  double get currentBalance {
    if (_defaultCardId == null) return 0.0;
    return totalBalance(_defaultCardId!);
  }
}
