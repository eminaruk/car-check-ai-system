import 'package:flutter/material.dart';
import 'add_vehicle_screen.dart';

class CheckScreen extends StatelessWidget {
  const CheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Şimdilik araç yok varsayalım (ileride state management ile kontrol edilecek)
    final bool hasVehicles = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Check'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: hasVehicles
          ? _CheckContent()
          : _NoVehicleState(context),
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

class _CheckContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                    items: const [],
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Check Alanları
          const Text(
            'Check Alanları',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _CheckAreaCard(
            icon: Icons.tire_repair,
            title: 'Lastikler',
            description: 'Lastik durumu ve diş derinliği analizi',
            isRequired: true,
          ),
          _CheckAreaCard(
            icon: Icons.dashboard,
            title: 'Konsol',
            description: 'Gösterge paneli ve kontrol ışıkları',
            isRequired: true,
          ),
          _CheckAreaCard(
            icon: Icons.event_seat,
            title: 'Koltuklar',
            description: 'Koltuk durumu ve yıpranma analizi',
            isRequired: true,
          ),
          _CheckAreaCard(
            icon: Icons.car_repair,
            title: 'Motor Bölümü',
            description: 'Motor ve aksamların durumu',
            isRequired: false,
          ),
          _CheckAreaCard(
            icon: Icons.directions_car,
            title: 'Dış Görünüm',
            description: 'Boya, göçük ve çizik analizi',
            isRequired: false,
          ),

          const SizedBox(height: 24),

          // Başlat Butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Check başlatılıyor...')),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                'Check Başlat',
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
      ),
    );
  }
}

class _CheckAreaCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isRequired;

  const _CheckAreaCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isRequired,
  });

  @override
  State<_CheckAreaCard> createState() => _CheckAreaCardState();
}

class _CheckAreaCardState extends State<_CheckAreaCard> {
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isRequired;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: _isSelected,
        onChanged: widget.isRequired
            ? null
            : (value) {
                setState(() {
                  _isSelected = value ?? false;
                });
              },
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Row(
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (widget.isRequired) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Zorunlu',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          widget.description,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

