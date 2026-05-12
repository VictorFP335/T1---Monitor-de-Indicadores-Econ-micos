import 'package:cloud_firestore/cloud_firestore.dart';

class AnaliseSalva {
  final String id;
  final String nomeAnalise;
  final String indicadorNome;
  final int indicadorCodigo;
  final String dataInicial;
  final String dataFinal;
  final double media;
  final double minimo;
  final double maximo;
  final double variacao;
  final String descricao;
  final DateTime criadoEm;

  const AnaliseSalva({
    required this.id,
    required this.nomeAnalise,
    required this.descricao,
    required this.indicadorNome,
    required this.indicadorCodigo,
    required this.dataInicial,
    required this.dataFinal,
    required this.media,
    required this.minimo,
    required this.maximo,
    required this.variacao,
    required this.criadoEm,
  });

  factory AnaliseSalva.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AnaliseSalva(
      id: doc.id,
      nomeAnalise: d['nomeAnalise'] as String,
      descricao: d['descricao'] as String? ?? '',
      indicadorNome: d['indicadorNome'] as String,
      indicadorCodigo: (d['indicadorCodigo'] as num).toInt(),
      dataInicial: d['dataInicial'] as String,
      dataFinal: d['dataFinal'] as String,
      media: (d['media'] as num).toDouble(),
      minimo: (d['minimo'] as num).toDouble(),
      maximo: (d['maximo'] as num).toDouble(),
      variacao: (d['variacao'] as num).toDouble(),
      criadoEm: (d['criadoEm'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'nomeAnalise': nomeAnalise,
        'descricao': descricao,
        'indicadorNome': indicadorNome,
        'indicadorCodigo': indicadorCodigo,
        'dataInicial': dataInicial,
        'dataFinal': dataFinal,
        'media': media,
        'minimo': minimo,
        'maximo': maximo,
        'variacao': variacao,
        'criadoEm': Timestamp.fromDate(criadoEm),
      };
}
