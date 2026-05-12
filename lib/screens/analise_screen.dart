import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/indicador.dart';
import '../models/dado_serie.dart';
import '../models/analise_salva.dart';
import '../services/firestore_service.dart';

class AnaliseScreen extends StatefulWidget {
  final Indicador indicador;
  final List<DadoSerie> dados;
  final String dataInicial;
  final String dataFinal;

  const AnaliseScreen({
    super.key,
    required this.indicador,
    required this.dados,
    required this.dataInicial,
    required this.dataFinal,
  });

  @override
  State<AnaliseScreen> createState() => _AnaliseScreenState();
}

class _AnaliseScreenState extends State<AnaliseScreen> with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  late TabController _tabController;
  late _Estatisticas _stats;
  late List<DadoSerie> _dadosFiltrados;
  int _janelaMM = 7;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _dadosFiltrados = widget.dados;
    _stats = _Estatisticas.calcular(_dadosFiltrados, _janelaMM);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Análise — ${widget.indicador.nome}'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accent,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.show_chart_rounded), text: 'Gráfico'),
            Tab(icon: Icon(Icons.analytics_rounded), text: 'Estatísticas'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _salvando ? null : _mostrarDialogSalvar,
              icon: _salvando
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent))
                  : const Icon(Icons.bookmark_add_rounded, size: 20),
              label: Text(
                'SALVAR',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1.1,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.accent,
                backgroundColor: AppTheme.accent.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGrafico(),
          _buildEstatisticas(),
        ],
      ),
    );
  }

  // ---- TAB 1: GRÁFICO ----
  Widget _buildGrafico() {
    if (_dadosFiltrados.isEmpty) {
      return const Center(child: Text('Sem dados para exibir.'));
    }

    final spots = <FlSpot>[];
    final spotsMM = <FlSpot>[];
    final mm = _stats.mediaMovel;

    for (int i = 0; i < _dadosFiltrados.length; i++) {
      spots.add(FlSpot(i.toDouble(), _dadosFiltrados[i].valor));
      if (i < mm.length && !mm[i].isNaN) {
        spotsMM.add(FlSpot(i.toDouble(), mm[i]));
      }
    }

    final minY = (_stats.minimo * 0.95);
    final maxY = (_stats.maximo * 1.05);
    final count = _dadosFiltrados.length;

    // Calcular índices de min e max
    int iMin = 0, iMax = 0;
    for (int i = 1; i < _dadosFiltrados.length; i++) {
      if (_dadosFiltrados[i].valor < _dadosFiltrados[iMin].valor) iMin = i;
      if (_dadosFiltrados[i].valor > _dadosFiltrados[iMax].valor) iMax = i;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPeriodoChip(),
          const SizedBox(height: 16),
          // Legenda
          Wrap(
            spacing: 16,
            children: [
              _buildLegendaItem(AppTheme.accent, widget.indicador.nome),
              _buildLegendaItem(AppTheme.accentGold, 'Média móvel (${_janelaMM}p)'),
              _buildLegendaItem(AppTheme.error.withOpacity(0.7), 'Máximo'),
              _buildLegendaItem(AppTheme.success.withOpacity(0.7), 'Mínimo'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 300,
            padding: const EdgeInsets.only(right: 16, top: 8),
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: AppTheme.divider,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      getTitlesWidget: (v, _) => Text(
                        v.toStringAsFixed(1),
                        style: GoogleFonts.inter(
                            color: AppTheme.textSecondary, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: max(1.0, (count / 6)).toDouble(),
                      getTitlesWidget: (v, _) {
                        final i = v.round();
                        if (i < 0 || i >= _dadosFiltrados.length) return const SizedBox.shrink();
                        final d = _dadosFiltrados[i].data;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${d.month.toString().padLeft(2, '0')}/${d.year.toString().substring(2)}',
                            style: GoogleFonts.inter(
                                color: AppTheme.textSecondary, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.surface.withOpacity(0.9),
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (spots) => spots.map((s) {
                      if (s.barIndex == 0) {
                        final i = s.x.toInt();
                        final d = _dadosFiltrados[i].data;
                        final diff = s.y - _stats.media;
                        final diffPerc = (diff / _stats.media) * 100;

                        return LineTooltipItem(
                          '${d.day}/${d.month}/${d.year}\n',
                          GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            TextSpan(
                              text: s.y.toStringAsFixed(4),
                              style: GoogleFonts.spaceGrotesk(
                                color: AppTheme.accent,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: '\n${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(4)} (${diffPerc.toStringAsFixed(1)}%)',
                              style: GoogleFonts.inter(
                                color: diff >= 0 ? AppTheme.success : AppTheme.error,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      }
                      return null;
                    }).toList(),
                  ),
                  getTouchedSpotIndicator: (barData, spots) {
                    return spots.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: AppTheme.accent.withOpacity(0.3),
                          strokeWidth: 2,
                          dashArray: [5, 5],
                        ),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                            radius: 6,
                            color: AppTheme.accent,
                            strokeWidth: 2,
                            strokeColor: AppTheme.background,
                          ),
                        ),
                      );
                    }).toList();
                  },
                ),
                lineBarsData: [
                  // Linha principal
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    color: AppTheme.accent,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, _) => spot.x == iMin || spot.x == iMax,
                      getDotPainter: (spot, _, __, ___) {
                        final isMin = spot.x.toInt() == iMin;
                        return FlDotCirclePainter(
                          radius: 5,
                          color: isMin ? AppTheme.success : AppTheme.error,
                          strokeColor: AppTheme.background,
                          strokeWidth: 2,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.accent.withOpacity(0.3),
                          AppTheme.accent.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                  // Média móvel
                  if (spotsMM.length > 1)
                    LineChartBarData(
                      spots: spotsMM,
                      isCurved: true,
                      curveSmoothness: 0.4,
                      color: AppTheme.accentGold.withOpacity(0.8),
                      barWidth: 1.5,
                      dotData: const FlDotData(show: false),
                      dashArray: [6, 4],
                    ),
                ],
                // Linha da média
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: _stats.media,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                      strokeWidth: 1,
                      dashArray: [4, 6],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        labelResolver: (_) => 'Média: ${_stats.media.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                            color: AppTheme.textSecondary, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Controle janela MM
          Row(
            children: [
              Text('Janela da média móvel:',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(width: 12),
              ...([7, 14, 30].map((j) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$j'),
                      selected: _janelaMM == j,
                      onSelected: (_) => setState(() {
                        _janelaMM = j;
                        _stats = _Estatisticas.calcular(_dadosFiltrados, _janelaMM);
                      }),
                      selectedColor: AppTheme.accent.withOpacity(0.2),
                      backgroundColor: AppTheme.surface,
                      labelStyle: GoogleFonts.inter(
                        color: _janelaMM == j ? AppTheme.accent : AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                      side: BorderSide(
                        color: _janelaMM == j ? AppTheme.accent : AppTheme.divider,
                      ),
                    ),
                  ))),
            ],
          ),
          const SizedBox(height: 16),
          _buildMiniStats(),
        ],
      ),
    );
  }

  Widget _buildPeriodoResumo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accent.withOpacity(0.15), AppTheme.accent.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, color: AppTheme.accent, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Período da Análise',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${widget.dataInicial} até ${widget.dataFinal}',
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_dadosFiltrados.length} pontos',
              style: GoogleFonts.inter(
                color: AppTheme.accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendaItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 3, color: color),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _buildMiniStats() {
    return Row(
      children: [
        Expanded(child: _StatChip('Mín', _stats.minimo.toStringAsFixed(4), AppTheme.success)),
        const SizedBox(width: 8),
        Expanded(child: _StatChip('Máx', _stats.maximo.toStringAsFixed(4), AppTheme.error)),
        const SizedBox(width: 8),
        Expanded(child: _StatChip('Média', _stats.media.toStringAsFixed(4), AppTheme.accent)),
      ],
    );
  }

  // ---- TAB 2: ESTATÍSTICAS ----
  Widget _buildEstatisticas() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPeriodoChip(),
          const SizedBox(height: 20),
          Text(
            'Resumo Estatístico',
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          _buildGridStats(),
          const SizedBox(height: 24),
          Text(
            'Distribuição de Valores',
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildHistograma(),
          const SizedBox(height: 24),
          Text(
            'Variação Mês a Mês',
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildBarrasVariacao(),
        ],
      ),
    );
  }

  Widget _buildGridStats() {
    final items = [
      _StatItem('Mínimo', _stats.minimo.toStringAsFixed(4), Icons.arrow_downward_rounded, AppTheme.success),
      _StatItem('Máximo', _stats.maximo.toStringAsFixed(4), Icons.arrow_upward_rounded, AppTheme.error),
      _StatItem('Média', _stats.media.toStringAsFixed(4), Icons.horizontal_rule_rounded, AppTheme.accent),
      _StatItem('Mediana', _stats.mediana.toStringAsFixed(4), Icons.center_focus_strong_rounded, AppTheme.accentGold),
      _StatItem('Desvio Padrão', _stats.desvioPadrao.toStringAsFixed(4), Icons.bar_chart_rounded, const Color(0xFFB388FF)),
      _StatItem('Variação %', '${_stats.variacaoPercent.toStringAsFixed(2)}%',
          _stats.variacaoPercent >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          _stats.variacaoPercent >= 0 ? AppTheme.success : AppTheme.error),
      _StatItem('Observações', '${_dadosFiltrados.length}', Icons.dataset_rounded, AppTheme.textSecondary),
      _StatItem('Coef. Variação', '${_stats.coefVariacao.toStringAsFixed(2)}%', Icons.percent_rounded, const Color(0xFFFF8A65)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildStatCard(items[i]),
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.valor,
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistograma() {
    // Cria 8 faixas
    final min = _stats.minimo;
    final max = _stats.maximo;
    final range = max - min;
    if (range <= 0) {
      return Center(
        child: Text(
          'Valores constantes no período.',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12),
        ),
      );
    }

    const buckets = 8;
    final counts = List.filled(buckets, 0);
    for (final d in _dadosFiltrados) {
      int b = ((d.valor - min) / range * buckets).floor();
      if (b >= buckets) b = buckets - 1;
      counts[b]++;
    }
    final maxCount = counts.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: maxCount.toDouble() * 1.2,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(color: AppTheme.divider, strokeWidth: 0.8),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 9),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i % 2 != 0) return const SizedBox.shrink();
                  final val = min + (range / buckets * i);
                  return Text(
                    val.toStringAsFixed(1),
                    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 9),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(
            buckets,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: counts[i].toDouble(),
                  color: AppTheme.accent.withOpacity(0.7 + 0.3 * counts[i] / maxCount),
                  width: 24,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarrasVariacao() {
    if (_dadosFiltrados.length < 2) return const SizedBox.shrink();

    // Pega apenas os últimos 12 para não poluir
    final dados = _dadosFiltrados.length > 13
        ? _dadosFiltrados.sublist(_dadosFiltrados.length - 13)
        : _dadosFiltrados;
    final variacoes = <double>[];
    for (int i = 1; i < dados.length; i++) {
      if (dados[i - 1].valor != 0) {
        variacoes.add((dados[i].valor - dados[i - 1].valor) / dados[i - 1].valor.abs() * 100);
      } else {
        variacoes.add(0);
      }
    }

    if (variacoes.isEmpty) {
      return const Center(child: Text('Dados insuficientes para variação.'));
    }
    final maxAbs = variacoes.map((v) => v.abs()).reduce(max);

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: maxAbs * 1.3,
          minY: -maxAbs * 1.3,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: v == 0 ? AppTheme.textSecondary.withOpacity(0.5) : AppTheme.divider,
              strokeWidth: v == 0 ? 1.5 : 0.8,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text(
                  '${v.toStringAsFixed(1)}%',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 8),
                ),
              ),
            ),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(
            variacoes.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: variacoes[i],
                  fromY: 0,
                  color: variacoes[i] >= 0 ? AppTheme.success : AppTheme.error,
                  width: 14,
                  borderRadius: BorderRadius.vertical(
                    top: variacoes[i] >= 0
                        ? const Radius.circular(3)
                        : Radius.zero,
                    bottom: variacoes[i] < 0
                        ? const Radius.circular(3)
                        : Radius.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodoChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.date_range_rounded, color: AppTheme.accent, size: 16),
          const SizedBox(width: 8),
          Text(
            '${widget.dataInicial} → ${widget.dataFinal}',
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ---- SALVAR ----
  void _mostrarDialogSalvar() {
    final nomeCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Salvar Análise',
          style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomeCtrl,
                autofocus: true,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Nome da análise',
                  hintText: 'Ex: SELIC 2024 — Alta de juros',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                  if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descrição/Observações',
                  hintText: 'O que você analisou?',
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              await _salvarAnalise(nomeCtrl.text.trim(), descCtrl.text.trim());
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _salvarAnalise(String nome, String descricao) async {
    setState(() => _salvando = true);
    try {
      final analise = AnaliseSalva(
        id: '',
        nomeAnalise: nome,
        descricao: descricao,
        indicadorNome: widget.indicador.nome,
        indicadorCodigo: widget.indicador.codigo,
        dataInicial: widget.dataInicial,
        dataFinal: widget.dataFinal,
        media: _stats.media,
        minimo: _stats.minimo,
        maximo: _stats.maximo,
        variacao: _stats.variacaoPercent,
        criadoEm: DateTime.now(),
      );
      await _firestoreService.salvarAnalise(analise);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Análise "$nome" salva com sucesso!'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }
}

// ---- Modelos de Dados para Visualização ----
class _StatItem {
  final String label;
  final String valor;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.valor, this.icon, this.color);
}

// ---- Cálculo de Estatísticas ----
class _Estatisticas {
  final double minimo;
  final double maximo;
  final double media;
  final double mediana;
  final double desvioPadrao;
  final double variacaoPercent;
  final double coefVariacao;
  final List<double> mediaMovel;

  const _Estatisticas({
    required this.minimo,
    required this.maximo,
    required this.media,
    required this.mediana,
    required this.desvioPadrao,
    required this.variacaoPercent,
    required this.coefVariacao,
    required this.mediaMovel,
  });

  factory _Estatisticas.calcular(List<DadoSerie> dados, int janela) {
    if (dados.isEmpty) {
      return const _Estatisticas(
          minimo: 0, maximo: 0, media: 0, mediana: 0,
          desvioPadrao: 0, variacaoPercent: 0, coefVariacao: 0, mediaMovel: []);
    }
    final valores = dados.map((d) => d.valor).toList();
    final n = valores.length;

    final minimo = valores.reduce(min);
    final maximo = valores.reduce(max);
    final media = valores.reduce((a, b) => a + b) / n;

    final sorted = [...valores]..sort();
    final mediana = n.isOdd
        ? sorted[n ~/ 2]
        : (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2;

    final variancia = valores.map((v) => pow(v - media, 2)).reduce((a, b) => a + b) / n;
    final desvio = sqrt(variancia);
    final coefVar = media != 0 ? (desvio / media.abs()) * 100 : 0.0;

    final variacaoPercent = valores.first != 0
        ? (valores.last - valores.first) / valores.first.abs() * 100
        : 0.0;

    // Média Móvel
    final mm = <double>[];
    for (int i = 0; i < n; i++) {
      if (i < janela - 1) {
        mm.add(double.nan);
      } else {
        final window = valores.sublist(i - janela + 1, i + 1);
        mm.add(window.reduce((a, b) => a + b) / janela);
      }
    }

    return _Estatisticas(
      minimo: minimo,
      maximo: maximo,
      media: media,
      mediana: mediana,
      desvioPadrao: desvio,
      variacaoPercent: variacaoPercent,
      coefVariacao: coefVar,
      mediaMovel: mm,
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String valor;
  final Color color;

  const _StatChip(this.label, this.valor, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(valor, style: GoogleFonts.spaceGrotesk(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
    );
  }
}
