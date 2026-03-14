import 'package:freezed_annotation/freezed_annotation.dart';

part 'resolve_exception_request.freezed.dart';
part 'resolve_exception_request.g.dart';

@freezed
class ResolveExceptionRequest with _$ResolveExceptionRequest {
  const factory ResolveExceptionRequest({
    required String resolutionNotes,
    required String status,
  }) = _ResolveExceptionRequest;

  factory ResolveExceptionRequest.fromJson(Map<String, dynamic> json) =>
      _$ResolveExceptionRequestFromJson(json);
}
