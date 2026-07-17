import 'package:flutter/material.dart';
import 'package:ithinkwash/core/entities/concepto_entity.dart';
import 'package:ithinkwash/core/theme_app.dart';
import 'package:ithinkwash/shared/enums/estados_general.dart';
import 'package:ithinkwash/shared/enums/tipo_cobro.dart';

class ConceptoCardWidget extends StatelessWidget {
  final TserConceptoEntity concepto;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ConceptoCardWidget({
    super.key,
    required this.concepto,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final activo = concepto.estado.toUpperCase() == EstadosGeneral.ACTIVO.state;
    final color = activo ? ThemeApp.primary : ThemeApp.textSecondary;
    final tipoLabel = TipoCobro.getTipoCobroLabel(concepto.tipoCobro);
    final unidad =
        concepto.unidadMedida != null && concepto.unidadMedida!.isNotEmpty
            ? '/${concepto.unidadMedida}'
            : '';

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: activo ? Colors.grey.shade300 : Colors.red.shade100,
            width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onEdit(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(Icons.local_laundry_service, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(concepto.nombre,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: activo
                                      ? ThemeApp.textPrimary
                                      : ThemeApp.textSecondary,
                                  fontFamily: ThemeApp.fontFamily)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: activo
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                              activo
                                  ? EstadosGeneral.ACTIVO.getLabel
                                  : EstadosGeneral.INACTIVO.getLabel,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: activo ? Colors.green : Colors.red,
                                  fontFamily: ThemeApp.fontFamily)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.monetization_on,
                            size: 13, color: ThemeApp.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                            '\$${concepto.precioBase.toStringAsFixed(2)}$unidad',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ThemeApp.primary,
                                fontFamily: ThemeApp.fontFamily)),
                        const SizedBox(width: 10),
                        Icon(Icons.category_outlined,
                            size: 13, color: ThemeApp.textSecondary),
                        const SizedBox(width: 4),
                        Text(tipoLabel,
                            style: const TextStyle(
                                fontSize: 12,
                                color: ThemeApp.textSecondary,
                                fontFamily: ThemeApp.fontFamily)),
                      ],
                    ),
                    if (concepto.descripcion != null &&
                        concepto.descripcion!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(concepto.descripcion!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                color: ThemeApp.textSecondary,
                                fontStyle: FontStyle.italic,
                                fontFamily: ThemeApp.fontFamily)),
                      ),
                  ],
                ),
              ),
              IconButton(
                  icon: Icon(activo ? Icons.delete_outline : Icons.play_arrow,
                      size: 20,
                      color: activo ? ThemeApp.error : ThemeApp.success),
                  onPressed: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}
