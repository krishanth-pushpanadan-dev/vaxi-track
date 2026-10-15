import 'package:flutter/material.dart';

import '../data/alert_dummy_data.dart';
import '../models/alert_model.dart';

class AlertDetailsPage extends StatefulWidget {
  final AlertModel alert;

  const AlertDetailsPage({super.key, required this.alert});

  @override
  State<AlertDetailsPage> createState() => _AlertDetailsPageState();
}

class _AlertDetailsPageState extends State<AlertDetailsPage> {
  late AlertModel _currentAlert;

  @override
  void initState() {
    super.initState();
    _currentAlert = widget.alert;
  }

  void _updateSharedAlert({bool? acknowledged, AlertStatus? status}) {
    final index = alertList.indexWhere((item) => item.id == _currentAlert.id);

    if (index == -1) {
      _showMessage('This alert was not found in the shared alert list.');
      return;
    }

    final updatedAlert = AlertModel(
      id: _currentAlert.id,
      title: _currentAlert.title,
      description: _currentAlert.description,
      deviceName: _currentAlert.deviceName,
      location: _currentAlert.location,
      time: _currentAlert.time,
      temperature: _currentAlert.temperature,
      severity: _currentAlert.severity,
      status: status ?? _currentAlert.status,
      acknowledged: acknowledged ?? _currentAlert.acknowledged,
    );

    alertList[index] = updatedAlert;

    setState(() {
      _currentAlert = updatedAlert;
    });
  }

  void _acknowledgeAlert() {
    if (_currentAlert.acknowledged) return;

    _updateSharedAlert(acknowledged: true);

    if (_currentAlert.acknowledged) {
      _showMessage('Alert acknowledged successfully.');
    }
  }

  void _resolveAlert() {
    if (_currentAlert.status == AlertStatus.resolved) return;

    _updateSharedAlert(status: AlertStatus.resolved, acknowledged: true);

    if (_currentAlert.status == AlertStatus.resolved) {
      _showMessage('Alert resolved successfully.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final alert = _currentAlert;
    final isResolved = alert.status == AlertStatus.resolved;

    return Scaffold(
      appBar: AppBar(title: const Text('Alert Details'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: alert.severityColor.withOpacity(.15),
              child: Icon(
                alert.severityIcon,
                size: 45,
                color: alert.severityColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              alert.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Chip(
              backgroundColor: alert.severityColor.withOpacity(.15),
              label: Text(
                alert.severityText,
                style: TextStyle(
                  color: alert.severityColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _infoTile(Icons.memory, 'Device', alert.deviceName),
            _infoTile(Icons.location_on, 'Location', alert.location),
            _infoTile(
              Icons.thermostat,
              'Temperature',
              '${alert.temperature} °C',
            ),
            _infoTile(Icons.schedule, 'Time', alert.time),
            _infoTile(Icons.description, 'Description', alert.description),
            _infoTile(
              isResolved
                  ? Icons.check_circle
                  : alert.acknowledged
                  ? Icons.notifications_active
                  : Icons.error_outline,
              'Status',
              isResolved
                  ? 'Resolved'
                  : alert.acknowledged
                  ? 'Acknowledged'
                  : 'Pending',
            ),
            const SizedBox(height: 30),
            if (!alert.acknowledged && !isResolved)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Acknowledge Alert'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _acknowledgeAlert,
                ),
              ),
            if (!isResolved) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Resolve Alert'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _resolveAlert,
                ),
              ),
            ],
            if (isResolved)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'This alert has been resolved.',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
