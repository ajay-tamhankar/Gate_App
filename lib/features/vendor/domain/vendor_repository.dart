import 'models/vendor.dart';

abstract class VendorRepository {
  Future<VendorListResult> listVendors(VendorListQuery query);
  Future<Vendor> getVendor(String id);
  Future<Vendor> createVendor(VendorWriteRequest request);
  Future<Vendor> updateVendor(String id, VendorWriteRequest request);
  Future<void> deleteVendor(String id, {bool hard = false});
}
