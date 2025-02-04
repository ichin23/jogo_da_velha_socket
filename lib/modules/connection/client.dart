import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jogo_da_velha/modules/jogo/controller/JogoController.dart';

class ClientJogo {
  final ValueNotifier<Socket?> _socket = ValueNotifier(null);
  dynamic address;
  int? port;

  ValueNotifier<Socket?> get socket => _socket;

  Future<void> start(dynamic address, int port) async {
    this.address = address;
    this.port = port;
    _socket.value = await Socket.connect(address, port,
        timeout: const Duration(seconds: 2));

    _socket.value?.listen(
      _handleResponse,
      onDone: _handleDisconnection,
      onError: (error) => print('Erro no socket: $error'),
    );
  }

  Future<void> stop() async {
    print("Fechando");
    await _socket.value?.close();
    _socket.value = null;
    GetIt.I.get<JogoController>().encerraJogo();
  }

  void sendData(String message) {
    if (_socket.value != null) {
      print('Enviando mensagem: $message');
      _socket.value!.write('$message\n');
    } else {
      print('Erro: Não conectado ao servidor.');
    }
  }

  void _handleResponse(Uint8List data) {
    final response = String.fromCharCodes(data).trim();
    print('Resposta do servidor: $response');
    if (response == "restart") {
      GetIt.I.get<JogoController>().resetJogo();
      return;
    }
    int jogada = int.parse(response);
    GetIt.I.get<JogoController>().addJogada(jogada, JogadorType.servidor);
  }

  void _handleDisconnection() {
    print('Conexão com o servidor encerrada.');
    _socket.value = null;
    GetIt.I.get<JogoController>().encerraJogo();
  }
}
