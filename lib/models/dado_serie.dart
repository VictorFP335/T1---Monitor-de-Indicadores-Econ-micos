class DadoSerie {
  final DateTime data;
  final double valor;

  const DadoSerie({required this.data, required this.valor});

  factory DadoSerie.fromJson(Map<String, dynamic> json) {
    // API returns date as "DD/MM/AAAA"
    final partes = (json['data'] as String).split('/');
    final data = DateTime(
      int.parse(partes[2]),
      int.parse(partes[1]),
      int.parse(partes[0]),
    );
    final valor = double.tryParse(
          (json['valor'] as String).replaceAll(',', '.'),
        ) ??
        0.0;
    return DadoSerie(data: data, valor: valor);
  }
}
