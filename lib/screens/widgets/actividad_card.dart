import 'package:flutter/material.dart';
import '../../../models/actividad.dart';

class ActividadCard extends StatelessWidget {
  final Actividad actividad;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;
  final VoidCallback? onVerAvances;

  const ActividadCard({
    super.key,
    required this.actividad,
    this.onEditar,
    this.onEliminar,
    this.onVerAvances,
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
            // CABECERA: Nombre y estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    actividad.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: actividad.estadoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: actividad.estadoColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        actividad.estadoIcon,
                        color: actividad.estadoColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        actividad.estadoTexto,
                        style: TextStyle(
                          color: actividad.estadoColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // DESCRIPCIÓN (si existe)
            if (actividad.descripcion != null && actividad.descripcion!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  actividad.descripcion!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // PESO PORCENTUAL Y AVANCE
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  // PESO PORCENTUAL
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    child: Text(
                      'Peso: ${actividad.pesoTexto}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // PORCENTAJE COMPLETADO
                  if (actividad.porcentajeCompletado != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: actividad.porcentajeCompletado! >= 100
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: actividad.porcentajeCompletado! >= 100
                              ? Colors.green
                              : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${actividad.porcentajeCompletado!.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: actividad.porcentajeCompletado! >= 100
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // BARRA DE PROGRESO (si hay porcentaje completado)
            if (actividad.porcentajeCompletado != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(
                  value: actividad.porcentajeCompletado! / 100,
                  backgroundColor: Colors.grey[300],
                  color: actividad.porcentajeCompletado! >= 100
                      ? Colors.green
                      : Colors.orange,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

            // CONTRIBUCIÓN AL AVANCE TOTAL
            if (actividad.porcentajeCompletado != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Contribución: ${actividad.contribucionAvance.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // BOTONES DE ACCIÓN
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // BOTÓN VER AVANCES
                  if (onVerAvances != null)
                    OutlinedButton.icon(
                      onPressed: onVerAvances,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      icon: const Icon(Icons.list, size: 14),
                      label: const Text(
                        'Avances',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),

                  const Spacer(),

                  // BOTÓN EDITAR
                  if (onEditar != null)
                    IconButton(
                      onPressed: onEditar,
                      icon: const Icon(Icons.edit, size: 18),
                      color: Colors.orange,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),

                  const SizedBox(width: 8),

                  // BOTÓN ELIMINAR
                  if (onEliminar != null)
                    IconButton(
                      onPressed: onEliminar,
                      icon: const Icon(Icons.delete, size: 18),
                      color: Colors.red,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}