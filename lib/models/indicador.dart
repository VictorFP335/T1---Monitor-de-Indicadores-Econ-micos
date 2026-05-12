import 'package:cloud_firestore/cloud_firestore.dart';

class Indicador {
  final String id;
  final String nome;
  final int codigo;

  const Indicador({
    required this.id,
    required this.nome,
    required this.codigo,
  });

  factory Indicador.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Indicador(
      id: doc.id,
      nome: data['nome'] as String,
      codigo: (data['codigo'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'codigo': codigo,
      };

  @override
  String toString() => 'Indicador($nome, $codigo)';
}
