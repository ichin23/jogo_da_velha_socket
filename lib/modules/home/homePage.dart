import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jogo_da_velha/modules/jogo/controller/JogoController.dart';
import 'package:jogo_da_velha/modules/jogo/jogoPage.dart';
import 'package:jogo_da_velha/modules/jogo/showConnectionPage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
                onPressed: () async {
                  await GetIt.I
                      .get<JogoController>()
                      .startJogo(JogadorType.servidor);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Showconnectionpage()));
                },
                child: const Text("Criar Servidor")),
            const SizedBox(height: 25),
            FilledButton(
                onPressed: () async {
                  String? erro;
                  bool loading = false;
                  TextEditingController ip = TextEditingController();
                  showDialog(
                      context: context,
                      builder: (context) =>
                          StatefulBuilder(builder: (context, state) {
                            return AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Visibility(
                                      visible: erro != null,
                                      child: Text(
                                        erro ?? "",
                                        style:
                                            const TextStyle(color: Colors.red),
                                      )),
                                  TextFormField(
                                    controller: ip,
                                    validator: (text) {
                                      if (text?.isEmpty ?? true) {
                                        return "Digite algo";
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                        label: Text("IP"),
                                        hintText: "192.168.1.1"),
                                  ),
                                  const SizedBox(height: 5),
                                  loading
                                      ? const CircularProgressIndicator()
                                      : TextButton(
                                          onPressed: () async {
                                            try {
                                              loading = true;
                                              state(() {});
                                              await GetIt.I
                                                  .get<JogoController>()
                                                  .startJogo(
                                                      JogadorType.cliente,
                                                      address: ip.text,
                                                      port: 3000);
                                              GetIt.I
                                                  .get<JogoController>()
                                                  .resetJogo();
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const JogoPage()));
                                            } on SocketException catch (e) {
                                              erro = "IP não encontrado";
                                              print("Erro home: $e");
                                              loading = false;
                                              state(() {});
                                            }
                                          },
                                          child: const Text("Conectar"))
                                ],
                              ),
                            );
                          }));
                },
                child: const Text("Conectar ao Servidor"))
          ],
        ),
      ),
    );
  }
}
