import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/students_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SiarApp());
}

class SiarApp extends StatelessWidget {
  const SiarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIAR — Sistema de Alertas Tempranas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A3C5E)),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Map<String, dynamic>? _user;

  void _onLogin(Map<String, dynamic> user) {
    setState(() => _user = user);
  }

  void _onLogout() {
    setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return LoginScreen(onLogin: _onLogin);
    }
    return MainLayout(user: _user!, onLogout: _onLogout);
  }
}

class MainLayout extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;
  const MainLayout({super.key, required this.user, required this.onLogout});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  Color _rolColor() {
    final rol = widget.user['rol'] ?? '';
    if (rol == 'admin') return const Color(0xFFC0392B);
    if (rol == 'coordinador') return const Color(0xFF8B5E0A);
    return const Color(0xFF2E6A1A);
  }

  String _rolLabel() {
    final rol = widget.user['rol'] ?? '';
    if (rol == 'admin') return 'Admin';
    if (rol == 'coordinador') return 'Coordinador';
    return 'Docente';
  }

  List<Widget> get _screens => [
    DashboardScreen(user: widget.user),
    StudentsScreen(user: widget.user),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: const Color(0xFF1A3C5E),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(color: Colors.white),
            unselectedIconTheme: IconThemeData(color: Colors.white.withOpacity(0.5)),
            selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            unselectedLabelTextStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
              child: Column(
                children: [
                  const Text('SIAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Alertas Tempranas', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _rolColor(), borderRadius: BorderRadius.circular(99)),
                    child: Text(_rolLabel(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.user['nombre'] ?? '', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10), textAlign: TextAlign.center),
                ],
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: IconButton(
                icon: Icon(Icons.logout, color: Colors.white.withOpacity(0.7)),
                tooltip: 'Cerrar sesión',
                onPressed: widget.onLogout,
              ),
            ),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.people_outlined), selectedIcon: Icon(Icons.people), label: Text('Estudiantes')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}