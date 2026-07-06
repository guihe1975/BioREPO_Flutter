//import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';

import 'screens/exante_page.dart';
import 'screens/expost_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BioREPO',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biomasa - CO2'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                'Estimar la Biomasa y el Carbono de una plantación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // ✅ OPTION BUTTONS (Radio)
              Card(
                elevation: 2,
                child: Column(
                  children: [

                    RadioListTile<String>(
                      title: const Text('Expost - Plantación existente'),
                      value: 'expost',
                      groupValue: appState.tipoCalculo,
                      onChanged: (value) {
                        appState.setTipoCalculo(value!);
                      },
                    ),

                    RadioListTile<String>(
                      title: const Text('Exante - Nuevo proyecto'),
                      value: 'exante',
                      groupValue: appState.tipoCalculo,
                      onChanged: (value) {
                        appState.setTipoCalculo(value!);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ✅ Dropdown PROVINCIAS
              SizedBox(
                width: 320,
                child: DropdownButtonFormField<String>(
                  initialValue: appState.selectedProvincia,
                  hint: const Text('Provincia'),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: appState.provincias.map((provincia) {
                    return DropdownMenuItem(
                      value: provincia,
                      child: Text(provincia),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      appState.setProvincia(value);
                    }
                  },
                ),
              ),

              const SizedBox(height: 15),

              // ✅ Dropdown MUNICIPIOS
              SizedBox(
                width: 360,
                child: DropdownButtonFormField<String>(
                  initialValue: appState.selectedMunicipio,
                  hint: const Text('Término municipal'),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: appState.municipiosFiltrados.map((municipio) {
                    return DropdownMenuItem(
                      value: municipio,
                      child: Text(municipio, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      appState.setMunicipio(value);
                    }
                  },
                ),
              ),

              const SizedBox(height: 30),

              // ✅ Botón siguiente
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    if (appState.tipoCalculo == 'exante') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExantePage()),
                      );
                    } else if (appState.tipoCalculo == 'expost') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExpostPage()),
                      );
                    }
                  },
                  child: const Text('Siguiente'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}