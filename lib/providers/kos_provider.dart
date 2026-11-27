
import 'package:flutter/foundation.dart';

import '../models/kos.dart';
import '../repositories/kos_repository.dart';

class KosProvider extends ChangeNotifier {
  final KosRepository _repository;

  KosProvider({KosRepository? repository})
      : _repository = repository ?? KosRepository();

  List<Kos> _allKosList = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Kos> get kosList {
    if (_searchQuery.isEmpty) {
      return _allKosList;
    }

    final query = _searchQuery.toLowerCase();

    return _allKosList.where((kos) {
      return kos.namaKos.toLowerCase().contains(query) ||
          kos.alamatLengkap.toLowerCase().contains(query) ||
          kos.area.toLowerCase().contains(query);
    }).toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  void searchKos(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  Future<void> loadKos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allKosList = await _repository.getPublicKos();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
