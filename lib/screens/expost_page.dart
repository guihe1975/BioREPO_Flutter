import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ExpostPage extends StatefulWidget {
  @override
  State<ExpostPage> createState() => _ExpostPageState();
}

class _ExpostPageState extends State<ExpostPage> {

  final TextEditingController edadController = TextEditingController();
  final TextEditingController densidadController = TextEditingController();
  final TextEditingController superficieController = TextEditingController();

  List<String> seleccionadas = [];
  Map<String, TextEditingController> porcentajes = {};
  Map<String, TextEditingController> alturas = {};

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    // ✅ OJO: de momento usamos las mismas especies
    final especies = appState.selectedProvincia == null
        ? <String>[]
        : appState.obtenerEspecies(appState.selectedProvincia!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biomasa EXPOST'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Text(
                  'Datos del proyecto (EXPOST)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // ✅ EDAD (necesaria para IS)
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: edadController,
                    decoration: const InputDecoration(
                      labelText: 'Edad (años)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                const SizedBox(height: 15),

                // ✅ DENSIDAD
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: densidadController,
                    decoration: const InputDecoration(
                      labelText: 'Densidad (pie/ha)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                const SizedBox(height: 15),

                // ✅ SUPERFICIE
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: superficieController,
                    decoration: const InputDecoration(
                      labelText: 'Superficie (ha)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                const SizedBox(height: 30),

                // ✅ BLOQUE ESPECIES
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          'Especies (máx. 3)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          height: 260,
                          child: ListView(
                            children: especies.map((especie) {

                              final isSelected =
                                  seleccionadas.contains(especie);

                              porcentajes.putIfAbsent(
                                especie,
                                () => TextEditingController(),
                              );

                              alturas.putIfAbsent(
                                especie,
                                () => TextEditingController(),
                              );

                              return Row(
                                children: [

                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          if (seleccionadas.length >= 3) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text('Máximo 3 especies'),
                                              ),
                                            );
                                            return;
                                          }
                                          seleccionadas.add(especie);
                                        } else {
                                          seleccionadas.remove(especie);
                                        }
                                      });
                                    },
                                  ),

                                  Expanded(child: Text(especie)),

                                  if (isSelected)
                                    Row(
                                      children: [

                                        // ✅ % presencia
                                        SizedBox(
                                          width: 70,
                                          child: TextField(
                                            controller: porcentajes[especie],
                                            decoration:
                                                const InputDecoration(
                                              labelText: '%',
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType:
                                                TextInputType.number,
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        // ✅ altura media
                                        SizedBox(
                                          width: 80,
                                          child: TextField(
                                            controller: alturas[especie],
                                            decoration:
                                                const InputDecoration(
                                              labelText: 'h (m)',
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType:
                                                TextInputType.number,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ✅ BOTÓN (por ahora solo validación)
                ElevatedButton(
                  onPressed: () {

                    if (seleccionadas.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecciona al menos una especie'),
                        ),
                      );
                      return;
                    }

                    // ✅ validar porcentajes
                    double suma = 0;

                    for (var especie in seleccionadas) {
                      final valor = double.tryParse(
                              porcentajes[especie]?.text ?? '0') ??
                          0;
                      suma += valor;
                    }

                    if ((suma - 100).abs() > 0.01) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Los porcentajes deben sumar 100% (actual: $suma)'),
                        ),
                      );
                      return;
                    }

                    // ✅ validar alturas
                    for (var especie in seleccionadas) {
                      final h = double.tryParse(
                              alturas[especie]?.text ?? '0') ??
                          0;

                      if (h <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Altura inválida en $especie'),
                          ),
                        );
                        return;
                      }
                    }

                    print("✅ Datos EXPOST correctos");
                  },
                  child: const Text("Validar datos EXPOST"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
