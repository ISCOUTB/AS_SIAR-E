import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _data = {};
  List<Map<String, dynamic>> _programas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    final data = await ApiService.getDashboardData();
    final programas = await ApiService.getProgramsDistribution();
    setState(() {
      _data = data;
      _programas = programas;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final metricas = _data['metricas'] ?? {};
    final alertas = List<Map<String, dynamic>>.from(_data['alertas'] ?? []);
    final rol = widget.user['rol'] ?? '';
    final esDocente = rol == 'docente';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Dashboard', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: const Color(0xFFEDF5E7), borderRadius: BorderRadius.circular(99)),
            child: const Row(children: [
              Icon(Icons.circle, size: 8, color: Color(0xFF2E6A1A)),
              SizedBox(width: 6),
              Text('En vivo', style: TextStyle(fontSize: 12, color: Color(0xFF2E6A1A), fontWeight: FontWeight.w500)),
            ]),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarDatos, tooltip: 'Recargar'),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Métricas
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: [
                      _MetricCard(label: 'Total Estudiantes', value: '${metricas['total'] ?? 0}', sub: 'Periodo 2026-1'),
                      _MetricCard(label: 'Riesgo Alto', value: '${metricas['alto'] ?? 0}', sub: 'Requieren atención', valueColor: const Color(0xFFC0392B)),
                      _MetricCard(label: 'Riesgo Medio', value: '${metricas['medio'] ?? 0}', sub: 'En seguimiento', valueColor: const Color(0xFF8B5E0A)),
                      _MetricCard(label: 'Riesgo Bajo', value: '${metricas['bajo'] ?? 0}', sub: 'Estables', valueColor: const Color(0xFF2E6A1A)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Distribución por programa
                  const Text('Distribución por Programa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _programas.isEmpty
                      ? const Text('Sin datos de programas.', style: TextStyle(color: Color(0xFF6B6960)))
                      : Column(
                          children: _programas.map((p) => _ProgramBar(
                            programa: p['programa'] ?? '',
                            alto: (p['alto'] ?? 0) as int,
                            medio: (p['medio'] ?? 0) as int,
                            bajo: (p['bajo'] ?? 0) as int,
                          )).toList(),
                        ),

                  // Alertas recientes — solo admin y coordinador
                  if (!esDocente) ...[
                    const SizedBox(height: 24),
                    const Text('Alertas Recientes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    alertas.isEmpty
                        ? const Text('No hay alertas recientes.', style: TextStyle(color: Color(0xFF6B6960)))
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: alertas.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (_, i) {
                                final a = alertas[i];
                                final nivel = a['nivel'] ?? '';
                                final color = nivel == 'Alto'
                                    ? const Color(0xFFC0392B)
                                    : nivel == 'Medio'
                                        ? const Color(0xFF8B5E0A)
                                        : const Color(0xFF2E6A1A);
                                final bgColor = nivel == 'Alto'
                                    ? const Color(0xFFFDEEEC)
                                    : nivel == 'Medio'
                                        ? const Color(0xFFFDF3E1)
                                        : const Color(0xFFEDF5E7);
                                return ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(99)),
                                    child: Text(nivel, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                                  ),
                                  title: Text(a['nombre'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                  subtitle: Text('${a['programa'] ?? ''} · ${a['motivo'] ?? ''}', style: const TextStyle(fontSize: 12)),
                                  trailing: Text(a['fecha'] ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF9E9D96))),
                                );
                              },
                            ),
                          ),
                  ],

                  // Mensaje especial para docente
                  if (esDocente) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF5E7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2E6A1A).withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.info_outline, color: Color(0xFF2E6A1A), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Puedes ver y gestionar tus estudiantes en la sección "Estudiantes".',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF2E6A1A)),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label, value, sub;
  final Color valueColor;
  const _MetricCard({required this.label, required this.value, required this.sub, this.valueColor = const Color(0xFF1A1917)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: Color(0xFF9E9D96), letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: valueColor)),
          Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9D96))),
        ],
      ),
    );
  }
}

class _ProgramBar extends StatelessWidget {
  final String programa;
  final int alto, medio, bajo;
  const _ProgramBar({required this.programa, required this.alto, required this.medio, required this.bajo});

  @override
  Widget build(BuildContext context) {
    final total = alto + medio + bajo;
    if (total == 0) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(programa, style: const TextStyle(fontSize: 12, color: Color(0xFF6B6960)))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(children: [
                if (alto > 0) Flexible(flex: alto, child: Container(height: 20, color: const Color(0xFFC0392B))),
                if (medio > 0) Flexible(flex: medio, child: Container(height: 20, color: const Color(0xFFE67E22))),
                if (bajo > 0) Flexible(flex: bajo, child: Container(height: 20, color: const Color(0xFF27AE60))),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          Text('$total', style: const TextStyle(fontSize: 12, color: Color(0xFF6B6960))),
        ],
      ),
    );
  }
}

