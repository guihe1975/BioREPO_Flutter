import 'dart:math';

class BiomasaService {

  // =====================================================
  // =====================================================
  //                ✅ MODELOS EXANTE
  // =====================================================
  // =====================================================


    static double _obtenerValorClimatico(
    String? tipo,
    double precip,
    double temp,
    double martonne,
  ) {
    switch (tipo) {
      case "P":
        return precip;
      case "T":
        return temp;
      case "M":
        return martonne;
      default:
        return 0;
    }
  }

  // ================================
  // ✅ FUNCIÓN PRINCIPAL
  // ================================
  static double calcularBiomasa({
    required Map<String, dynamic> datos,
    required int edad,
    required double porcentaje,
    required double N,
    required double precip,
    required double temp,
    required double martonne,

  }) {

    final modelo = datos["modelo"];
    final p = datos["parametros"];
    
    // ✅ obtener tipos climáticos desde JSON
    final tipoXcl1 = datos["xcl1"];
    final tipoXcl2 = datos["xcl2"];

    // ✅ traducir a valores reales
    final xcl1 = _obtenerValorClimatico(tipoXcl1, precip, temp, martonne);
    final xcl2 = _obtenerValorClimatico(tipoXcl2, precip, temp, martonne);

    double resultado = 0;

    if (modelo == "A") {
      resultado = _calcularAlometrico(p, N, edad, xcl1, xcl2);
    } else if (modelo == "R") {
      resultado = _calcularRichards(p, N, edad, xcl1);
    }

    return resultado * (porcentaje / 100);
  }

  // ================================
  // 🔥 LÓGICA DE PRIORIDAD
  // ================================
  static double _calcularAlometrico(
    Map<String, dynamic> p,
    double N,
    int edad,
    double xcl1,
    double xcl2,
  ) {

    // 1️⃣ MODELO CLIMA
    final clima = _modeloAlometricoClima(p, N, edad, xcl1, xcl2);

    if (clima.isFinite && clima > 0) {
      return clima;
    }

    // 2️⃣ MODELO DENSIDAD
    final densidad = _modeloAlometricoDensidad(p, N, edad);

    if (densidad.isFinite && densidad > 0) {
      return densidad;
    }

    // 3️⃣ MODELO BASE (SIEMPRE)
    return _modeloAlometricoBase(p, edad);
  }

  static double _calcularRichards(
    Map<String, dynamic> p,
    double N,
    int edad,
    double xcl1,
  ) {

    // 1️⃣ MODELO CLIMA
    final clima = _modeloRichardsClima(p, N, edad, xcl1);

    if (clima.isFinite && clima > 0) {
      return clima;
    }

    // 2️⃣ MODELO DENSIDAD
    final densidad = _modeloRichardsDensidad(p, N, edad);

    if (densidad.isFinite && densidad > 0) {
      return densidad;
    }

    // 3️⃣ MODELO BASE
    return _modeloRichardsBase(p, edad);
  }

  // ================================
  // ✅ MODELOS BASE (YA CORRECTOS)
  // ================================

  static double _modeloAlometricoBase(
    Map<String, dynamic> p,
    int edad,
  ) {
    final double a = (p["a"] ?? 0).toDouble();
    final double b = (p["b"] ?? 0).toDouble();

    return a * pow(edad, b);
  }

  static double _modeloRichardsBase(
    Map<String, dynamic> p,
    int edad,
  ) {
    final double a = (p["a"] ?? 0).toDouble();
    final double b = (p["b"] ?? 0).toDouble();
    final double c = (p["c"] ?? 0).toDouble();

    return a * pow((1 - exp(b * edad)), c);
  }

  // ================================
  // ✅ (TEMPORALES - luego afinamos)
  // ================================
  static double _modeloAlometricoClima(
    Map<String, dynamic> p,
    double N,
    int edad,
    double xcl1,
    double xcl2,
  ) {
    final a0 = (p["a0"] ?? 0).toDouble();
    final a1 = (p["a1"] ?? 0).toDouble();
    final a2 = (p["a2"] ?? 0).toDouble();

    final b0 = (p["b0"] ?? 0).toDouble();
    final b1 = (p["b1"] ?? 0).toDouble();
    final b2 = (p["b2"] ?? 0).toDouble();
    final b3 = (p["b3"] ?? 0).toDouble();

    final base = a0 + a1 * N + a2 * xcl1;
    final exponente = b0 + b1 * xcl1 + b2 * N + b3 * xcl2;

    return base * pow(edad, exponente);
  }

  static double _modeloAlometricoDensidad(
    Map<String, dynamic> p,
    double N,
    int edad,
  ) {
    final a00 = (p["a00"] ?? 0).toDouble();
    final a01 = (p["a01"] ?? 0).toDouble();

    final b00 = (p["b00"] ?? 0).toDouble();
    final b01 = (p["b01"] ?? 0).toDouble();

    final base = a00 + a01 * N;
    final exponente = b00 + b01 * N;

    return base * pow(edad, exponente);
  }


  static double _modeloRichardsClima(
    Map<String, dynamic> p,
    double N,
    int edad,
    double xcl,
  ) {
    final a1 = (p["a1"] ?? 0).toDouble();
    final a2 = (p["a2"] ?? 0).toDouble();

    final b0 = (p["b0"] ?? 0).toDouble();
    final b1 = (p["b1"] ?? 0).toDouble();

    final base = (a1 * N + a2 * xcl);
    final interior = 1 - exp(b0 * edad);

    return base * pow(interior, b1);
  }

  static double _modeloRichardsDensidad(
    Map<String, dynamic> p,
    double N,
    int edad,
  ) {
    final a00 = (p["a00"] ?? 0).toDouble();
    final a01 = (p["a01"] ?? 0).toDouble();

    final b00 = (p["b00"] ?? 0).toDouble();
    final b01 = (p["b01"] ?? 0).toDouble();

    final base = a00 + a01 * N;
    final interior = 1 - exp(b00 * edad);

    return base * pow(interior, b01);
  }

  // =====================================================
  // =====================================================
  //                 ✅ MODELOS EXPOST
  // =====================================================
  // =====================================================

  static double _modeloIS_M1(
    double H1,
    double t1,
    double t2,
    Map<String, dynamic> p,
  ) {
    final a1 = (p["p1"] ?? 0).toDouble();
    final a2 = (p["p2"] ?? 0).toDouble();

    final num = log(1 - exp(a1 * t2));
    final den = log(1 - exp(a1 * t1));

    if (den == 0) return 0;

    final exponente = num / den;

    return a2 * pow((H1 / a2), exponente);
  }
  
  // ================================
  // ✅ CALCULO ÍNDICE DE SITIO (EXPOST)
  // ================================
  static double calcularIndiceSitio({
    required String modelo,
    required double H1,
    required double t1,
    required double t2,
    required Map<String, dynamic> parametros,
  }) {

    switch (modelo) {

      case "M1":
        return _modeloIS_M1(H1, t1, t2, parametros);

      case "M2":
        return _modeloIS_M1(H1, t1, t2, parametros);

      case "M3":
        return _modeloIS_M1(H1, t1, t2, parametros);

      default:
        return 0;
    }
  }









}