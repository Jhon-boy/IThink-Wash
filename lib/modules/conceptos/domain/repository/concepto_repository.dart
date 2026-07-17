import 'package:dartz/dartz.dart';
import 'package:ithinkwash/core/entities/concepto_entity.dart';
import 'package:ithinkwash/core/utils/either.dart';

abstract class ConceptoRepository {
  Future<Either<Failure, List<TserConceptoEntity>>> getConceptosEntity();
  Future<Either<Failure, TserConceptoEntity>> getConceptoByIdEntity(int idConcepto);
  Future<Either<Failure, TserConceptoEntity>> registerConceptoEntity(TserConceptoEntity data);
  Future<Either<Failure, TserConceptoEntity>> updateConceptoEntity(TserConceptoEntity data);
  Future<Either<Failure, bool>> deleteConceptoEntity(int idConcepto, String user);
  Future<Either<Failure, TserConceptoEntity>> toggleEstadoConceptoEntity(int idConcepto, bool activo, String user);
}
