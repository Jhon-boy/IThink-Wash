import 'package:flutter/material.dart';
import 'package:ithinkwash/core/entities/servicio_adicional_entity.dart';
import 'package:ithinkwash/core/theme_app.dart';
import 'package:ithinkwash/core/utils/formatters.dart';
import 'package:ithinkwash/shared/enums/estados_general.dart';
import 'package:ithinkwash/shared/widgets/dialog_generic_widget.dart';

class ServicioAdicionalFormDialog extends StatefulWidget {
  final TserServicioAdicionalEntity? servicio;

  const ServicioAdicionalFormDialog({super.key, this.servicio});

  static Future<TserServicioAdicionalEntity?> show(
      BuildContext context, TserServicioAdicionalEntity? servicio) {
    return showDialog<TserServicioAdicionalEntity>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ServicioAdicionalFormDialog(servicio: servicio),
    );
  }

  @override
  State<ServicioAdicionalFormDialog> createState() =>
      _ServicioAdicionalFormDialogState();
}

class _ServicioAdicionalFormDialogState
    extends State<ServicioAdicionalFormDialog> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _descripcionCtrl;
  bool _estadoActivo = true;

  @override
  void initState() {
    super.initState();
    final s = widget.servicio;
    _nombreCtrl = TextEditingController(text: s?.nombre ?? '');
    _precioCtrl = TextEditingController(text: s?.precioBase.toString() ?? '');
    _descripcionCtrl = TextEditingController(text: s?.descripcion ?? '');
    _estadoActivo = s?.estado.toUpperCase() == EstadosGeneral.ACTIVO.state;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.servicio != null;
    return DialogoPersonalizadoWidget(
      titulo: isEdit ? 'Editar Servicio Adicional' : 'Nuevo Servicio Adicional',
      buttonTitle: isEdit ? 'Actualizar' : 'Crear',
      onAceptarPressed: _submit,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreCtrl,
              inputFormatters: [UpperCaseTextFormatter()],
              maxLength: 50,
              decoration: ThemeApp.inputDecoration(
                  'Nombre del servicio', '', Icons.dry_cleaning),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _precioCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyTextFormatter()],
              maxLength: 10,
              decoration: ThemeApp.inputDecoration(
                  'Precio', '0.00', Icons.attach_money),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descripcionCtrl,
              maxLength: 250,
              maxLines: 2,
              decoration: ThemeApp.inputDecoration(
                  'Descripción (opcional)', '', Icons.description),
            ),
            if (isEdit) ...[
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Estado: ',
                        style: TextStyle(
                            fontSize: 13,
                            color: ThemeApp.textSecondary,
                            fontFamily: ThemeApp.fontFamily)),
                    Switch(
                      value: _estadoActivo,
                      activeColor: ThemeApp.success,
                      onChanged: (v) => setState(() => _estadoActivo = v),
                    ),
                    Text(
                        _estadoActivo
                            ? EstadosGeneral.ACTIVO.getLabel
                            : EstadosGeneral.INACTIVO.getLabel,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: _estadoActivo
                                ? ThemeApp.success
                                : ThemeApp.error,
                            fontFamily: ThemeApp.fontFamily)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El nombre es obligatorio')));
      return;
    }
    final precio = double.tryParse(_precioCtrl.text.trim()) ?? 0;
    if (precio <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Precio inválido')));
      return;
    }

    final entity = TserServicioAdicionalEntity(
      idServicioAdicional: widget.servicio?.idServicioAdicional,
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim().isEmpty
          ? null
          : _descripcionCtrl.text.trim(),
      precioBase: precio,
      estado: _estadoActivo
          ? EstadosGeneral.ACTIVO.state
          : EstadosGeneral.INACTIVO.state,
      imagen: widget.servicio?.imagen,
    );

    Navigator.pop(context, entity);
  }
}
