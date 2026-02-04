import 'package:flutter/material.dart';
import '../../../services/obra_service.dart';
import '../../../models/obra.dart';
import '../../models/actividad.dart';
import '../../models/avance.dart';
import '../widgets/avance_card.dart';
import '../widgets/actividad_card.dart';
import '../widgets/loading_widget.dart';

class ObraFormScreen extends StatefulWidget {
  final Obra? obra; // Si es null, es creación. Si tiene valor, es edición.

  const ObraFormScreen({super.key, this.obra});

  @override
  State<ObraFormScreen> createState() => _ObraFormScreenState();
}

class _ObraFormScreenState extends State<ObraFormScreen> {
  // SERVICIOS
  final ObraService _obraService = ObraService();

  // CONTROLADORES DEL FORMULARIO
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _direccionController = TextEditingController();
  final _clienteController = TextEditingController();
  final _presupuestoController = TextEditingController();

  // FECHAS
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  // ESTADO
  String _estadoSeleccionado = 'PLANIFICADA';
  bool _isLoading = false;
  bool _isSaving = false;
  bool _showAvancesSection = false;

  // LISTAS (para demostración - en realidad vendrían del servicio)
  List<Map<String, dynamic>> _actividadesDemo = [];
  List<Map<String, dynamic>> _avancesDemo = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosObra();
    _cargarDatosDemo();
  }

  void _cargarDatosObra() {
    if (widget.obra != null) {
      final obra = widget.obra!;
      _nombreController.text = obra.nombre;
      _descripcionController.text = obra.descripcion ?? '';
      _direccionController.text = obra.direccion ?? '';
      _clienteController.text = obra.cliente ?? '';
      _presupuestoController.text = obra.presupuesto?.toString() ?? '';
      _fechaInicio = obra.fechaInicio;
      _fechaFin = obra.fechaFin;
      _estadoSeleccionado = obra.estado;
    }
  }

  void _cargarDatosDemo() {
    // Datos de ejemplo para demostración
    _actividadesDemo = [
      {
        'id': 1,
        'nombre': 'Excavación y Nivelación',
        'descripcion': 'Preparación del terreno',
        'peso': 15.0,
        'estado': 'COMPLETADA',
        'porcentaje': 100.0,
      },
      {
        'id': 2,
        'nombre': 'Cimentación',
        'descripcion': 'Hormigonado de cimientos',
        'peso': 25.0,
        'estado': 'EN_PROGRESO',
        'porcentaje': 75.0,
      },
      {
        'id': 3,
        'nombre': 'Estructura Principal',
        'descripcion': 'Armado y hormigonado de columnas',
        'peso': 35.0,
        'estado': 'PENDIENTE',
        'porcentaje': 0.0,
      },
    ];

    _avancesDemo = [
      {
        'id': 1,
        'fecha': DateTime.now().subtract(const Duration(days: 2)),
        'porcentaje': 100.0,
        'horas': 8.0,
        'descripcion': 'Excavación completada en área norte',
        'estado': 'FINALIZADO',
        'tieneEvidencia': true,
      },
      {
        'id': 2,
        'fecha': DateTime.now().subtract(const Duration(days: 1)),
        'porcentaje': 75.0,
        'horas': 6.0,
        'descripcion': 'Hormigonado de cimientos al 75%',
        'estado': 'EN_PROCESO',
        'tieneEvidencia': false,
      },
    ];
  }

  Future<void> _seleccionarFecha(BuildContext context, bool esInicio) async {
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.orange,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        if (esInicio) {
          _fechaInicio = fechaSeleccionada;
        } else {
          _fechaFin = fechaSeleccionada;
        }
      });
    }
  }

  String? _validarCampo(String? value, String nombreCampo, {bool required = true}) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'El $nombreCampo es requerido';
    }
    return null;
  }

  String? _validarPresupuesto(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final presupuesto = double.tryParse(value);
    if (presupuesto == null) {
      return 'Ingrese un valor numérico válido';
    }
    if (presupuesto < 0) {
      return 'El presupuesto no puede ser negativo';
    }
    return null;
  }

  String? _validarFechas() {
    if (_fechaInicio != null && _fechaFin != null) {
      if (_fechaFin!.isBefore(_fechaInicio!)) {
        return 'La fecha fin no puede ser anterior a la fecha inicio';
      }
    }
    return null;
  }

  Future<void> _guardarObra() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final errorFechas = _validarFechas();
    if (errorFechas != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorFechas),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final nuevaObra = Obra(
        idObra: widget.obra?.idObra,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isNotEmpty
            ? _descripcionController.text.trim()
            : null,
        direccion: _direccionController.text.trim().isNotEmpty
            ? _direccionController.text.trim()
            : null,
        cliente: _clienteController.text.trim().isNotEmpty
            ? _clienteController.text.trim()
            : null,
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
        presupuesto: _presupuestoController.text.trim().isNotEmpty
            ? double.tryParse(_presupuestoController.text.trim())
            : null,
        estado: _estadoSeleccionado,
        porcentajeAvance: 0,
      );

      if (widget.obra == null) {
        // CREAR NUEVA OBRA
        await _obraService.crearObra(nuevaObra);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Obra creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Regresar a la lista después de un breve delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        // ACTUALIZAR OBRA EXISTENTE
        await _obraService.actualizarObra(nuevaObra);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Obra actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Regresar después de un breve delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _mostrarConfirmacionCancelar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Descartar cambios?'),
        content: const Text('Los cambios no guardados se perderán.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar editando'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.obra == null ? 'Nueva Obra' : 'Editar Obra',
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      actions: [
        if (widget.obra != null)
          IconButton(
            onPressed: () => setState(() => _showAvancesSection = !_showAvancesSection),
            icon: Icon(
              _showAvancesSection ? Icons.list : Icons.add_chart,
              color: Colors.white,
            ),
            tooltip: _showAvancesSection ? 'Ocultar avances' : 'Mostrar avances',
          ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ID DE OBRA (si es edición)
              if (widget.obra != null && widget.obra!.idObra != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'ID Obra: ${widget.obra!.idObra}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              // NOMBRE DE LA OBRA
              const Text(
                'Nombre de la Obra:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  hintText: 'Ingrese el nombre de la obra',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) => _validarCampo(value, 'nombre'),
                maxLines: 1,
              ),

              const SizedBox(height: 16),

              // DESCRIPCIÓN
              const Text(
                'Descripción:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  hintText: 'Descripción de la obra',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // DIRECCIÓN
              const Text(
                'Dirección:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(
                  hintText: 'Dirección de la obra',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // CLIENTE
              const Text(
                'Cliente:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _clienteController,
                decoration: InputDecoration(
                  hintText: 'Cliente',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatesAndBudgetCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FECHA INICIO
            const Text(
              'Fecha Inicio:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _seleccionarFecha(context, true),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _fechaInicio != null
                          ? '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}'
                          : 'Seleccionar fecha',
                      style: TextStyle(
                        fontSize: 14,
                        color: _fechaInicio != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // FECHA FIN
            const Text(
              'Fecha Fin:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _seleccionarFecha(context, false),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_available, color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _fechaFin != null
                          ? '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}'
                          : 'Seleccionar fecha',
                      style: TextStyle(
                        fontSize: 14,
                        color: _fechaFin != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // PRESUPUESTO
            const Text(
              'Presupuesto:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _presupuestoController,
              decoration: InputDecoration(
                hintText: '0.00',
                prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              keyboardType: TextInputType.number,
              validator: _validarPresupuesto,
            ),

            const SizedBox(height: 16),

            // ESTADO
            const Text(
              'Estado:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _estadoSeleccionado,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'PLANIFICADA',
                  child: Text('PLANIFICADA'),
                ),
                DropdownMenuItem(
                  value: 'ACTIVA',
                  child: Text('ACTIVA'),
                ),
                DropdownMenuItem(
                  value: 'SUSPENDIDA',
                  child: Text('SUSPENDIDA'),
                ),
                DropdownMenuItem(
                  value: 'FINALIZADA',
                  child: Text('FINALIZADA'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _estadoSeleccionado = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // BOTÓN CANCELAR
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : _mostrarConfirmacionCancelar,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'CANCELAR',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // BOTÓN GUARDAR
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _guardarObra,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                widget.obra == null ? 'REGISTRAR' : 'GUARDAR CAMBIOS',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActividadesSection() {
    if (_actividadesDemo.isEmpty) return const SizedBox();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actividades de la Obra',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ..._actividadesDemo.map((actividad) {
              return ActividadCard(
                actividad: Actividad(
                  idActividad: actividad['id'],
                  idObra: widget.obra?.idObra ?? 0,
                  nombre: actividad['nombre'],
                  descripcion: actividad['descripcion'],
                  pesoPorcentual: actividad['peso'],
                  estado: actividad['estado'],
                  porcentajeCompletado: actividad['porcentaje'],
                ),
                onEditar: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Editar actividad: ${actividad['nombre']}'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                onEliminar: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Eliminar actividad: ${actividad['nombre']}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                onVerAvances: () {
                  setState(() => _showAvancesSection = true);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvancesSection() {
    if (!_showAvancesSection || _avancesDemo.isEmpty) return const SizedBox();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Historial de Avances',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _showAvancesSection = false),
                  icon: const Icon(Icons.close),
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._avancesDemo.map((avance) {
              return AvanceCard(
                avance: Avance(
                  idAvance: avance['id'],
                  idActividad: 1, // Demo
                  idUsuario: 1, // Demo
                  fecha: avance['fecha'],
                  porcentajeEjecutado: avance['porcentaje'],
                  horasTrabajadas: avance['horas'],
                  descripcion: avance['descripcion'],
                  evidenciaFoto: avance['tieneEvidencia'] ? 'demo.jpg' : null,
                  estado: avance['estado'],
                ),
                onToggleEstado: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cambiar estado del avance'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                onEliminar: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Eliminar avance'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                onVerEvidencia: avance['tieneEvidencia']
                    ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ver evidencia fotográfica'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                    : null,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),

      body: _isLoading
          ? const LoadingWidget(message: 'Cargando información...')
          : SingleChildScrollView(
        child: Column(
          children: [
            // FORMULARIO DE OBRA
            _buildFormCard(),

            // FECHAS Y PRESUPUESTO
            _buildDatesAndBudgetCard(),

            // SECCIÓN DE ACTIVIDADES (solo en edición)
            if (widget.obra != null) _buildActividadesSection(),

            // SECCIÓN DE AVANCES (solo si se activa)
            _buildAvancesSection(),

            // BOTONES DE GUARDAR/CANCELAR
            _buildSaveButtons(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _clienteController.dispose();
    _presupuestoController.dispose();
    super.dispose();
  }
}