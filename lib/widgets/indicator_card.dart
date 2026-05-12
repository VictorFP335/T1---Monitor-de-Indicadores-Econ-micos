import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/indicador.dart';
import '../models/dado_serie.dart';
import '../services/bcb_service.dart';

class IndicatorCard extends StatelessWidget {
  final Indicador indicador;
  final IconData icon;
  final Color color;
  final String unidade;
  final BcbService bcbService;
  final VoidCallback onTap;

  const IndicatorCard({
    super.key,
    required this.indicador,
    required this.icon,
    required this.color,
    required this.unidade,
    required this.bcbService,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'indicador_${indicador.codigo}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: AppTheme.glassCard(borderColor: color.withOpacity(0.3)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withOpacity(0.2),
                          color.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          indicador.nome,
                          style: GoogleFonts.inter(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cód. ${indicador.codigo}',
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<DadoSerie?>(
                    future: bcbService.buscarUltimoValor(indicador.codigo),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.accent,
                          ),
                        );
                      }
                      if (!snap.hasData || snap.data == null) {
                        return const Text('—', style: TextStyle(color: AppTheme.textSecondary));
                      }
                      final dado = snap.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${unidade.startsWith('R') ? '$unidade ' : ''}${dado.valor.toStringAsFixed(2)}${unidade.startsWith('%') || unidade.endsWith('%') ? ' $unidade' : ''}',
                            style: GoogleFonts.spaceGrotesk(
                              color: color,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            _fmtData(dado.data),
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _fmtData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
