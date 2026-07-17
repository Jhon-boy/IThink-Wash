import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/entities/orden_entity.dart';
import 'package:ithinkwash/core/theme_app.dart';
import 'package:ithinkwash/core/utils/app_util.dart';
import 'package:ithinkwash/modules/user/data/datasource/persona_data_source.dart';

class OrdenCardWidget extends ConsumerStatefulWidget {
  final TordOrdenEntity orden;
  final VoidCallback onTap;

  const OrdenCardWidget({
    super.key,
    required this.orden,
    required this.onTap,
  });

  @override
  ConsumerState<OrdenCardWidget> createState() => _OrdenCardWidgetState();
}

class _OrdenCardWidgetState extends ConsumerState<OrdenCardWidget> {
  String _nombreCliente = '';
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarCliente();
  }

  Future<void> _cargarCliente() async {
    try {
      final ds = PersonasRemoteDataSource(ref: ref);
      final persona =
          await ds.getPersonaById(widget.orden.idPersona.toString());
      if (persona != null && mounted) {
        setState(() {
          _nombreCliente = '${persona.nombres} ${persona.apellidos}';
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.orden;
    final color = AppUtils.getColorEstado(o.estado);
    final estadoLabel = AppUtils.getLabelEstado(o.estado);
    final fecha = AppUtils.formatDate(o.fechaRecepcion);
    const estiloSmall =
        TextStyle(fontSize: 12, color: ThemeApp.textSecondary, fontFamily: ThemeApp.fontFamily);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 82,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            o.numeroOrden ?? 'Orden #${o.idOrden}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                fontFamily: ThemeApp.fontFamily),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(estadoLabel,
                              style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: ThemeApp.fontFamily)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 14, color: ThemeApp.textSecondary),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            _cargando ? '...' : _nombreCliente,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFamily: ThemeApp.fontFamily),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 13, color: ThemeApp.textSecondary),
                        const SizedBox(width: 5),
                        Text(fecha, style: estiloSmall),
                        if (o.comentario != null && o.comentario!.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(o.comentario!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: ThemeApp.textSecondary,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: ThemeApp.fontFamily)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('\$${(o.total ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: ThemeApp.primary,
                                fontFamily: ThemeApp.fontFamily)),
                        if (o.saldoPendiente != null && o.saldoPendiente! > 0) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.warning_amber_rounded,
                              size: 14, color: ThemeApp.error),
                          const SizedBox(width: 3),
                          Text('Saldo: \$${o.saldoPendiente!.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ThemeApp.error,
                                  fontFamily: ThemeApp.fontFamily)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: ThemeApp.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
