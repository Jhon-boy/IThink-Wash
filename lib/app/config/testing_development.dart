
import 'package:ithinkwash/app/config/env_config.dart';
import 'package:ithinkwash/app/config/enviroment.dart';
import 'package:ithinkwash/shared/enums/enviroment.dart';

/// Configuración para ambiente de Testing/QA
class TestingEnvironment extends Environment {
  TestingEnvironment()
      : super(
          type: EnvironmentType.testing,
          apiBaseUrl: EnvConfig.API_URL,
          enableLogs: true,
          enableDebugMode: false,
           timeOut: EnvConfig.API_TIMEOUT
        );
}
