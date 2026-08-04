import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class MyAppState extends ChangeNotifier {

  // ================================
  // ✅ VARIABLES DE SELECCIÓN
  // ================================
  String? tipoCalculo;
  String? selectedProvincia;
  String? selectedMunicipio;
  String? tipoDensidad;

  // ================================
  // ✅ DATOS PRINCIPALES
  // ================================
  Map<String, dynamic> parametrosData = {};
  Map<String, dynamic> municipiosData = {};
  Map<String, dynamic> expostData = {};


  // ================================
  // ✅ DATOS EXANTE (IMPORTANTE 🔥)
  // ================================
  int? edad;
  List<Map<String, dynamic>> especiesSeleccionadas = [];

  // ================================
  // ✅ DATOS MUNICIPIOS
  // ================================
  List<String> provincias = [];
  List<Map<String, dynamic>> todosMunicipios = [];
  List<String> municipiosFiltrados = [];

  // ================================
  // ✅ CONSTRUCTOR
  // ================================
  MyAppState() {
    loadData();
    loadParametros();
    loadModelos();
    loadExpost();
  }


  // ===================================
  // ✅ FUNCIÓN ESPECIFICA PARA EXPOST
  // ===================================
  List<String> obtenerEspeciesExpost() {
    if (expostData.isEmpty) return [];

    final lista = expostData["especies"] as List;

    return lista
        .map((e) => e["nombre"] as String)
        .toList()
      ..sort();
  }

  // ================================
  // ✅ CARGAR MUNICIPIOS
  // ================================
  Future<void> loadData() async {
    print("🔄 Cargando municipios...");
    final String response =
        await rootBundle.loadString('lib/data/terminomunicipal.json');

    print("✅ JSON cargado");

    final Map<String, dynamic> data = json.decode(response);

    municipiosData = data;

    // ✅ extraer provincias directamente del JSON
    final List<dynamic> listaProvincias = data["provincias"];

    provincias = listaProvincias
        .map((p) => p["nombre"] as String)
        .toList()
      ..sort();

    print("✅ Provincias cargadas: ${provincias.length}");

    notifyListeners();
  }
  Future<void> loadExpost() async {
    final response =
        await rootBundle.loadString('lib/data/expost_parametros.json');

    expostData = json.decode(response);

    notifyListeners();
  }

  // ================================
  // ✅ CARGAR PARÁMETROS EXANTE
  // ================================
  Future<void> loadParametros() async {
    final String response =
        await rootBundle.loadString('lib/data/exante_parametros.json');

    parametrosData = json.decode(response);

    notifyListeners();
  }

  // ==========================================
  // ✅ CARGAR RANGOS DE PARÁMETROS DEL MODELO
  // ==========================================
  Future<void> loadModelos() async {
    final response =
        await rootBundle.loadString('lib/data/rangos.json');

    modelosData = json.decode(response);

    notifyListeners();
  }

  // ================================
  // ✅ SETTERS
  // ================================
  void setTipoCalculo(String value) {
    tipoCalculo = value;
    notifyListeners();
  }

  void setProvincia(String provincia) {
    selectedProvincia = provincia;
    selectedMunicipio = null;

    if (municipiosData.isEmpty) return;

    final provinciaData = municipiosData["provincias"]
        .firstWhere(
          (p) => p["nombre"] == provincia,
          orElse: () => null,
        );

    if (provinciaData == null) return;

    final lista = (provinciaData["municipios"] as List)
        .map((m) => m["nombre"] as String)
        .toList();

    // ✅ Separar _Media provincial
    String? media;
    final resto = <String>[];

    for (var m in lista) {
      if (m == "_Media provincial") {
        media = m;
      } else {
        resto.add(m);
      }
    }

    // ✅ Ordenar resto
    resto.sort();

    // ✅ Construir lista final
    municipiosFiltrados = [];

    if (media != null) {
      municipiosFiltrados.add(media); // primero siempre
    }

    municipiosFiltrados.addAll(resto);

    print("✅ Municipios cargados: ${municipiosFiltrados.length}");

    notifyListeners();
  }

  void setMunicipio(String municipio) {
    selectedMunicipio = municipio;
    notifyListeners();
  }

  void setTipoDensidad(String value) {
    tipoDensidad = value;
    notifyListeners();
  }

  // ================================
  // ✅ OBTENER ESPECIES (para UI)
  // ================================
  List<String> obtenerEspecies(String provincia) {
    if (parametrosData.isEmpty) return [];

    final provinciaData = parametrosData["provincias"]
        .where((p) => p["nombre"] == provincia)
        .toList();

    if (provinciaData.isEmpty) return [];

    return (provinciaData[0]["especies"] as List)
        .map<String>((e) => e["nombre"] as String)
        .toList();
  }

  // ================================
  // ✅ OBTENER PARÁMETROS (para cálculos)
  // ================================
  Map<String, dynamic>? obtenerParametros(
      String provincia, String especie) {

    if (parametrosData.isEmpty) return null;

    final provinciaData = parametrosData["provincias"]
        .where((p) => p["nombre"] == provincia)
        .toList();

    if (provinciaData.isEmpty) return null;

    final especieData = provinciaData[0]["especies"]
        .where((e) => e["nombre"] == especie)
        .toList();

    if (especieData.isEmpty) return null;

    return especieData[0];
  }
  //VERIFICAR QUE EL PORCENTAJE DE LAS ESPECIES 
  // SELECCIONADAS SUMA 100%
  
  // ================================
  // ✅ GUARDAR DATOS EXANTE 🔥
  // ================================
  void guardarDatosExante({
    required int edadInput,
    required List<Map<String, dynamic>> especies,
  }) {
    edad = edadInput;
    especiesSeleccionadas = especies;

    print("✅ Datos guardados:");
    print("Edad: $edad");
    print("Especies: $especiesSeleccionadas");

    notifyListeners();
  }
  Map<String, double>? obtenerClima(
    String provincia,
    String municipio,
  ) {

    if (municipiosData.isEmpty) return null;

    final provinciaData = municipiosData["provincias"]
        .firstWhere(
          (p) => p["nombre"] == provincia,
          orElse: () => null,
        );

    if (provinciaData == null) return null;

    final municipioData = provinciaData["municipios"]
        .firstWhere(
          (m) => m["nombre"] == municipio,
          orElse: () => null,
        );

    if (municipioData == null) return null;

    return {
      "pt": (municipioData["pt"] ?? 0).toDouble(),
      "tm": (municipioData["tm"] ?? 0).toDouble(),
      "martonne": (municipioData["martonne"] ?? 0).toDouble(),
    };
  }
  Map<String, dynamic> modelosData = {};
  Map<String, dynamic>? obtenerModeloReferencia(String especie) {
    if (modelosData.isEmpty) return null;

    final lista = modelosData["especies"] as List;

    try {
      return lista.firstWhere(
        (e) => e["nombre"] == especie,
      );
    } catch (e) {
      return null;
    }
  }
    Map<String, dynamic>? obtenerDatosExpost(String especie) {
    if (expostData.isEmpty) return null;

    final lista = expostData["especies"] as List;

    try {
      return lista.firstWhere(
        (e) => e["nombre"] == especie,
      );
    } catch (e) {
      return null;
    }
  }
}
