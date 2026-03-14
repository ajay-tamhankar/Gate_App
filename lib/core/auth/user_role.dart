enum UserRole {
  gateSecurity('Gate Security'),
  warehouseExecutive('Warehouse Executive'),
  warehouseManager('Warehouse Manager'),
  whMgr('WH Mgr'),
  admin('Admin');

  final String label;
  const UserRole(this.label);
}
