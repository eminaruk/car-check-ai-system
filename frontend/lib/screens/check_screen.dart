import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/storage_service.dart';

class CheckScreen extends StatefulWidget {
  final String? selectedCheckId;
  final VoidCallback? onCheckClosed;

  const CheckScreen({super.key, this.selectedCheckId, this.onCheckClosed});

  @override
  State<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  List<Map<String, dynamic>> checks = [];
  List<Map<String, dynamic>> vehicles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(CheckScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Eğer selectedCheckId değişti ve yeni bir ID geldiyse check detaylarını aç
    if (widget.selectedCheckId != null &&
        widget.selectedCheckId != oldWidget.selectedCheckId &&
        !isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openSelectedCheck();
      });
    }
  }

  Future<void> _loadData() async {
    final loadedVehicles = await StorageService.getVehicles();
    final loadedChecks = await StorageService.getChecks();
    setState(() {
      vehicles = loadedVehicles;
      checks = loadedChecks;
      isLoading = false;
    });

    // Eğer selectedCheckId varsa ve data yüklendiyse check detaylarını aç
    if (widget.selectedCheckId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openSelectedCheck();
      });
    }
  }

  void _openSelectedCheck() {
    if (widget.selectedCheckId == null) return;

    final check = checks.firstWhere(
      (c) => c['id'] == widget.selectedCheckId,
      orElse: () => {},
    );

    if (check.isNotEmpty) {
      _showCheckDetails(check);
    }
  }

  void _navigateToNewCheck() {
    if (vehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.needVehicleFirst),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewCheckScreen(vehicles: vehicles),
      ),
    ).then((result) {
      if (result == true) {
        _loadData();
      }
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getVehicleName(String? vehicleId, BuildContext context) {
    if (vehicleId == null) return AppLocalizations.of(context)!.unknownVehicle;
    final vehicle = vehicles.firstWhere(
      (v) => v['id'] == vehicleId,
      orElse: () => {'name': AppLocalizations.of(context)!.unknownVehicle},
    );
    return vehicle['name'] ?? AppLocalizations.of(context)!.unknownVehicle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myChecks),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : checks.isEmpty
              ? _buildEmptyState()
              : _buildCheckList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToNewCheck,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.newCheck),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noCheckYet,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.startFirstCheck,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToNewCheck,
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.doFirstCheck),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckList() {
    final sortedChecks = List<Map<String, dynamic>>.from(checks);
    sortedChecks.sort((a, b) {
      final aDate = a['createdAt'] ?? '';
      final bDate = b['createdAt'] ?? '';
      return bDate.compareTo(aDate);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedChecks.length,
      itemBuilder: (context, index) {
        final check = sortedChecks[index];
        return _buildCheckCard(check);
      },
    );
  }

  Widget _buildCheckCard(Map<String, dynamic> check) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _showCheckDetails(check),
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.assignment,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
        ),
        title: Text(
          _getVehicleName(check['vehicleId'], context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(check['createdAt']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  void _showCheckDetails(Map<String, dynamic> check) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.assignment,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getVehicleName(check['vehicleId'], context),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(check['createdAt']),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow(AppLocalizations.of(context)!.status, check['status'] ?? AppLocalizations.of(context)!.completed),
            _buildDetailRow(AppLocalizations.of(context)!.photoCount, '${check['photoCount'] ?? 0}'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close),
                label: Text(AppLocalizations.of(context)!.close),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ).then((_) {
      // Modal bottom sheet kapandığında callback'i çağır
      widget.onCheckClosed?.call();
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// Yeni Check Ekranı
class NewCheckScreen extends StatefulWidget {
  final List<Map<String, dynamic>> vehicles;

  const NewCheckScreen({super.key, required this.vehicles});

  @override
  State<NewCheckScreen> createState() => _NewCheckScreenState();
}

class _NewCheckScreenState extends State<NewCheckScreen> {
  String? selectedVehicleId;
  Map<String, bool> photosTaken = {};
  bool photosCollected = false;

  List<Map<String, dynamic>> _getRequiredPhotos(String? fuelType, BuildContext context) {
    if (fuelType == null) return [];
    final l10n = AppLocalizations.of(context)!;

    final basePhotos = [
      {'id': 'tire_fl', 'title': l10n.photoTireFl, 'icon': Icons.tire_repair, 'required': true},
      {'id': 'tire_fr', 'title': l10n.photoTireFr, 'icon': Icons.tire_repair, 'required': true},
      {'id': 'tire_rl', 'title': l10n.photoTireRl, 'icon': Icons.tire_repair, 'required': true},
      {'id': 'tire_rr', 'title': l10n.photoTireRr, 'icon': Icons.tire_repair, 'required': true},
    ];

    if (fuelType == 'elektrik') {
      return [
        ...basePhotos,
        {'id': 'frunk', 'title': l10n.photoFrunk, 'icon': Icons.battery_charging_full, 'required': true},
        {'id': 'headlights', 'title': l10n.photoHeadlights, 'icon': Icons.lightbulb, 'required': true},
        {'id': 'taillights', 'title': l10n.photoTaillights, 'icon': Icons.lightbulb_outline, 'required': true},
        {'id': 'dashboard', 'title': l10n.photoDashboard, 'icon': Icons.dashboard, 'required': true},
        {'id': 'charge_port_closed', 'title': l10n.photoChargePortClosed, 'icon': Icons.power, 'required': true},
        {'id': 'charge_port_open', 'title': l10n.photoChargePortOpen, 'icon': Icons.power, 'required': true},
      ];
    } else if (fuelType == 'plugin_hibrit') {
      return [
        ...basePhotos,
        {'id': 'engine', 'title': l10n.photoEngine, 'icon': Icons.car_repair, 'required': true},
        {'id': 'headlights', 'title': l10n.photoHeadlights, 'icon': Icons.lightbulb, 'required': true},
        {'id': 'taillights', 'title': l10n.photoTaillights, 'icon': Icons.lightbulb_outline, 'required': true},
        {'id': 'dashboard', 'title': l10n.photoDashboard, 'icon': Icons.dashboard, 'required': true},
        {'id': 'exhaust', 'title': l10n.photoExhaust, 'icon': Icons.cloud, 'required': true},
        {'id': 'oil_stick', 'title': l10n.photoOilStick, 'icon': Icons.opacity, 'required': false},
        {'id': 'charge_port_closed', 'title': l10n.photoChargePortClosed, 'icon': Icons.power, 'required': true},
        {'id': 'charge_port_open', 'title': l10n.photoChargePortOpen, 'icon': Icons.power, 'required': true},
      ];
    } else if (fuelType == 'hibrit') {
      return [
        ...basePhotos,
        {'id': 'engine', 'title': l10n.photoEngine, 'icon': Icons.car_repair, 'required': true},
        {'id': 'headlights', 'title': l10n.photoHeadlights, 'icon': Icons.lightbulb, 'required': true},
        {'id': 'taillights', 'title': l10n.photoTaillights, 'icon': Icons.lightbulb_outline, 'required': true},
        {'id': 'dashboard', 'title': l10n.photoDashboard, 'icon': Icons.dashboard, 'required': true},
        {'id': 'exhaust', 'title': l10n.photoExhaust, 'icon': Icons.cloud, 'required': true},
        {'id': 'oil_stick', 'title': l10n.photoOilStick, 'icon': Icons.opacity, 'required': false},
        {'id': 'hybrid_cooler', 'title': l10n.photoHybridCooler, 'icon': Icons.ac_unit, 'required': false},
      ];
    } else {
      return [
        ...basePhotos,
        {'id': 'engine', 'title': l10n.photoEngine, 'icon': Icons.car_repair, 'required': true},
        {'id': 'headlights', 'title': l10n.photoHeadlights, 'icon': Icons.lightbulb, 'required': true},
        {'id': 'taillights', 'title': l10n.photoTaillights, 'icon': Icons.lightbulb_outline, 'required': true},
        {'id': 'dashboard', 'title': l10n.photoDashboard, 'icon': Icons.dashboard, 'required': true},
        {'id': 'exhaust', 'title': l10n.photoExhaust, 'icon': Icons.cloud, 'required': true},
        {'id': 'oil_stick', 'title': l10n.photoOilStick, 'icon': Icons.opacity, 'required': false},
      ];
    }
  }

  void _collectPhotos() {
    setState(() {
      photosCollected = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.takePhotosInOrder),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _startCheck() async {
    final selectedVehicle = widget.vehicles.firstWhere(
      (v) => v['id'] == selectedVehicleId,
    );

    final check = {
      'vehicleId': selectedVehicleId,
      'createdAt': DateTime.now().toIso8601String(),
      'status': AppLocalizations.of(context)!.completed,
      'photoCount': photosTaken.length,
    };

    await StorageService.saveCheck(check);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.checkCompleted(selectedVehicle['name'] ?? '')),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
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
                    isRequired ? AppLocalizations.of(context)!.required : AppLocalizations.of(context)!.optional,
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
                    AppLocalizations.of(context)!.uploadPhoto,
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
                label: Text(
                  AppLocalizations.of(context)!.takeOrUploadPhoto,
                  style: const TextStyle(fontSize: 16),
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
                  child: Text(AppLocalizations.of(context)!.skip),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _sortedVehicles {
    final sorted = List<Map<String, dynamic>>.from(widget.vehicles);
    sorted.sort((a, b) => (a['name'] ?? '').toString().toLowerCase().compareTo((b['name'] ?? '').toString().toLowerCase()));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = selectedVehicleId != null
        ? widget.vehicles.firstWhere((v) => v['id'] == selectedVehicleId)
        : null;
    final requiredPhotos = _getRequiredPhotos(selectedVehicle?['fuelType'], context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.newCheck),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.selectVehicleTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._sortedVehicles.map((vehicle) {
              final isSelected = selectedVehicleId == vehicle['id'];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    setState(() {
                      selectedVehicleId = vehicle['id'];
                      photosTaken.clear();
                      photosCollected = false;
                    });
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    vehicle['name'] ?? AppLocalizations.of(context)!.vehicle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                  subtitle: Text('${vehicle['brand']} ${vehicle['model']}'),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
              );
            }),

            if (selectedVehicleId != null) ...[
              const SizedBox(height: 16),

              if (!photosCollected)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _collectPhotos,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      AppLocalizations.of(context)!.getPhotos,
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.photoOfTotal(
                        photosTaken.values.where((v) => v).length + 1,
                        requiredPhotos.length,
                      ),
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

                if (photosTaken.values.where((v) => v).length < requiredPhotos.length) ...[
                  _getCurrentPhotoSlot(requiredPhotos),
                  const SizedBox(height: 24),
                ] else ...[
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
                          Text(
                            AppLocalizations.of(context)!.allPhotosUploaded,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.photosUploadedSuccess(requiredPhotos.length),
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
                      label: Text(
                        AppLocalizations.of(context)!.completeCheck,
                        style: const TextStyle(fontSize: 16),
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
      ),
    );
  }
}
