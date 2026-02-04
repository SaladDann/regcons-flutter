import 'package:flutter/material.dart';
import '../../../models/avance.dart';

class AvanceCard extends StatelessWidget {
  final Avance avance;
  final VoidCallback? onToggleEstado;
  final VoidCallback? onEliminar;
  final VoidCallback? onVerEvidencia;

  const AvanceCard({
    super.key,
    required this.avance,
    this.onToggleEstado,
    this.onEliminar,
    this.onVerEvidencia,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CABECERA: Fecha y estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  avance.fechaHoraCompleta,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: avance.estadoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: avance.estadoColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        avance.estadoIcon,
                        color: avance.estadoColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        avance.estadoTexto,
                        style: TextStyle(
                          color: avance.estadoColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // PORCENTAJE EJECUTADO
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getPorcentajeColor(avance.porcentajeEjecutado),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.percent,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      avance.porcentajeTexto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // HORAS TRABAJADAS (si existen)
            if (avance.tieneHorasTrabajadas)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.orange,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      avance.horasTexto!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

            // DESCRIPCIÓN (si existe)
            if (avance.tieneDescripcion)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  avance.descripcion!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // EVIDENCIA FOTO (si existe)
            if (avance.tieneEvidencia && onVerEvidencia != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: GestureDetector(
                  onTap: onVerEvidencia,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: Stack(
                      children: [
                        // Placeholder para imagen (en realidad se cargaría la imagen)
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_camera,
                                color: Colors.grey,
                                size: 32,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Evidencia fotográfica',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Botón para ver
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // BOTONES DE ACCIÓN
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // BOTÓN TOGGLE ESTADO
                  if (onToggleEstado != null)
                    ElevatedButton(
                      onPressed: onToggleEstado,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: avance.estado == 'FINALIZADO'
                            ? Colors.grey
                            : const Color(0xFF4CAF50), // Verde
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        avance.estado == 'FINALIZADO' ? 'Finalizado' : 'Finalizar',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),

                  const Spacer(),

                  // BOTÓN ELIMINAR
                  if (onEliminar != null)
                    ElevatedButton(
                      onPressed: onEliminar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF44336), // Rojo
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPorcentajeColor(double porcentaje) {
    if (porcentaje >= 100) return Colors.green;
    if (porcentaje >= 75) return Colors.lightGreen;
    if (porcentaje >= 50) return Colors.yellow[700]!;
    if (porcentaje >= 25) return Colors.orange;
    return Colors.red;
  }
}