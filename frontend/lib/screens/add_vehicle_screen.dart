import 'package:flutter/material.dart';
import '../services/storage_service.dart';

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
  final _kmController = TextEditingController();

  String? _selectedTransmission;
  String? _selectedModification;
  String? _selectedFuelType;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final vehicleData = {
        'name': _nameController.text,
        'brand': _brandController.text,
        'model': _modelController.text,
        'year': int.tryParse(_yearController.text),
        'fuelType': _selectedFuelType,
        'km': int.tryParse(_kmController.text),
        'transmission': _selectedTransmission,
        'modification': _selectedModification,
      };

      await StorageService.saveVehicle(vehicleData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Araç eklendi: ${_nameController.text}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
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

              // Yakıt Tipi
              DropdownButtonFormField<String>(
                value: _selectedFuelType,
                decoration: const InputDecoration(
                  labelText: 'Yakıt Tipi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_gas_station),
                ),
                items: const [
                  DropdownMenuItem(value: 'benzin', child: Text('Benzin')),
                  DropdownMenuItem(value: 'dizel', child: Text('Dizel')),
                  DropdownMenuItem(value: 'lpg', child: Text('LPG')),
                  DropdownMenuItem(value: 'hibrit', child: Text('Hibrit')),
                  DropdownMenuItem(value: 'plugin_hibrit', child: Text('Plugin Hibrit')),
                  DropdownMenuItem(value: 'elektrik', child: Text('Elektrik')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFuelType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen yakıt tipi seçin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kilometre
              TextFormField(
                controller: _kmController,
                decoration: const InputDecoration(
                  labelText: 'Kilometre',
                  hintText: 'Örn: 45000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kilometre girin';
                  }
                  final km = int.tryParse(value);
                  if (km == null || km < 0) {
                    return 'Geçerli bir kilometre girin';
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

