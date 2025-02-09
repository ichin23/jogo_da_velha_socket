import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jogo_da_velha/modules/connection/client.dart';
import 'package:jogo_da_velha/modules/connection/server.dart';
import 'package:jogo_da_velha/modules/home/homePage.dart';
import 'package:jogo_da_velha/modules/jogo/controller/JogoController.dart';

class JogoPage extends StatefulWidget {
  const JogoPage({super.key});

  @override
  State<JogoPage> createState() => _JogoPageState();
}

class _JogoPageState extends State<JogoPage> {
  late double size;

  double calculateSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    if (width > height) {
      return height * 0.8;
    } else {
      return width * 0.8;
    }
  }

  @override
  void initState() {
    super.initState();

    print("Criando listener");

    if (GetIt.I.get<JogoController>().jogadorType == JogadorType.servidor) {
      print("Identificado como servidor");
      GetIt.I.get<ServerJogo>().currentConnection.addListener(() {
        print(
            "Listener Server: ${GetIt.I.get<ServerJogo>().currentConnection.value}");
        if (GetIt.I.get<ServerJogo>().currentConnection.value == null) {
          GetIt.I.get<JogoController>().encerraJogo();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (pg) => pg.isFirst);
        }
      });
    } else {
      GetIt.I.get<ClientJogo>().socket.addListener(() {
        print("Listener Client: ${GetIt.I.get<ClientJogo>().socket.value}");
        if (GetIt.I.get<ClientJogo>().socket.value == null) {
          GetIt.I.get<JogoController>().encerraJogo();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (pg) => pg.isFirst);
          }
        }
      });
    }

    /*GetIt.I.get<JogoController>().jogoStatus.addListener(() {
      print(GetIt.I.get<JogoController>().jogoStatus.value);
      if (GetIt.I.get<JogoController>().jogoStatus.value == JogoStatus.parado) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (pg) => pg.isFirst);
      }
    });*/
  }

  @override
  void dispose() {
    if (GetIt.I.get<JogoController>().jogadorType == JogadorType.servidor) {
      GetIt.I.get<ServerJogo>().currentConnection.removeListener(() {
        print("Listener Server removed");
      });
    } else {
      GetIt.I.get<ClientJogo>().socket.removeListener(() {
        print("Listener Server removed");
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = calculateSize(context);
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(),
              Column(
                children: [
                  ValueListenableBuilder<JogadorType>(
                      valueListenable: GetIt.I.get<JogoController>().vez,
                      builder: (context, vez, c) {
                        return Text(
                          vez == GetIt.I.get<JogoController>().jogadorType
                              ? "Sua vez"
                              : "Vez do outro",
                          style: const TextStyle(fontSize: 22),
                        );
                      }),
                  SizedBox(
                      width: size,
                      height: size,
                      child: ValueListenableBuilder<JogadorType?>(
                          valueListenable: GetIt.I.get<JogoController>().winner,
                          builder: (context, winner, c) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 700),
                                  opacity: winner != null ? 0.3 : 1,
                                  child: ValueListenableBuilder<List<int?>>(
                                      valueListenable: GetIt.I
                                          .get<JogoController>()
                                          .matrizJogo,
                                      builder: (context, matriz, c) {
                                        print(matriz);
                                        return GridView.builder(
                                            itemCount: matriz.length,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3),
                                            itemBuilder: (context, i) =>
                                                GestureDetector(
                                                  onTap: () {
                                                    if (GetIt.I
                                                            .get<
                                                                JogoController>()
                                                            .vez
                                                            .value ==
                                                        GetIt.I
                                                            .get<
                                                                JogoController>()
                                                            .jogadorType) {
                                                      GetIt.I
                                                          .get<JogoController>()
                                                          .addJogada(
                                                              i,
                                                              GetIt.I
                                                                  .get<
                                                                      JogoController>()
                                                                  .vez
                                                                  .value);
                                                    }
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black),
                                                    ),
                                                    child: matriz[i] == null
                                                        ? Container()
                                                        : Icon(
                                                            matriz[i] == 0
                                                                ? Icons
                                                                    .circle_outlined
                                                                : Icons.close,
                                                            size: size / 4,
                                                          ),
                                                  ),
                                                ));
                                      }),
                                ),
                                Visibility(
                                  visible: winner != null,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: winner ==
                                                      GetIt.I
                                                          .get<JogoController>()
                                                          .jogadorType
                                                  ? Colors.green
                                                  : Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Text(
                                              winner == JogadorType.cliente
                                                  ? "O venceu"
                                                  : winner ==
                                                          JogadorType.servidor
                                                      ? "X venceu"
                                                      : "Deu velha!",
                                              style: const TextStyle(
                                                  fontSize: 28)),
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              GetIt.I
                                                  .get<JogoController>()
                                                  .restart();
                                            },
                                            icon: const Icon(Icons.refresh))
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            );
                          })),
                ],
              ),
              OutlinedButton(
                  style: OutlinedButton.styleFrom(),
                  onPressed: () async {
                    await GetIt.I.get<JogoController>().closeJogo();
                    print("Fechar Jogo");
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                        (pg) => pg.isFirst);
                  },
                  child: const Text("Sair")),
            ],
          ),
        ),
      ),
    );
  }
}
