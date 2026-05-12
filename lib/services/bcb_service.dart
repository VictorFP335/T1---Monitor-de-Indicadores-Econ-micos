import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dado_serie.dart';

class BcbService {
  static const _base = 'https://api.bcb.gov.br/dados/serie/bcdata.sgs';

  Future<List<DadoSerie>> buscarSerie({
    required int codigo,
    required String dataInicial,
    required String dataFinal,
  }) async {
    final url = Uri.parse(
      '$_base.$codigo/dados?formato=json&dataInicial=$dataInicial&dataFinal=$dataFinal',
    );
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('Erro na API BCB (${response.statusCode})');
      }
      final List<dynamic> json = jsonDecode(response.body);
      return json
          .map((e) => DadoSerie.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Falha na conexão: Verifique sua internet.');
    }
  }

  Future<DadoSerie?> buscarUltimoValor(int codigo) async {
    final hoje = DateTime.now();
    final inicio = hoje.subtract(const Duration(days: 120));
    final fmt = _fmt;
    try {
      final dados = await buscarSerie(
        codigo: codigo,
        dataInicial: fmt(inicio),
        dataFinal: fmt(hoje),
      );
      if (dados.isEmpty) return null;
      return dados.last;
    } catch (_) {
      return null;
    }
  }

  String Function(DateTime) get _fmt => (d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
