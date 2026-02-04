import 'package:flutter/material.dart';
import 'package:regcons/screens/obras/obras_screen.dart';
import 'package:regcons/screens/reporte_seguridad_screen.dart';
import 'package:regcons/screens/reportes_screen.dart';
import '../models/obra.dart';
import '../services/obra_service.dart';
import 'news_page.dart';
import 'configuraciones_screen.dart';

class HomePage extends StatefulWidget {
  final String nombreUsuario;

  const HomePage({super.key, required this.nombreUsuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ÍNDICE DEL MENÚ
  int _selectedIndex = 0;

  // SERVICIO DE OBRAS
  final ObraService _obraService = ObraService();

  // DATOS DE LA OBRA ACTIVA
  Obra? _obraSeleccionada;
  List<Obra> _obrasActivas = [];
  bool _isLoading = true;

  // TÍTULOS POR SECCIÓN
  static const List<String> _titles = [
    'Inicio',
    'Noticias',
    'Reportar Incidente',
    'Ver Reportes',
    'Ajustes',
  ];

  @override
  void initState() {
    super.initState();
    _cargarObrasActivas();
  }

  Future<void> _cargarObrasActivas() async {
    setState(() => _isLoading = true);

    try {
      final obras = await _obraService.obtenerObrasActivas();
      setState(() {
        _obrasActivas = obras;
        if (obras.isNotEmpty) {
          _obraSeleccionada = obras.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar obras: $e');
      setState(() => _isLoading = false);
    }
  }

  // CONTENIDO POR SECCIÓN
  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const NewsPage();
      case 2:
        return const ReporteSeguridadScreen();
      case 3:
        return const ReportesScreen();
      case 4:
        return const ConfiguracionesScreen();
      default:
        return const Center(child: Text('Sección no disponible'));
    }
  }

  // CONTENIDO DE INICIO (HOME)
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TÍTULO DE BIENVENIDA
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.nombreUsuario,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // TARJETA DE OBRA ACTIVA
          Card(
            color: const Color.fromARGB(120, 24, 27, 53),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.construction, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'OBRA ACTIVA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Seleccione la obra:',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // SPINNER DE OBRAS
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    )
                  else if (_obrasActivas.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[800]!.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Colors.orange),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'No hay obras activas.\nCrea una nueva obra para comenzar.',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ObrasScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: const Text('Crear obra'),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800]!.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Obra>(
                          value: _obraSeleccionada,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E2130),
                          style: const TextStyle(color: Colors.white),
                          items: _obrasActivas.map((obra) {
                            return DropdownMenuItem<Obra>(
                              value: obra,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      obra.estadoIcon,
                                      color: obra.estadoColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        obra.nombre,
                                        style: const TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (obra) {
                            if (obra != null) {
                              setState(() => _obraSeleccionada = obra);
                            }
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // PROGRESO DE AVANCE
                  if (_obraSeleccionada != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Avance: ${_obraSeleccionada!.porcentajeAvance?.toStringAsFixed(1) ?? 0}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _obraSeleccionada!.estadoColor
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _obraSeleccionada!.estadoColor,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _obraSeleccionada!.estado,
                                style: TextStyle(
                                  color: _obraSeleccionada!.estadoColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        LinearProgressIndicator(
                          value:
                              (_obraSeleccionada!.porcentajeAvance ?? 0) / 100,
                          backgroundColor: Colors.grey[800],
                          color: _obraSeleccionada!.estadoColor,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(6),
                        ),

                        const SizedBox(height: 8),

                        if (_obraSeleccionada!.descripcion != null)
                          Text(
                            _obraSeleccionada!.descripcion!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // BOTONES PRINCIPALES
          const Text(
            'ACCIONES RÁPIDAS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildActionButton(
                icon: Icons.construction,
                label: 'Gestionar\nObras',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ObrasScreen(),
                    ),
                  );
                },
              ),

              _buildActionButton(
                icon: Icons.assignment_add,
                label: 'Registrar\nAvance',
                color: Colors.green,
                onTap: () {
                  // TODO: Navegar a registro de avance
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registro de avance - En desarrollo'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),

              _buildActionButton(
                icon: Icons.warning_amber,
                label: 'Reportar\nIncidente',
                color: Colors.red,
                onTap: () {
                  setState(() => _selectedIndex = 2);
                },
              ),

              _buildActionButton(
                icon: Icons.bar_chart,
                label: 'Ver\nReportes',
                color: Colors.purple,
                onTap: () {
                  setState(() => _selectedIndex = 3);
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // RESUMEN RÁPIDO
          Card(
            color: const Color.fromARGB(120, 24, 27, 53),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<Map<String, int>>(
                future: _obraService.getEstadisticas(),
                builder: (context, snapshot) {
                  final stats =
                      snapshot.data ??
                      {
                        'total': 0,
                        'activas': 0,
                        'planificadas': 0,
                        'finalizadas': 0,
                      };

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RESUMEN DE OBRAS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'TOTAL',
                            stats['total'].toString(),
                            Icons.business,
                          ),
                          _buildStatItem(
                            'ACTIVAS',
                            stats['activas'].toString(),
                            Icons.play_circle_fill,
                            color: Colors.green,
                          ),
                          _buildStatItem(
                            'FINALIZADAS',
                            stats['finalizadas'].toString(),
                            Icons.check_circle,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color.fromARGB(120, 24, 27, 53),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? Colors.orange).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color ?? Colors.orange, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
        ),
      ],
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
      backgroundColor: const Color(0xFF10121D),

      // APP BAR DINÁMICO
      appBar: AppBar(
        backgroundColor: const Color(0xFF181B35),
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  onPressed: _cargarObrasActivas,
                  icon: const Icon(Icons.refresh, color: Colors.orange),
                  tooltip: 'Actualizar obras',
                ),
              ]
            : null,
      ),

      // CONTENIDO CENTRAL
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/tapiz_bg.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.3),
            ),
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
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Noticias',
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
