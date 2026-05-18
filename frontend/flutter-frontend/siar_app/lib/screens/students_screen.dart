import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StudentsScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const StudentsScreen({super.key, required this.user});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _filtroRiesgo = '';
  String _buscar = '';
  List<Map<String, dynamic>> _estudiantes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEstudiantes();
  }

  Future<void> _cargarEstudiantes() async {
    setState(() => _cargando = true);
    final rol = widget.user['rol'] ?? '';
    final programa = widget.user['programa'] ?? '';

    List<Map<String, dynamic>> data = await ApiService.getStudents();

    if (rol == 'docente' && programa.isNotEmpty) {
      data = data.where((e) => e['programa'] == programa).toList();
    }

    setState(() {
      _estudiantes = data;
      _cargando = false;
    });
  }

  Color _riesgoColor(String r) {
    if (r == 'Alto') return const Color(0xFFC0392B);
    if (r == 'Medio') return const Color(0xFF8B5E0A);
    return const Color(0xFF2E6A1A);
  }

  Color _riesgoBg(String r) {
    if (r == 'Alto') return const Color(0xFFFDEEEC);
    if (r == 'Medio') return const Color(0xFFFDF3E1);
    return const Color(0xFFEDF5E7);
  }

  String _getRiesgo(Map<String, dynamic> e) {
    final score = (e['risk_score'] ?? 0).toDouble();
    if (score >= 75) return 'Alto';
    if (score >= 50) return 'Medio';
    return 'Bajo';
  }

  void _abrirDetalle(Map<String, dynamic> e) {
    final riesgo = _getRiesgo(e);
    final yaIntervenido = (e['intervenido'] ?? 0) == 1;
    final studentId = e['student_id'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final intervenido = (e['intervenido'] ?? 0) == 1;
          return AlertDialog(
            title: Row(
              children: [
                Expanded(child: Text(e['nombre'] ?? '')),
                if (intervenido)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFEDF5E7), borderRadius: BorderRadius.circular(99)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_circle, size: 12, color: Color(0xFF2E6A1A)),
                      SizedBox(width: 4),
                      Text('Intervenido', style: TextStyle(fontSize: 11, color: Color(0xFF2E6A1A), fontWeight: FontWeight.w600)),
                    ]),
                  ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${e['programa'] ?? ''} · Semestre ${e['semestre'] ?? ''}° · ${e['student_id'] ?? ''}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B6960)),
                ),
                const Divider(height: 24),
                _detailRow('Nivel de riesgo', '$riesgo — ${(e['risk_score'] ?? 0).toInt()}%', color: _riesgoColor(riesgo)),
                _detailRow('Nota promedio', '${(e['notas'] ?? 0.0).toStringAsFixed(1)} / 5.0'),
                _detailRow('Asistencia', '${(e['asistencia'] ?? 0).toInt()}%'),
                _detailRow('Plataforma', e['plataforma'] ?? ''),
                _detailRow('Recomendación', riesgo == 'Alto' ? 'Contacto urgente con docente.' : riesgo == 'Medio' ? 'Tutorías de apoyo.' : 'Monitoreo estándar.'),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
              if (!intervenido)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A3C5E)),
                  icon: const Icon(Icons.check, color: Colors.white, size: 16),
                  label: const Text('Marcar Intervenido', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    final ok = await ApiService.intervenirEstudiante(studentId);
                    if (ok) {
                      setState(() {
                        final idx = _estudiantes.indexWhere((s) => s['student_id'] == studentId);
                        if (idx != -1) {
                          _estudiantes[idx] = Map<String, dynamic>.from(_estudiantes[idx])..['intervenido'] = 1;
                          e['intervenido'] = 1;
                        }
                      });
                      setDialogState(() {});
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Estudiante marcado como intervenido'),
                            backgroundColor: Color(0xFF2E6A1A),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                )
              else
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E6A1A)),
                  icon: const Icon(Icons.check_circle, color: Colors.white, size: 16),
                  label: const Text('Ya intervenido', style: TextStyle(color: Colors.white)),
                  onPressed: null,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _detailRow(String key, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(fontSize: 13, color: Color(0xFF6B6960))),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color ?? const Color(0xFF1A1917))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _estudiantes.where((e) {
      final riesgo = _getRiesgo(e);
      final nombre = (e['nombre'] ?? '').toString().toLowerCase();
      final id = (e['student_id'] ?? '').toString().toLowerCase();
      final matchRiesgo = _filtroRiesgo.isEmpty || riesgo == _filtroRiesgo;
      final matchBuscar = _buscar.isEmpty || nombre.contains(_buscar.toLowerCase()) || id.contains(_buscar.toLowerCase());
      return matchRiesgo && matchBuscar;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Estudiantes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarEstudiantes, tooltip: 'Recargar'),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre o ID...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          filled: true, fillColor: Colors.white,
                        ),
                        onChanged: (v) => setState(() => _buscar = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _filtroRiesgo.isEmpty ? null : _filtroRiesgo,
                      hint: const Text('Riesgo'),
                      items: ['Alto', 'Medio', 'Bajo'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => setState(() => _filtroRiesgo = v ?? ''),
                    ),
                    if (_filtroRiesgo.isNotEmpty)
                      TextButton(onPressed: () => setState(() => _filtroRiesgo = ''), child: const Text('Limpiar')),
                  ]),
                  const SizedBox(height: 16),
                  _estudiantes.isEmpty
                      ? const Expanded(child: Center(child: Text('No se pudieron cargar los datos de la API.\nVerifica que el backend esté corriendo.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6B6960)))))
                      : Expanded(
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                            child: ListView.separated(
                              itemCount: filtrados.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (_, i) {
                                final e = filtrados[i];
                                final riesgo = _getRiesgo(e);
                                final nombre = e['nombre'] ?? '';
                                final intervenido = (e['intervenido'] ?? 0) == 1;
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: intervenido ? const Color(0xFF2E6A1A) : const Color(0xFF185FA5),
                                    child: intervenido
                                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                                        : Text(nombre.split(' ').map((w) => w[0]).take(2).join(''), style: const TextStyle(color: Colors.white, fontSize: 13)),
                                  ),
                                  title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                  subtitle: Text('${e['programa'] ?? ''} · Semestre ${e['semestre'] ?? ''}° · ${e['student_id'] ?? ''}', style: const TextStyle(fontSize: 12)),
                                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                    if (intervenido)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFFEDF5E7), borderRadius: BorderRadius.circular(99)),
                                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                          Icon(Icons.check_circle, size: 12, color: Color(0xFF2E6A1A)),
                                          SizedBox(width: 4),
                                          Text('Intervenido', style: TextStyle(fontSize: 11, color: Color(0xFF2E6A1A), fontWeight: FontWeight.w600)),
                                        ]),
                                      )
                                    else ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: _riesgoBg(riesgo), borderRadius: BorderRadius.circular(99)),
                                        child: Text(riesgo, style: TextStyle(fontSize: 12, color: _riesgoColor(riesgo), fontWeight: FontWeight.w600)),
                                      ),
                                      const SizedBox(width: 12),
                                      Text('${(e['risk_score'] ?? 0).toInt()}%', style: TextStyle(fontSize: 13, color: _riesgoColor(riesgo), fontWeight: FontWeight.w500)),
                                    ],
                                    const SizedBox(width: 8),
                                    TextButton(onPressed: () => _abrirDetalle(e), child: const Text('Ver')),
                                  ]),
                                );
                              },
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}