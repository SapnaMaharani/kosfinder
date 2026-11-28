
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kos.dart';

class KosRepository {
  final SupabaseClient _client;

  KosRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // Mengambil semua data kos untuk pengguna publik.
  Future<List<Kos>> getPublicKos() async {
    try {
      final response = await _client
          .from('kos')
          .select()
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((item) => Kos.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat daftar kos: $e');
    }
  }

  // Mengambil ID pengguna yang sedang login.
  String _getCurrentUserId() {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    return user.id;
  }

  // Mengambil daftar kos milik pengguna yang login.
  Future<List<Kos>> getMyKos() async {
    try {
      final userId = _getCurrentUserId();

      final response = await _client
          .from('kos')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((item) => Kos.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat kos milik sendiri: $e');
    }
  }

  // Menambahkan kos dengan owner_id pengguna yang login.
  Future<void> addKos(Map<String, dynamic> kosData) async {
    try {
      final userId = _getCurrentUserId();

      await _client.from('kos').insert({
        ...kosData,
        'owner_id': userId,
      });
    } catch (e) {
      throw Exception('Gagal menambahkan kos: $e');
    }
  }

  // Mengubah data kos milik pengguna yang login.
  Future<void> updateKos(
    String kosId,
    Map<String, dynamic> kosData,
  ) async {
    try {
      final userId = _getCurrentUserId();

      final response = await _client
          .from('kos')
          .update({
            ...kosData,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', kosId)
          .eq('owner_id', userId)
          .select('id, jumlah_kamar')
          .maybeSingle();

      if (response == null) {
        throw Exception(
          'Data kos tidak ditemukan atau kamu tidak memiliki akses untuk mengubahnya.',
        );
      }
    } catch (e) {
      throw Exception('Gagal mengubah data kos: $e');
    }
  }

  // Menghapus kos milik pengguna yang login.
  Future<void> deleteKos(String kosId) async {
    try {
      final userId = _getCurrentUserId();

      await _client
          .from('kos')
          .delete()
          .eq('id', kosId)
          .eq('owner_id', userId);
    } catch (e) {
      throw Exception('Gagal menghapus kos: $e');
    }
  }
}
