
import 'package:flutter/foundation.dart';

import '../models/kos.dart';
import '../repositories/kos_repository.dart';

class KosProvider extends ChangeNotifier {
  final KosRepository _repository;

  KosProvider({KosRepository? repository})
      : _repository = repository ?? KosRepository();

  List<Kos> _allKosList = [];
  List<Kos> _myKosList = [];

  bool _isLoading = false;
  bool _isOwnerLoading = false;

  String? _errorMessage;
  String? _ownerErrorMessage;
  String _searchQuery = '';

  int? _minPrice;
  int? _maxPrice;

  String? _jenisFilter;
  final Set<String> _selectedFacilities = {};

  // Daftar kos publik dengan pencarian dan seluruh filter.
  List<Kos> get kosList {
    final query = _searchQuery.toLowerCase();

    return _allKosList.where((kos) {
      final matchesSearch = query.isEmpty ||
          kos.namaKos.toLowerCase().contains(query) ||
          kos.alamatLengkap.toLowerCase().contains(query) ||
          kos.area.toLowerCase().contains(query);

      final matchesMinPrice =
          _minPrice == null || kos.hargaBulanan >= _minPrice!;

      final matchesMaxPrice =
          _maxPrice == null || kos.hargaBulanan <= _maxPrice!;

      final matchesJenis =
          _jenisFilter == null || kos.jenis == _jenisFilter;

      // Logika AND: kos harus memiliki semua fasilitas terpilih.
      final matchesFacilities = _selectedFacilities.every(
        (facility) => kos.fasilitas.contains(facility),
      );

      return matchesSearch &&
          matchesMinPrice &&
          matchesMaxPrice &&
          matchesJenis &&
          matchesFacilities;
    }).toList();
  }

  List<Kos> get myKosList => _myKosList;

  bool get isLoading => _isLoading;
  bool get isOwnerLoading => _isOwnerLoading;

  String? get errorMessage => _errorMessage;
  String? get ownerErrorMessage => _ownerErrorMessage;

  String get searchQuery => _searchQuery;

  int? get minPrice => _minPrice;
  int? get maxPrice => _maxPrice;

  String? get jenisFilter => _jenisFilter;

  Set<String> get selectedFacilities =>
      Set.unmodifiable(_selectedFacilities);

  // Pencarian berdasarkan nama, alamat, dan area.
  void searchKos(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  // Mengatur filter harga.
  void setPriceFilter({
    int? minPrice,
    int? maxPrice,
  }) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    notifyListeners();
  }

  // Mengatur filter jenis kos.
  void setJenisFilter(String? jenis) {
    _jenisFilter = jenis;
    notifyListeners();
  }

  // Memilih atau membatalkan fasilitas.
  void toggleFacility(String facility) {
    if (_selectedFacilities.contains(facility)) {
      _selectedFacilities.remove(facility);
    } else {
      _selectedFacilities.add(facility);
    }

    notifyListeners();
  }

  // Menghapus seluruh filter harga, jenis, dan fasilitas.
  void resetFilters() {
    _minPrice = null;
    _maxPrice = null;
    _jenisFilter = null;
    _selectedFacilities.clear();
    notifyListeners();
  }

  // Menghapus filter harga saja.
  void resetPriceFilter() {
    _minPrice = null;
    _maxPrice = null;
    notifyListeners();
  }

  // Memuat seluruh kos publik.
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

  // Memuat kos milik pengguna yang login.
  Future<void> loadMyKos() async {
    _isOwnerLoading = true;
    _ownerErrorMessage = null;
    notifyListeners();

    try {
      _myKosList = await _repository.getMyKos();
    } catch (e) {
      _ownerErrorMessage = e.toString();
    } finally {
      _isOwnerLoading = false;
      notifyListeners();
    }
  }

  Future<void> addKos(Map<String, dynamic> kosData) async {
    await _repository.addKos(kosData);
    await loadMyKos();
    await loadKos();
  }

  Future<void> updateKos(
    String kosId,
    Map<String, dynamic> kosData,
  ) async {
    await _repository.updateKos(kosId, kosData);
    await loadMyKos();
    await loadKos();
  }

  Future<void> deleteKos(String kosId) async {
    await _repository.deleteKos(kosId);
    await loadMyKos();
    await loadKos();
  }
}
