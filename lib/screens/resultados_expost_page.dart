import 'package:flutter/material.dart';
import '/providers/app_state.dart';
import 'package:provider/provider.dart';
//import '../providers/app_state.dart';

class ResultadosExpostPage extends StatelessWidget {
  final List<Map<String, dynamic>> resultados;
  final double totalPorHa;
  final double totalProyecto;
  final int edadUsuario;
  final double densidadUsuario;
  final double superficieUsuario;
  //final String provincia;
  //final String municipio;
  //final double totalCarbono;
  

  const ResultadosExpostPage({
    super.key,
    required this.resultados,
    required this.totalPorHa,
    required this.totalProyecto,      
    required this.edadUsuario,
    required this.densidadUsuario,
    required this.superficieUsuario,
    //required this.provincia,
    //required this.municipio,
    //required this.totalCarbono,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resultados EXANTE"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const Text(
              "Resultados de Biomasa",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // ✅ DATOS DE UBICACIÓN DEL PROYECTO
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Ubicación",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Provincia: $provincia"),
                    Text("Municipio: $municipio"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Datos introducidos",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Edad: $edadUsuario"),
                    Text("Densidad: $densidadUsuario"),
                    Text("Superficie: $superficieUsuario"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ LISTA DE ESPECIES
            Expanded(
              child: ListView.builder(
                itemCount: resultados.length,
                itemBuilder: (context, index) {

                  final item = resultados[index];
                  final appState = Provider.of<MyAppState>(context,listen: false);
                  final rangos = appState.obtenerModeloReferencia(item["nombre"]);
                  bool avisoEdad = false;
                  bool avisoDensidad = false;
                  //bool avisoClima = false;

                  if (rangos != null) {

                    final edadMin = rangos["edad"]["min"];
                    final edadMax = rangos["edad"]["max"];

                    final densMin = rangos["densidad"]["min"];
                    final densMax = rangos["densidad"]["max"];

                    //final ptMin = rangos["precipitacion"]["min"];
                    //final ptMax = rangos["precipitacion"]["max"];

                    //final tmMin = rangos["temperatura"]["min"];
                    //final tmMax = rangos["temperatura"]["max"];

                    avisoEdad = edadUsuario < edadMin || edadUsuario > edadMax;
                    avisoDensidad = densidadUsuario < densMin || densidadUsuario > densMax;

                    // clima lo puedes añadir si quieres pasar pt/tm a la pantalla
                  }
                  return Card(
                    elevation: 2,
                    color: (avisoEdad || avisoDensidad)
                        ? Colors.amber[100]
                        : null,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(item["nombre"]),

                      // ✅ AQUÍ VA EL COLUMN
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text("Porcentaje: ${item["porcentaje"]}%"),
                          
                          if (rangos != null) ...[
                            Text(
                              "Edad: $edadUsuario (rango ${rangos["edad"]["min"]}-${rangos["edad"]["max"]})",
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "Densidad: $densidadUsuario (rango ${rangos["densidad"]["min"]}-${rangos["densidad"]["max"]})",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],

                          if (avisoEdad)
                            const Text(
                              "⚠️ Edad fuera de rango",
                              style: TextStyle(color: Colors.orange, fontSize: 12),
                            ),

                          if (avisoDensidad)
                            const Text(
                              "⚠️ Densidad fuera de rango",
                              style: TextStyle(color: Colors.orange, fontSize: 12),
                            ),
                        ],
                      ),
                      
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Biomasa: ${item["biomasa"].toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            "Carbono: ${item["carbono"].toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // ✅ RESULTADOS TOTALES
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Biomasa (kg/ha):"),
                        Text(totalPorHa.toStringAsFixed(2)),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Biomasa total (t):",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          totalProyecto.toStringAsFixed(2),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}