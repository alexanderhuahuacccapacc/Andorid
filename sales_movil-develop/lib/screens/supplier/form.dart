import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/providers/supplier_provider.dart';
import 'package:sales/models/supplier.dart';

class SupplierFormScreen extends StatefulWidget {
  final Supplier? supplier; // null = crear, distinto = editar
  const SupplierFormScreen({super.key, this.supplier});

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name     = TextEditingController();
  late final _docNum   = TextEditingController();
  late final _email    = TextEditingController();
  late final _phone    = TextEditingController();
  late final _address  = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    if (s != null) {
      _name   .text = s.name;
      _docNum .text = s.documentNumber;
      _email  .text = s.email;
      _phone  .text = s.phone;
      _address.text = s.address;
    }
  }

  @override
  void dispose() {
    _name.dispose(); _docNum.dispose(); _email.dispose();
    _phone.dispose(); _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final prov = context.read<SupplierProvider>();
    final s = widget.supplier;
    final updated = Supplier(
      s?.id ?? 0,
      _name.text.trim(),
      _docNum.text.trim(),
      _email.text.trim(),
      _phone.text.trim(),
      _address.text.trim(),
      false,
      s?.serverId,
    );
    try {
      if (s == null) {
        await prov.save(updated);
      } else {
        await prov.edit(s.id, updated);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType kb = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: kb,
        decoration: InputDecoration(labelText: label,
            border: const OutlineInputBorder()),
        validator: (v) => (v == null || v.trim().isEmpty)
            ? 'Campo requerido' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar proveedor' : 'Nuevo proveedor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            _field('Nombre', _name),
            _field('N° documento', _docNum,
                kb: TextInputType.number),
            _field('Email', _email,
                kb: TextInputType.emailAddress),
            _field('Teléfono', _phone,
                kb: TextInputType.phone),
            _field('Dirección', _address),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(isEdit ? 'Guardar cambios' : 'Crear proveedor'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ]),
        ),
      ),
    );
  }
}