import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jogo_da_velha/modules/jogo/controller/JogoController.dart';
import 'package:network_info_plus/network_info_plus.dart';

class ServerJogo {
  final ValueNotifier<String?> ip = ValueNotifier(null);
  late ServerSocket _serverSocket;
  final ValueNotifier<Socket?> _currentConnection = ValueNotifier(null);

  ValueNotifier<Socket?> get currentConnection => _currentConnection;

  Future<void> start() async {
    final info = NetworkInfo();
    ip.value = await info.getWifiIP();
    _serverSocket = await ServerSocket.bind(ip.value, 3000, shared: true);
    _serverSocket.listen(
      handleConnection,
    );
  }

  Future<void> stop() async {
    if (_currentConnection.value != null) {
      print("Fechando conexão com o cliente...");
      await _currentConnection.value
          ?.close(); // Fecha explicitamente o socket do cliente
      _currentConnection.value = null;
    }
    await _serverSocket.close();
    GetIt.I.get<JogoController>().encerraJogo();
    print('Servidor parado.');
  }

  void handleConnection(Socket client) {
    if (_currentConnection.value != null) {
      print(
          'Nova tentativa de conexão recusada. Apenas um dispositivo pode se conectar por vez.');
      client.write('Servidor ocupado. Apenas uma conexão permitida por vez.');
      client.close();
      return;
    }

    print("${client.remoteAddress.address}:${client.remotePort}");

    _currentConnection.value = client;

    client.listen((Uint8List data) {
      final response = String.fromCharCodes(data).trim();
      print('Resposta do servidor: $response');
      print(identical(response, "restart"));
      if (identical(response, "restart")) {
        GetIt.I.get<JogoController>().resetJogo();
        return;
      }
      int jogada = int.parse(response);
      GetIt.I.get<JogoController>().addJogada(jogada, JogadorType.cliente);
    }, onDone: () {
      _currentConnection.value = null;
      print("Cliente encerrou a conexão");
    });
  }

  void sendData(String data) {
    _currentConnection.value?.write(data);
  }
}
