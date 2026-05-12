import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/indicador.dart';

class DatabaseSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> seedInitialData() async {
    final indicadoresColl = _db.collection('indicadores');
    
    // Verifica se já existem indicadores
    final snapshot = await indicadoresColl.limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      print('Base de dados já contém indicadores. Pulando seeding...');
      return;
    }

    print('Iniciando seeding da base de dados...');

    final initialData = [
      {'nome': 'Taxa SELIC', 'codigo': 11},
      {'nome': 'IPCA (Inflação)', 'codigo': 433},
      {'nome': 'Dólar (USD/BRL)', 'codigo': 1},
      {'nome': 'Taxa de Desemprego', 'codigo': 24369},
      {'nome': 'Euro (EUR/BRL)', 'codigo': 10844},
      {'nome': 'PIB Mensal (R\$)', 'codigo': 4380},
      {'nome': 'INPC', 'codigo': 188},
      {'nome': 'IGP-M', 'codigo': 189},
      {'nome': 'Reservas Int. (US\$)', 'codigo': 3546},
      {'nome': 'Dívida Líquida (%)', 'codigo': 4503},
    ];

    for (var data in initialData) {
      await indicadoresColl.add(data);
    }

    print('Seeding concluído com sucesso!');
  }
}
