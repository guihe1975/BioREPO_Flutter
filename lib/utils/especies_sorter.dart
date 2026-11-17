List<Map<String, dynamic>> ordenarResultadosPorEspecie(
  List<Map<String, dynamic>> resultados,
) {
  final ordenados = List<Map<String, dynamic>>.of(resultados);
  ordenados.sort((a, b) {
    final nombreA = (a["nombre"] as String).trim();
    final nombreB = (b["nombre"] as String).trim();
    final generoA = nombreA.split(RegExp(r"\s+")).first.toLowerCase();
    final generoB = nombreB.split(RegExp(r"\s+")).first.toLowerCase();
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

    return nombreA.toLowerCase().compareTo(nombreB.toLowerCase());
  });
  return ordenados;
}

int _grupoGenero(String genero) {
  if (genero == "pinus") return 0;
  if (genero == "quercus") return 1;
  return 2;
}
