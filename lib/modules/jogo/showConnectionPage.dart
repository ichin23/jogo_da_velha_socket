import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jogo_da_velha/modules/connection/server.dart';
import 'package:jogo_da_velha/modules/jogo/controller/JogoController.dart';
import 'package:jogo_da_velha/modules/jogo/jogoPage.dart';

class Showconnectionpage extends StatefulWidget {
  const Showconnectionpage({super.key});

  @override
  State<Showconnectionpage> createState() => _ShowconnectionpageState();
}

class _ShowconnectionpageState extends State<Showconnectionpage> {
  late ServerJogo server;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    server = GetIt.I.get<ServerJogo>();

    server.currentConnection.addListener(() {
      if (server.currentConnection.value != null) {
        if (mounted) {
          GetIt.I.get<JogoController>().resetJogo();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const JogoPage()));
        }
      }
    });
  }

  @override
  void dispose() {
    server.currentConnection.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
          valueListenable: server.ip,
          builder: (context, value, child) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "IP",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    value.toString(),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 150,
                  ),
                  const Text(
                      "Use outro dispositivo para conectar a esse endereço")
                ],
              ),
            );
          }),
    );
  }
}
