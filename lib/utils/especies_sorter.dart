List<String> ordenarNombresEspecies(List<String> especies) {
  final ordenadas = List<String>.of(especies);
  ordenadas.sort(_compararNombresEspecie);
  return ordenadas;
}

List<Map<String, dynamic>> ordenarResultadosPorEspecie(
  List<Map<String, dynamic>> resultados,
) {
  final ordenados = List<Map<String, dynamic>>.of(resultados);
  ordenados.sort((a, b) {
    return _compararNombresEspecie(
      a["nombre"] as String,
      b["nombre"] as String,
    );
  });
  return ordenados;
}

int _compararNombresEspecie(String nombreA, String nombreB) {
  final nombreNormalizadoA = nombreA.trim().toLowerCase();
  final nombreNormalizadoB = nombreB.trim().toLowerCase();
  final generoA = nombreNormalizadoA.split(RegExp(r"\s+")).first;
  final generoB = nombreNormalizadoB.split(RegExp(r"\s+")).first;
  final grupoA = _grupoGenero(generoA);
  final grupoB = _grupoGenero(generoB);

  if (grupoA != grupoB) {
    return grupoA.compareTo(grupoB);
  }

  if (grupoA == 2) {
    final comparacionGenero = generoA.compareTo(generoB);
    if (comparacionGenero != 0) {
      return comparacionGenero;
    }
  }

  return nombreNormalizadoA.compareTo(nombreNormalizadoB);
}

int _grupoGenero(String genero) {
  if (genero == "pinus") return 0;
  if (genero == "quercus") return 1;
  return 2;
}
