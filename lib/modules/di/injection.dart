import 'package:get_it/get_it.dart';
import 'package:jogo_da_velha/modules/connection/client.dart';
import 'package:jogo_da_velha/modules/connection/server.dart';
import 'package:jogo_da_velha/modules/jogo/controller/JogoController.dart';

void injectDependencies() {
  GetIt.I.registerSingleton(JogoController());
  GetIt.I.registerSingleton(ServerJogo());
  GetIt.I.registerSingleton(ClientJogo());
}
