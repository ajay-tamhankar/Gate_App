import 'package:freezed_annotation/freezed_annotation.dart';

part 'reco_exception.freezed.dart';
part 'reco_exception.g.dart';

@freezed
class RecoException with _$RecoException {
  const factory RecoException({
    required String id,
    required String gateEntryId,
    required String poNumber,
    required String status,
    required String description,
    required DateTime createdAt,
    String? resolvedAt,
    String? resolvedBy,
  }) = _RecoException;

  factory RecoException.fromJson(Map<String, dynamic> json) =>
      _$RecoExceptionFromJson(json);
}
