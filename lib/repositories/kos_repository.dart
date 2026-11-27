
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kos.dart';

class KosRepository {
  final SupabaseClient _client;

  KosRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

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
}
