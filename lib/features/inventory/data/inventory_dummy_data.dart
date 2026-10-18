import '../model/inventory_item_model.dart';

/// Shared local sample inventory. Reports and Inventory use the same records.
final List<InventoryItem> inventoryDummyItems = [
  InventoryItem(
    id: 'INV001',
    vaccineName: 'Pfizer COVID-19',
    batchNumber: 'PF-2026-102',
    totalDoses: 1200,
    availableDoses: 980,
    expiryDate: DateTime(2026, 8, 18),
    storageLocation: 'Cold Room A',
  ),
  InventoryItem(
    id: 'INV002',
    vaccineName: 'BCG Vaccine',
    batchNumber: 'BCG-2026-021',
    totalDoses: 800,
    availableDoses: 120,
    expiryDate: DateTime(2026, 10, 30),
    storageLocation: 'Cold Room B',
  ),
  InventoryItem(
    id: 'INV003',
    vaccineName: 'MMR Vaccine',
    batchNumber: 'MMR-2026-031',
    totalDoses: 650,
    availableDoses: 0,
    expiryDate: DateTime(2026, 7, 14),
    storageLocation: 'Cold Room C',
  ),
  InventoryItem(
    id: 'INV004',
    vaccineName: 'Hepatitis B Vaccine',
    batchNumber: 'HB-2026-014',
    totalDoses: 500,
    availableDoses: 420,
    expiryDate: DateTime(2026, 9, 13),
    storageLocation: 'Cold Room A',
  ),
];
