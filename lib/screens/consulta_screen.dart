import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/indicador.dart';
import '../models/dado_serie.dart';
import '../services/bcb_service.dart';
import '../widgets/dado_item.dart';
import 'analise_screen.dart';

class ConsultaScreen extends StatefulWidget {
  final Indicador indicador;
  const ConsultaScreen({super.key, required this.indicador});

  @override
  State<ConsultaScreen> createState() => _ConsultaScreenState();
}

class _ConsultaScreenState extends State<ConsultaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataInicialCtrl = TextEditingController();
  final _dataFinalCtrl = TextEditingController();
  final _bcbService = BcbService();

  Future<List<DadoSerie>>? _futureConsulta;
  bool _consultou = false;

  @override
  void dispose() {
    _dataInicialCtrl.dispose();
    _dataFinalCtrl.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(TextEditingController ctrl) async {
    DateTime initial;
    try {
      final partes = ctrl.text.split('/');
      initial = DateTime(
          int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0]));
    } catch (_) {
      initial = DateTime.now();
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.accent,
            onPrimary: AppTheme.background,
            surface: AppTheme.cardBg,
            onSurface: AppTheme.textPrimary,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        ctrl.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _consultar() {
    if (!_formKey.currentState!.validate()) return;

    // Validar se data final é após inicial
    final partesIni = _dataInicialCtrl.text.split('/');
    final dIni = DateTime(int.parse(partesIni[2]), int.parse(partesIni[1]),
        int.parse(partesIni[0]));
    final partesFim = _dataFinalCtrl.text.split('/');
    final dFim = DateTime(int.parse(partesFim[2]), int.parse(partesFim[1]),
        int.parse(partesFim[0]));

    if (dFim.isBefore(dIni)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A data final não pode ser anterior à data inicial.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _consultou = true;
      _futureConsulta = _bcbService.buscarSerie(
        codigo: widget.indicador.codigo,
        dataInicial: _dataInicialCtrl.text,
        dataFinal: _dataFinalCtrl.text,
      );
    });
  }

  String? _validarData(String? val) {
    if (val == null || val.isEmpty) return 'Campo obrigatório';
    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regex.hasMatch(val)) return 'Use o formato DD/MM/AAAA';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.indicador.nome),
        actions: [
          if (_consultou && _futureConsulta != null)
            FutureBuilder<List<DadoSerie>>(
              future: _futureConsulta,
              builder: (context, snap) {
                if (snap.hasData && snap.data!.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.analytics_rounded),
                    tooltip: 'Ver análise',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnaliseScreen(
                          indicador: widget.indicador,
                          dados: snap.data!,
                          dataInicial: _dataInicialCtrl.text,
                          dataFinal: _dataFinalCtrl.text,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFormulario(),
          const Divider(height: 1),
          Expanded(child: _buildResultado()),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.4),
        border: const Border(bottom: BorderSide(color: AppTheme.divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.tune_rounded, color: AppTheme.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Filtros de Consulta',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dataInicialCtrl,
                    readOnly: true,
                    validator: _validarData,
                    style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      labelText: 'Data Inicial',
                      prefixIcon: const Icon(Icons.date_range_rounded, color: AppTheme.accent, size: 18),
                      filled: true,
                      fillColor: AppTheme.background.withOpacity(0.5),
                    ),
                    onTap: () => _selecionarData(_dataInicialCtrl),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _dataFinalCtrl,
                    readOnly: true,
                    validator: _validarData,
                    style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      labelText: 'Data Final',
                      prefixIcon: const Icon(Icons.date_range_rounded, color: AppTheme.accentRose, size: 18),
                      filled: true,
                      fillColor: AppTheme.background.withOpacity(0.5),
                    ),
                    onTap: () => _selecionarData(_dataFinalCtrl),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _consultar,
                icon: const Icon(Icons.auto_graph_rounded, size: 20),
                label: Text('ANALISAR DADOS', style: GoogleFonts.spaceGrotesk(letterSpacing: 1.2)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.background,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultado() {
    if (!_consultou) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded,
                size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'Selecione o período e clique em Consultar',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }
    return FutureBuilder<List<DadoSerie>>(
      future: _futureConsulta,
      builder: (context, snapshot) {
        // Estado: carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppTheme.accent),
                SizedBox(height: 16),
                Text('Buscando dados na API do BCB...',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          );
        }
        // Estado: erro
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      color: AppTheme.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao consultar a API',
                    style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.error,
                        fontWeight: FontWeight.w700,
                        fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _consultar,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Tentar novamente'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      side: const BorderSide(color: AppTheme.accent),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        // Estado: dados
        final dados = snapshot.data ?? [];
        if (dados.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inbox_rounded,
                    color: AppTheme.textSecondary, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Nenhum dado encontrado para o período',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            _buildHeaderResultado(dados.length),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: dados.length,
                itemBuilder: (context, index) {
                  final dado =
                      dados[dados.length - 1 - index]; // mais recente primeiro
                  return DadoItem(
                      dado: dado,
                      index: dados.length - 1 - index,
                      total: dados.length);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderResultado(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppTheme.surface,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$total registros',
              style: GoogleFonts.inter(
                color: AppTheme.success,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                'Toque em ',
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
              const Icon(Icons.analytics_rounded,
                  color: AppTheme.accent, size: 18),
              Text(
                ' no topo para análise',
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Class _DadoItem removed and moved to lib/widgets/dado_item.dart
