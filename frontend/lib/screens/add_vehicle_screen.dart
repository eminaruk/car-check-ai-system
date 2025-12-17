import 'package:flutter/material.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  
  String? _selectedTransmission;
  String? _selectedModification;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form geçerli, verileri işle
      final vehicleData = {
        'name': _nameController.text,
        'brand': _brandController.text,
        'model': _modelController.text,
        'year': int.tryParse(_yearController.text),
        'transmission': _selectedTransmission,
        'modification': _selectedModification,
      };

      // Şimdilik sadece göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Araç eklendi: ${_nameController.text}'),
          backgroundColor: Colors.green,
        ),
      );

      // Geri dön
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Araç Ekle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // İsim
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Araç İsmi',
                  hintText: 'Örn: Benim Arabam',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.drive_eta),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen araç ismi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Marka
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Marka',
                  hintText: 'Örn: Toyota, Ford, BMW',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.branding_watermark),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen marka girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Model
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  hintText: 'Örn: Corolla, Focus, 3 Series',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.model_training),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen model girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Üretim Yılı
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Üretim Yılı',
                  hintText: 'Örn: 2020',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen üretim yılı girin';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                    return 'Geçerli bir yıl girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Vites Seçeneği
              DropdownButtonFormField<String>(
                value: _selectedTransmission,
                decoration: const InputDecoration(
                  labelText: 'Vites Tipi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.settings),
                ),
                items: const [
                  DropdownMenuItem(value: 'manuel', child: Text('Manuel')),
                  DropdownMenuItem(value: 'otomatik', child: Text('Otomatik')),
                  DropdownMenuItem(value: 'yarı_otomatik', child: Text('Yarı Otomatik')),
                  DropdownMenuItem(value: 'cvt', child: Text('CVT')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTransmission = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen vites tipi seçin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Modifiye Durumu
              DropdownButtonFormField<String>(
                value: _selectedModification,
                decoration: const InputDecoration(
                  labelText: 'Modifiye Durumu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.build),
                ),
                items: const [
                  DropdownMenuItem(value: 'orijinal', child: Text('Orijinal')),
                  DropdownMenuItem(value: 'hafif_modifiye', child: Text('Hafif Modifiye')),
                  DropdownMenuItem(value: 'orta_modifiye', child: Text('Orta Modifiye')),
                  DropdownMenuItem(value: 'agir_modifiye', child: Text('Ağır Modifiye')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedModification = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen modifiye durumu seçin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Kaydet Butonu
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: const Text('Araç Ekle', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

