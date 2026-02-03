import 'package:flutter/material.dart';
import 'package:regcons/screens/news_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ÍNDICE DEL MENÚ
  int _selectedIndex = 0;

  // TÍTULOS POR SECCIÓN
  static const List<String> _titles = [
    'Noticias',
    'Registrar Obras y Avances',
    'Reportar Incidente',
    'Ver Reportes',
    'Ajustes',
  ];

  // CONTENIDO TEMPORAL
  Widget _buildContent() {
    if (_selectedIndex == 0) {
      return const NewsPage();
    }

    return Center(
      child: Text(
        _titles[_selectedIndex],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // EVENTO MENÚ
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // CONTENIDO CENTRAL
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/tapiz_bg.png', fit: BoxFit.cover),
          ),
          _buildContent(),
        ],
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF181B35),
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Noticias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.construction),
            label: 'Obras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber),
            label: 'Incidente',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
