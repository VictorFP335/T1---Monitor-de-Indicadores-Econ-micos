import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/indicador.dart';
import '../models/analise_salva.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ---- Indicadores (read-only) ----
  Stream<List<Indicador>> streamIndicadores() {
    return _db.collection('indicadores').snapshots().map(
          (snap) => snap.docs.map(Indicador.fromDoc).toList(),
        );
  }

  Future<void> salvarIndicador(Indicador indicador) async {
    await _db.collection('indicadores').add(indicador.toMap());
  }

  // ---- Análises Salvas ----
  Stream<List<AnaliseSalva>> streamAnalises() {
    return _db
        .collection('analises')
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(AnaliseSalva.fromDoc).toList());
  }

  Future<void> salvarAnalise(AnaliseSalva analise) async {
    await _db.collection('analises').add(analise.toMap());
  }

  Future<void> deletarAnalise(String id) async {
    await _db.collection('analises').doc(id).delete();
  }
}
