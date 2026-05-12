import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/analise_salva.dart';
import '../models/indicador.dart';
import '../services/firestore_service.dart';
import '../services/bcb_service.dart';
import 'analise_screen.dart';

class AnalisesSalvasScreen extends StatefulWidget {
  const AnalisesSalvasScreen({super.key});

  @override
  State<AnalisesSalvasScreen> createState() => _AnalisesSalvasScreenState();
}

class _AnalisesSalvasScreenState extends State<AnalisesSalvasScreen> {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análises Salvas'),
      ),
      body: StreamBuilder<List<AnaliseSalva>>(
        stream: _firestoreService.streamAnalises(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.accent));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar análises: ${snapshot.error}',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          final analises = snapshot.data ?? [];

          if (analises.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border_rounded,
                      color: AppTheme.textSecondary.withOpacity(0.3), size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma análise salva ainda.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: analises.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _AnaliseCard(
                  analise: analises[index],
                  onDelete: () => _confirmarDelete(analises[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmarDelete(AnaliseSalva analise) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Excluir Análise?'),
        content: Text('Deseja realmente excluir "${analise.nomeAnalise}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _firestoreService.deletarAnalise(analise.id);
              if (mounted) Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _AnaliseCard extends StatefulWidget {
  final AnaliseSalva analise;
  final VoidCallback onDelete;

  const _AnaliseCard({required this.analise, required this.onDelete});

  @override
  State<_AnaliseCard> createState() => _AnaliseCardState();
}

class _AnaliseCardState extends State<_AnaliseCard> {
  bool _carregando = false;

  Future<void> _abrirAnalise(BuildContext context) async {
    setState(() => _carregando = true);
    try {
      final bcb = BcbService();
      final dados = await bcb.buscarSerie(
        codigo: widget.analise.indicadorCodigo,
        dataInicial: widget.analise.dataInicial,
        dataFinal: widget.analise.dataFinal,
      );

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AnaliseScreen(
              indicador: Indicador(
                id: '',
                nome: widget.analise.indicadorNome,
                codigo: widget.analise.indicadorCodigo,
              ),
              dados: dados,
              dataInicial: widget.analise.dataInicial,
              dataFinal: widget.analise.dataFinal,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final variacaoPos = widget.analise.variacao >= 0;
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _abrirAnalise(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: AppTheme.glassCard(),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.analise.nomeAnalise,
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.analise.indicadorNome,
                                style: GoogleFonts.inter(
                                    color: AppTheme.accent, fontSize: 13),
                              ),
                              if (widget.analise.descricao.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.analise.descricao,
                                  style: GoogleFonts.inter(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onDelete,
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppTheme.error),
                          tooltip: 'Excluir',
                        ),
                      ],
                    ),
                  ),
                  // Período
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range_rounded,
                            color: AppTheme.textSecondary, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.analise.dataInicial} → ${widget.analise.dataFinal}',
                          style: GoogleFonts.inter(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Stats
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        _StatBadge('Mín', widget.analise.minimo.toStringAsFixed(2), AppTheme.success),
                        const SizedBox(width: 8),
                        _StatBadge('Máx', widget.analise.maximo.toStringAsFixed(2), AppTheme.error),
                        const SizedBox(width: 8),
                        _StatBadge('Média', widget.analise.media.toStringAsFixed(2), AppTheme.accent),
                        const SizedBox(width: 8),
                        _StatBadge(
                          'Var.',
                          '${variacaoPos ? '+' : ''}${widget.analise.variacao.toStringAsFixed(1)}%',
                          variacaoPos ? AppTheme.success : AppTheme.error,
                        ),
                      ],
                    ),
                  ),
                  // Footer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppTheme.divider)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            color: AppTheme.textSecondary, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          _fmtDateTime(widget.analise.criadoEm),
                          style: GoogleFonts.inter(
                              color: AppTheme.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_carregando)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.accent),
              ),
            ),
          ),
      ],
    );
  }

  String _fmtDateTime(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: 10)),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
