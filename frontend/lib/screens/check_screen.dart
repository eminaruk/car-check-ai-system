import 'package:flutter/material.dart';
import 'add_vehicle_screen.dart';
import '../services/storage_service.dart';

class CheckScreen extends StatefulWidget {
  const CheckScreen({super.key});

  @override
  State<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  List<Map<String, dynamic>> vehicles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final loadedVehicles = await StorageService.getVehicles();
    setState(() {
      vehicles = loadedVehicles;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Check'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vehicles.isEmpty
              ? _NoVehicleState(context)
              : _CheckContent(vehicles: vehicles),
    );
  }

  Widget _NoVehicleState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 64,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Araç Gerekli',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check yapabilmek için önce bir araç eklemeniz gerekiyor',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddVehicleScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Araç Ekle'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckContent extends StatefulWidget {
  final List<Map<String, dynamic>> vehicles;

  const _CheckContent({required this.vehicles});

  @override
  State<_CheckContent> createState() => _CheckContentState();
}

class _CheckContentState extends State<_CheckContent> {
  String? selectedVehicleId;
  Map<String, bool> photosTaken = {};
  bool photosCollected = false;

  List<Map<String, dynamic>> _getRequiredPhotos(String? fuelType) {
    if (fuelType == null) return [];

    final basePhotos = [
      {'id': 'tire_fl', 'title': 'Sol Ön Lastik', 'icon': Icons.tire_repair, 'required': true},
      {'id': 'tire_fr', 'title': 'Sağ Ön Lastik', 'icon': Icons.tire_repair, 'required': true},
      {'id': 'tire_rl', 'title': 'Sol Arka Lastik', 'icon': Icons.tire_repair, 'required': true},
      {'id': 'tire_rr', 'title': 'Sağ Arka Lastik', 'icon': Icons.tire_repair, 'required': true},
    ];

    if (fuelType == 'elektrik') {
      return [
        ...basePhotos,
        {'id': 'frunk', 'title': 'Frunk/Güç Elektroniği', 'icon': Icons.battery_charging_full, 'required': true},
        {'id': 'headlights', 'title': 'Ön Farlar', 'icon': Icons.lightbulb, 'required': true},
        {'id': 'taillights', 'title': 'Arka Stoplar', 'icon': Icons.lightbulb_outline, 'required': true},
        {'id': 'dashboard', 'title': 'Gösterge Paneli', 'icon': Icons.dashboard, 'required': true},
        {'id': 'charge_port_closed', 'title': 'Şarj Portu (Kapalı)', 'icon': Icons.power, 'required': true},
        {'id': 'charge_port_open', 'title': 'Şarj Portu (Açık)', 'icon': Icons.power, 'required': true},
      ];
    } else if (fuelType == 'plugin_hibrit') {
      return [
        ...basePhotos,
        {'id': 'engine', 'title': 'Motor Bölgesi', 'icon': Icons.car_repair, 'required': true},
        {'id': 'headlights', 'title': 'Ön Farlar', 'icon': Icons.lightbulb, 'required': true},
        {'id': 'taillights', 'title': 'Arka Stoplar', 'icon': Icons.lightbulb_outline, 'required': true},
        {'id': 'dashboard', 'title': 'Gösterge Paneli', 'icon': Icons.dashboard, 'required': true},
        {'id': 'exhaust', 'title': 'Egzoz', 'icon': Icons.cloud, 'required': true},
        {'id': 'oil_stick', 'title': 'Yağ Çubuğu', 'icon': Icons.opacity, 'required': false},
        {'id': 'charge_port_closed', 'title': 'Şarj Portu (Kapalı)', 'icon': Icons.power, 'required': true},
        {'id': 'charge_port_open', 'title': 'Şarj Portu (Açık)', 'icon': Icons.power, 'required': true},
      ];
    } else if (fuelType == 'hibrit') {
      return [
        ...basePhotos,
        {'id': 'engine', 'title': 'Motor Bölgesi', 'icon': Icons.car_repair, 'required': true},
        {'id': 'headlights', 'title': 'Ön Farlar', 'icon': Icons.lightbulb, 'required': true},
        {'id': 'taillights', 'title': 'Arka Stoplar', 'icon': Icons.lightbulb_outline, 'required': true},
        {'id': 'dashboard', 'title': 'Gösterge Paneli', 'icon': Icons.dashboard, 'required': true},
        {'id': 'exhaust', 'title': 'Egzoz', 'icon': Icons.cloud, 'required': true},
        {'id': 'oil_stick', 'title': 'Yağ Çubuğu', 'icon': Icons.opacity, 'required': false},
        {'id': 'hybrid_cooler', 'title': 'Hibrit Batarya Soğutucu', 'icon': Icons.ac_unit, 'required': false},
      ];
    } else {
      // ICE (benzin/dizel/lpg)
      return [
        ...basePhotos,
        {'id': 'engine', 'title': 'Motor Bölgesi', 'icon': Icons.car_repair, 'required': true},
        {'id': 'headlights', 'title': 'Ön Farlar', 'icon': Icons.lightbulb, 'required': true},
        {'id': 'taillights', 'title': 'Arka Stoplar', 'icon': Icons.lightbulb_outline, 'required': true},
        {'id': 'dashboard', 'title': 'Gösterge Paneli', 'icon': Icons.dashboard, 'required': true},
        {'id': 'exhaust', 'title': 'Egzoz', 'icon': Icons.cloud, 'required': true},
        {'id': 'oil_stick', 'title': 'Yağ Çubuğu', 'icon': Icons.opacity, 'required': false},
      ];
    }
  }

  void _collectPhotos() {
    setState(() {
      photosCollected = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lütfen sıra ile fotoğrafları çekin'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _startCheck() {
    final selectedVehicle = widget.vehicles.firstWhere(
      (v) => v['id'] == selectedVehicleId,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Check başlatılıyor: ${selectedVehicle['name']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _getCurrentPhotoSlot(List<Map<String, dynamic>> requiredPhotos) {
    final currentIndex = photosTaken.values.where((v) => v).length;
    final currentPhoto = requiredPhotos[currentIndex];
    final isRequired = currentPhoto['required'] as bool;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    currentPhoto['title'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isRequired ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isRequired ? 'Zorunlu' : 'Opsiyonel',
                    style: TextStyle(
                      fontSize: 12,
                      color: isRequired ? Colors.red : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    currentPhoto['icon'],
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Fotoğraf Yükle',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    photosTaken[currentPhoto['id']] = true;
                  });
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text(
                  'Fotoğraf Çek / Yükle',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            if (!isRequired) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      photosTaken[currentPhoto['id']] = true;
                    });
                  },
                  child: const Text('Atla'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = selectedVehicleId != null
        ? widget.vehicles.firstWhere((v) => v['id'] == selectedVehicleId)
        : null;
    final requiredPhotos = _getRequiredPhotos(selectedVehicle?['fuelType']);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Araç Seçimi
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Araç Seçin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                    hint: const Text('Araç seçin'),
                    value: selectedVehicleId,
                    items: widget.vehicles.map((vehicle) {
                      return DropdownMenuItem<String>(
                        value: vehicle['id'],
                        child: Text('${vehicle['name']} - ${vehicle['brand']} ${vehicle['model']}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedVehicleId = value;
                        photosTaken.clear();
                        photosCollected = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          if (selectedVehicleId != null) ...[
            const SizedBox(height: 16),

            if (!photosCollected)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _collectPhotos,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text(
                    'Görselleri Al',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              )
            else ...[
              // İlerleme göstergesi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fotoğraf ${photosTaken.values.where((v) => v).length + 1}/${requiredPhotos.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${((photosTaken.values.where((v) => v).length / requiredPhotos.length) * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: photosTaken.values.where((v) => v).length / requiredPhotos.length,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 24),

              // Tek fotoğraf slotu
              if (photosTaken.values.where((v) => v).length < requiredPhotos.length) ...[
                _getCurrentPhotoSlot(requiredPhotos),
                const SizedBox(height: 24),
              ] else ...[
                // Tüm fotoğraflar tamamlandı
                Card(
                  color: Colors.green.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tüm Fotoğraflar Yüklendi!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${requiredPhotos.length} fotoğraf başarıyla yüklendi',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _startCheck,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'Check\'e Başla',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}


