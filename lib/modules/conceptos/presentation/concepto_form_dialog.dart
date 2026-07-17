import 'package:flutter/material.dart';
import 'package:ithinkwash/core/entities/concepto_entity.dart';
import 'package:ithinkwash/core/theme_app.dart';
import 'package:ithinkwash/core/utils/formatters.dart';
import 'package:ithinkwash/shared/enums/estados_general.dart';
import 'package:ithinkwash/shared/enums/tipo_medida.dart';
import 'package:ithinkwash/shared/widgets/custom_dropdown.dart';
import 'package:ithinkwash/shared/widgets/dialog_generic_widget.dart';
import 'package:ithinkwash/shared/widgets/dialog_widget.dart';

class ConceptoFormDialog extends StatefulWidget {
  final TserConceptoEntity? concepto;

  const ConceptoFormDialog({super.key, this.concepto});

  static Future<TserConceptoEntity?> show(
      BuildContext context, TserConceptoEntity? concepto) {
    return showDialog<TserConceptoEntity>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConceptoFormDialog(concepto: concepto),
    );
  }

  @override
  State<ConceptoFormDialog> createState() => _ConceptoFormDialogState();
}

class _ConceptoFormDialogState extends State<ConceptoFormDialog> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _unidadPersonalizadaCtrl;
  String _tipoMedida = TipoMedida.LIBRA.state;
  bool _estadoActivo = true;

  @override
  void initState() {
    super.initState();
    final c = widget.concepto;
    _nombreCtrl = TextEditingController(text: c?.nombre ?? '');
    _precioCtrl = TextEditingController(text: c?.precioBase.toString() ?? '');
    _descripcionCtrl = TextEditingController(text: c?.descripcion ?? '');
    _unidadPersonalizadaCtrl =
        TextEditingController(text: c?.unidadMedida ?? '');
    _estadoActivo = c?.estado.toUpperCase() == EstadosGeneral.ACTIVO.state;

    final raw = c?.tipoCobro ?? TipoMedida.LIBRA.state;
    if (TipoMedida.getListValues().contains(raw.toUpperCase())) {
      _tipoMedida = raw.toUpperCase();
    } else {
      _tipoMedida = TipoMedida.LIBRA.state;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _descripcionCtrl.dispose();
    _unidadPersonalizadaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.concepto != null;
    return DialogoPersonalizadoWidget(
      titulo: isEdit ? 'Editar Concepto' : 'Nuevo Concepto',
      buttonTitle: isEdit ? 'Actualizar' : 'Crear',
      onAceptarPressed: _submit,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreCtrl,
              maxLength: 50,
              inputFormatters: [UpperCaseTextFormatter()],
              decoration: ThemeApp.inputDecoration(
                  'Nombre del servicio', '', Icons.local_laundry_service),
            ),
            const SizedBox(height: 14),
            const Text('Unidad de Medida', style: TextStyle(fontSize: 12)),
            CustomDropdown<String>(
              value: _tipoMedida,
              label: 'Unidad de Medida',
              hint: 'Seleccione',
              items: TipoMedida.getListValues(),
              displayText: (v) => TipoMedida.getTipoMedidaLabel(v),
              onChanged: (v) => setState(() => _tipoMedida = v!),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _precioCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyTextFormatter()],
              decoration: ThemeApp.inputDecoration(
                  'Precio', '0.00', Icons.attach_money),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descripcionCtrl,
              maxLength: 250,
              maxLines: 3,
              decoration: ThemeApp.inputDecoration(
                  'Descripción', 'Describa el servicio', Icons.description),
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
      DialogHelper.info(context,
          message: 'El nombre es obligatorio', onConfirmed: () {});
      return;
    }
    if (_descripcionCtrl.text.trim().isEmpty) {
      DialogHelper.info(context,
          message: 'La descripción es obligatoria', onConfirmed: () {});
      return;
    }
    final precio = double.tryParse(_precioCtrl.text.trim()) ?? 0;
    if (precio <= 0) {
      DialogHelper.info(context,
          message: 'Precio inválido', onConfirmed: () {});
      return;
    }

    if (_tipoMedida == TipoMedida.PERSONALIZADO.state &&
        _unidadPersonalizadaCtrl.text.trim().isEmpty) {
      DialogHelper.info(context,
          message: 'Indique la unidad de medida', onConfirmed: () {});
      return;
    }

    final entity = TserConceptoEntity(
      idConcepto: widget.concepto?.idConcepto,
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      tipoCobro: _tipoMedida,
      unidadMedida: _tipoMedida == TipoMedida.PERSONALIZADO.state
          ? _unidadPersonalizadaCtrl.text.trim()
          : _tipoMedida,
      precioBase: precio,
      estado: _estadoActivo
          ? EstadosGeneral.ACTIVO.state
          : EstadosGeneral.INACTIVO.state,
      imagen: widget.concepto?.imagen,
    );

    Navigator.pop(context, entity);
  }
}
