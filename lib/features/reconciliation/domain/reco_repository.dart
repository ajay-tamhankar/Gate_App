import 'entities/reco_exception.dart';

abstract class RecoRepository {
  Future<List<RecoException>> getExceptions();
  Future<RecoException> getExceptionDetail(String id);
  Future<void> resolveException(String id, String resolutionNotes);
}
