import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jogo_da_velha/modules/connection/client.dart';
import 'package:jogo_da_velha/modules/connection/server.dart';

enum JogadorType { cliente, servidor, velha }

enum JogoStatus { rodando, parado }

class JogoController {
  ValueNotifier<JogadorType> vez = ValueNotifier(JogadorType.cliente);
  JogadorType? jogadorType;
  ValueNotifier<JogoStatus> jogoStatus = ValueNotifier(JogoStatus.parado);
  ValueNotifier<JogadorType?> winner = ValueNotifier(null);

  ValueNotifier<List<int?>> matrizJogo =
      ValueNotifier(List.generate(9, (i) => null));

  resetJogo() {
    vez.value = winner.value ?? JogadorType.cliente;
    winner.value = null;
    matrizJogo.value = List.generate(9, (i) => null);
  }

  restart() {
    resetJogo();
    if (jogadorType == JogadorType.servidor) {
      GetIt.I.get<ServerJogo>().sendData("restart");
    } else {
      GetIt.I.get<ClientJogo>().sendData("restart");
    }
  }

  addJogada(int x, JogadorType jogador) {
    if (matrizJogo.value[x] != null) {
      return "Jogada Inválida";
    }

    matrizJogo.value = List.from(matrizJogo.value)..[x] = jogador.index;
    if (_checkWinner()) {
      
      if (winner.value!=JogadorType.velha) {
        winner.value = jogador;
      }
    }
    vez.value = vez.value == JogadorType.cliente
        ? JogadorType.servidor
        : JogadorType.cliente;
    if (jogadorType == JogadorType.servidor) {
      GetIt.I.get<ServerJogo>().sendData("$x");
    } else {
      GetIt.I.get<ClientJogo>().sendData("$x");
    }
  }

  startJogo(
    JogadorType jogadorType, {
    dynamic address,
    int? port,
  }) async {
    this.jogadorType = jogadorType;
    if (jogadorType == JogadorType.servidor) {
      print("Iniciando Servidor");
      await GetIt.I.get<ServerJogo>().start();
    } else {
      print("Iniciando Cliente");
      if (address != null && port != null) {
        await GetIt.I.get<ClientJogo>().start(address, port);
      }
    }
  }

  bool _checkWinner() {
    // Combinações vencedoras
    const winningPatterns = [
      [0, 1, 2], // Linha 1
      [3, 4, 5], // Linha 2
      [6, 7, 8], // Linha 3
      [0, 3, 6], // Coluna 1
      [1, 4, 7], // Coluna 2
      [2, 5, 8], // Coluna 3
      [0, 4, 8], // Diagonal 1
      [2, 4, 6], // Diagonal 2
    ];

    for (var pattern in winningPatterns) {
      if (matrizJogo.value[pattern[0]] != null &&
          matrizJogo.value[pattern[0]] == matrizJogo.value[pattern[1]] &&
          matrizJogo.value[pattern[1]] == matrizJogo.value[pattern[2]]) {
        return true;
      }
    }
    if (!matrizJogo.value.contains(null)) {
    winner.value = JogadorType.velha; // Indica empate
    return true;
  }
    return false;
  }

  closeJogo() async {
    if (jogadorType == JogadorType.servidor) {
      await GetIt.I.get<ServerJogo>().stop();
    } else {
      await GetIt.I.get<ClientJogo>().stop();
    }
  }

  encerraJogo() {
    jogoStatus.value = JogoStatus.parado;
    print(jogoStatus);
  }
}
