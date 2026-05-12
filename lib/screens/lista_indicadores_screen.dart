import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/indicador.dart';
import '../services/bcb_service.dart';
import '../services/firestore_service.dart';
import '../services/database_seeder.dart';
import '../widgets/indicator_card.dart';
import 'consulta_screen.dart';
import 'analises_salvas_screen.dart';

class ListaIndicadoresScreen extends StatefulWidget {
  const ListaIndicadoresScreen({super.key});

  @override
  State<ListaIndicadoresScreen> createState() => _ListaIndicadoresScreenState();
}

class _ListaIndicadoresScreenState extends State<ListaIndicadoresScreen> {
  final _firestoreService = FirestoreService();
  final _bcbService = BcbService();
  int _selectedIndex = 0;

  static const _indicadorIcons = {
    11: Icons.percent_rounded,
    433: Icons.trending_up_rounded,
    1: Icons.attach_money_rounded,
    24369: Icons.people_alt_rounded,
    10844: Icons.euro_rounded,
    4380: Icons.account_balance_rounded, // PIB
    188: Icons.shopping_cart_rounded, // INPC
    189: Icons.real_estate_agent_rounded, // IGP-M
    3546: Icons.account_balance_wallet_rounded, // Reservas
    4503: Icons.money_off_rounded, // Dívida
  };

  static const _indicadorColors = {
    11: AppTheme.accent,
    433: AppTheme.error,
    1: AppTheme.success,
    24369: AppTheme.accentGold,
    10844: Color(0xFF64B5F6),
    4380: Color(0xFF81C784),
    188: Color(0xFFFFB74D),
    189: Color(0xFF9575CD),
    3546: Color(0xFF4DD0E1),
    4503: Color(0xFFE57373),
  };

  static const _indicadorUnidades = {
    11: '% a.a.',
    433: '%',
    1: 'R\$',
    24369: '%',
    10844: 'R\$',
    4380: 'Mi R\$',
    188: '%',
    189: '%',
    3546: 'Mi US\$',
    4503: '%',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0 ? _buildLista() : const AnalisesSalvasScreen(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _mostrarDialogNovoIndicador,
              backgroundColor: AppTheme.accent,
              child: const Icon(Icons.add_rounded, color: AppTheme.background),
            )
          : null,
    );
  }

  void _mostrarDialogNovoIndicador() {
    final nomeCtrl = TextEditingController();
    final codCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Text('Novo Indicador', style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomeCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Nome (Ex: Dólar Americano)'),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: codCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Código SGS (Ex: 1)'),
                validator: (v) => int.tryParse(v ?? '') == null ? 'Código inválido' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final ind = Indicador(
                id: '',
                nome: nomeCtrl.text.trim(),
                codigo: int.parse(codCtrl.text.trim()),
              );
              await _firestoreService.salvarIndicador(ind);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.divider)),
        color: AppTheme.background,
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: AppTheme.background,
        selectedItemColor: AppTheme.accent,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Indicadores'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_rounded), label: 'Análises'),
        ],
      ),
    );
  }

  Widget _buildLista() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.5),
              border: const Border(bottom: BorderSide(color: AppTheme.divider)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visão Geral',
                          style: GoogleFonts.inter(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mercado & Economia',
                          style: GoogleFonts.spaceGrotesk(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.dashboard_rounded, color: AppTheme.accent),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        StreamBuilder<List<Indicador>>(
          stream: _firestoreService.streamIndicadores(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
              );
            }

            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 64, color: AppTheme.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum indicador encontrado',
                        style: GoogleFonts.spaceGrotesk(fontSize: 18, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Deseja popular o banco de dados com\nos indicadores padrão do BCB?',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await DatabaseSeeder.seedInitialData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Dados populados com sucesso!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao popular: $e')),
                            );
                          }
                        },
                        icon: const Icon(Icons.auto_fix_high_rounded),
                        label: const Text('Popular Banco de Dados'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: AppTheme.background,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final indicadores = snapshot.data!;

            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: IndicatorCard(
                      indicador: indicadores[index],
                      icon: _indicadorIcons[indicadores[index].codigo] ?? Icons.analytics_rounded,
                      color: _indicadorColors[indicadores[index].codigo] ?? AppTheme.accent,
                      unidade: _indicadorUnidades[indicadores[index].codigo] ?? '',
                      bcbService: _bcbService,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConsultaScreen(indicador: indicadores[index]),
                        ),
                      ),
                    ),
                  ),
                  childCount: indicadores.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
