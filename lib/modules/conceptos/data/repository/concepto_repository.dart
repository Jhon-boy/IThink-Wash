import 'package:dartz/dartz.dart';
import 'package:ithinkwash/core/entities/concepto_entity.dart';
import 'package:ithinkwash/core/services/conection_service.dart';
import 'package:ithinkwash/core/utils/either.dart';
import 'package:ithinkwash/modules/conceptos/data/datasource/concepto_remote_datasource.dart';
import 'package:ithinkwash/modules/conceptos/domain/repository/concepto_repository.dart';

class ConceptoRemoteRepository implements ConceptoRepository {
  final ConceptoRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();

  ConceptoRemoteRepository(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, List<TserConceptoEntity>>> getConceptosEntity() async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final result = await remote.getConceptos();
      return Right(result);
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TserConceptoEntity>> getConceptoByIdEntity(int idConcepto) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final result = await remote.getConceptoById(idConcepto);
      if (result != null) {
        return Right(result);
      }
      return Left(NotFoundFailure('No se encontró el concepto con ID: $idConcepto'));
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TserConceptoEntity>> registerConceptoEntity(TserConceptoEntity data) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final result = await remote.createConcepto(data);
      return Right(result);
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TserConceptoEntity>> updateConceptoEntity(TserConceptoEntity data) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final result = await remote.updateConcepto(data);
      return Right(result);
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteConceptoEntity(int idConcepto, String user) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final result = await remote.deleteConcepto(idConcepto, user);
      return Right(result);
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}
