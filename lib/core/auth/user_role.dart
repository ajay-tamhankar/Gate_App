enum UserRole {
  gateSecurity('Gate Security'),
  warehouseExecutive('Warehouse Executive'),
  warehouseManager('Warehouse Manager'),
  whMgr('WH Mgr'),
  admin('Admin');

  final String label;
  const UserRole(this.label);

  static UserRole? fromApi(String value) {
    switch (value) {
      case 'gate_security':
        return UserRole.gateSecurity;
      case 'warehouse_executive':
        return UserRole.warehouseExecutive;
      case 'warehouse_manager':
        return UserRole.warehouseManager;
      case 'wh_manager':
        return UserRole.whMgr;
      case 'admin':
        return UserRole.admin;
      default:
        return null;
    }
  }
}
