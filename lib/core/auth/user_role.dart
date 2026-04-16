enum UserRole {
  gateSecurity('Gate Security'),
  warehouseExecutive('Warehouse Executive'),
  warehouseManager('Warehouse Manager'),
  whMgr('WH Mgr'),
  admin('Admin');

  final String label;
  const UserRole(this.label);

  static UserRole? fromApi(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    switch (normalized) {
      case 'gate_security':
      case 'gate':
      case 'security':
        return UserRole.gateSecurity;
      case 'warehouse_executive':
      case 'warehouse_exec':
      case 'executive':
        return UserRole.warehouseExecutive;
      case 'warehouse_manager':
      case 'warehousemanager':
      case 'manager':
        return UserRole.warehouseManager;
      case 'wh_manager':
      case 'wh_mgr':
      case 'whmanager':
        return UserRole.whMgr;
      case 'admin':
      case 'administrator':
        return UserRole.admin;
      default:
        return null;
    }
  }
}

extension UserRoleX on UserRole {
  bool get isWarehouseManagerLike =>
      this == UserRole.warehouseManager || this == UserRole.whMgr;

  bool get isAdminOrWarehouseManager =>
      this == UserRole.admin || isWarehouseManagerLike;
}

extension NullableUserRoleX on UserRole? {
  bool get isAdminOrWarehouseManager =>
      this != null && this!.isAdminOrWarehouseManager;
}
