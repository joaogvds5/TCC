import 'package:flutter/foundation.dart';
import 'package:nearu/src/models/interest.dart';
import 'package:nearu/src/services/interest_service.dart';

class InterestController extends ChangeNotifier {
  final InterestService _service;

  InterestController({InterestService? service})
    : _service = service ?? InterestService();

  List<Interest> _allInterests = [];
  Set<int> _selectedIds = {};
  bool _isLoading = false;
  String? _error;

  List<Interest> get allInterests => _allInterests;
  Set<int> get selectedIds => _selectedIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isSelected(int id) => _selectedIds.contains(id);

  Future<void> load({required String userUuid}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getAllInterests(),
        _service.getUserInterestIds(userUuid),
      ]);

      _allInterests = results[0] as List<Interest>;
      _selectedIds = Set<int>.from(results[1] as Set<int>);
    } catch (e) {
      _error = 'Erro ao carregar interesses';
      debugPrint('InterestController.load: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggle(int interestId) {
    if (_allInterests.isNotEmpty &&
        !_allInterests.any((i) => i.id == interestId)) {
      return;
    }
    if (_selectedIds.contains(interestId)) {
      _selectedIds.remove(interestId);
    } else {
      _selectedIds.add(interestId);
    }
    notifyListeners();
  }

  Future<bool> save({required String userUuid}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ok = await _service.setUserInterests(
        userUuid: userUuid,
        interestIds: _selectedIds,
      );
      if (!ok) _error = 'Erro ao salvar interesses';
      return ok;
    } catch (e) {
      _error = 'Erro ao salvar interesses';
      debugPrint('InterestController.save: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelection(Set<int> ids) {
    _selectedIds = ids;
    notifyListeners();
  }
}
