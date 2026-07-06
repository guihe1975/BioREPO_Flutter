import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/biomasa_service.dart';
import 'resultados_exante_page.dart';

class ExantePage extends StatefulWidget {
  @override
  State<ExantePage> createState() => _ExantePageState();
}

class _ExantePageState extends State<ExantePage> {
  final TextEditingController edadController = TextEditingController();
  final TextEditingController densidadController = TextEditingController();
  final TextEditingController superficieController = TextEditingController();

  List<String> seleccionadas = [];
  Map<String, TextEditingController> porcentajes = {};

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    final especies = appState.selectedProvincia == null
        ? <String>[]
        : appState.obtenerEspecies(appState.selectedProvincia!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biomasa EXANTE'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [

                const Text(
                  'Datos del proyecto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // ✅ Edad
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

                // ✅ Superficie
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: superficieController,
                    decoration: const InputDecoration(
                      labelText: 'Superficie (ha)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),

                // ✅ Densidad
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

                const SizedBox(height: 30),

                // ✅ ESPECIES
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [

                        const Text(
                          'Especies (máx. 3)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          height: 250,
                          child: ListView(
                            children: especies.map((especie) {

                              final isSelected = seleccionadas.contains(especie);

                              porcentajes.putIfAbsent(
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
                                            ScaffoldMessenger.of(context).showSnackBar(
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
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        controller: porcentajes[especie],
                                        decoration: const InputDecoration(
                                          labelText: '%',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
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

                // ✅ BOTÓN
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {

                      // ✅ VALIDACIONES BÁSICAS
                      if (appState.selectedProvincia == null ||
                          appState.selectedMunicipio == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Selecciona provincia y municipio')),
                        );
                        return;
                      }

                      if (seleccionadas.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Selecciona al menos una especie')),
                        );
                        return;
                      }

                      // ✅ VALIDAR %
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

                      // ✅ EDAD
                      final int edad =
                          int.tryParse(edadController.text) ?? 0;
                      
                      // ✅ SUPERFICIE
                      final double superficie = 
                          double.tryParse(superficieController.text) ?? 0;

                      // ✅ DENSIDAD
                      final double N =
                          double.tryParse(densidadController.text) ?? 0;

                      // ✅ CLIMA REAL
                      final clima = appState.obtenerClima(
                        appState.selectedProvincia!,
                        appState.selectedMunicipio!,
                      );

                      if (clima == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('No se han encontrado datos climáticos')),
                        );
                        return;
                      }

                      double totalBiomasa = 0;
                      double totalCarbono = 0;

                      List<Map<String, dynamic>> listaResultados =[];

                      for (var especie in seleccionadas) {

                        final datos = appState.obtenerParametros(
                          appState.selectedProvincia!,
                          especie,
                        );

                        final porcentaje = double.tryParse(
                                porcentajes[especie]?.text ?? '0') ??
                            0;

                        final biomasa = BiomasaService.calcularBiomasa(
                          datos: datos!,
                          edad: edad,
                          porcentaje: porcentaje,
                          N: N,
                          precip: clima["pt"]!,
                          temp: clima["tm"]!,
                          martonne: clima["martonne"]!,
                        );
                        final factorC = datos["carbono"] ?? 0.5;
                        final carbono = biomasa * factorC;

                        listaResultados.add({
                          "nombre": especie,
                          "porcentaje": porcentaje,
                          "biomasa": biomasa,
                          "carbono": carbono,
                        });

                        totalBiomasa += biomasa;
                        totalCarbono += carbono;
                      }
                      
                      final biomasaTotalProyecto = totalBiomasa * superficie/1000; //SE TRANSFORMA A TONELADAS
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:(context)=> ResultadosExantePage(
                            resultados: listaResultados,
                            totalPorHa: totalBiomasa,
                            totalCarbono: totalCarbono,
                            totalProyecto: biomasaTotalProyecto,
                            edadUsuario: edad,
                            densidadUsuario: N,
                            superficieUsuario: superficie,
                            provincia: appState.selectedProvincia!,
                            municipio: appState.selectedMunicipio!,
                          ),
                        ),
                      );
                      },
                    child: const Text('Calcular BIOMASA'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
