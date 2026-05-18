import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _cargando = false;
  String _error = '';
  bool _verPass = false;

  Future<void> _login() async {
    setState(() { _cargando = true; _error = ''; });
    final result = await ApiService.login(_userController.text, _passController.text);
    setState(() => _cargando = false);

    if (result['success'] == true) {
      widget.onLogin(result['user']);
    } else {
      setState(() => _error = result['message'] ?? 'Error al iniciar sesión');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3C5E),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SIAR', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A3C5E))),
              const Text('Sistema de Alertas Tempranas', style: TextStyle(fontSize: 13, color: Color(0xFF6B6960))),
              const SizedBox(height: 32),
              const Text('Usuario', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(
                controller: _userController,
                decoration: InputDecoration(
                  hintText: 'Ingresa tu usuario',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Contraseña', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(
                controller: _passController,
                obscureText: !_verPass,
                decoration: InputDecoration(
                  hintText: 'Ingresa tu contraseña',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  suffixIcon: IconButton(
                    icon: Icon(_verPass ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _verPass = !_verPass),
                  ),
                ),
                onSubmitted: (_) => _login(),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFFDEEEC), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Color(0xFFC0392B), size: 16),
                    const SizedBox(width: 8),
                    Text(_error, style: const TextStyle(color: Color(0xFFC0392B), fontSize: 13)),
                  ]),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3C5E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _cargando ? null : _login,
                  child: _cargando
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Iniciar Sesión', style: TextStyle(color: Colors.white, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF5F4F0), borderRadius: BorderRadius.circular(8)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Usuarios de prueba:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B6960))),
                    SizedBox(height: 4),
                    Text('admin / admin123 — Administrador', style: TextStyle(fontSize: 11, color: Color(0xFF6B6960))),
                    Text('coordinador / coord123 — Coordinador', style: TextStyle(fontSize: 11, color: Color(0xFF6B6960))),
                    Text('docente1 / doc123 — Docente', style: TextStyle(fontSize: 11, color: Color(0xFF6B6960))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}