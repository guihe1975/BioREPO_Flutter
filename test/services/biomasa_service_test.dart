import 'package:flutter_test/flutter_test.dart';
import 'package:biorepo/services/biomasa_service.dart';

void main() {
  test('B1 returns biomass in kg/ha for Pinus pinea', () {
    final biomasa = BiomasaService.calcularBiomasaExpost(
      modeloBiomasa: 'B1',
      edad: 10,
      densidad: 1000,
      indiceSitio: 6.279362171545004,
      parametros: {
        'p4': 250.9,
        'p5': 0.77303,
        'p6': 0.00031,
        'p7': 0.08417,
      },
    );

    expect(biomasa, closeTo(10258.044418859, 0.001));
    expect(biomasa / 1000, closeTo(10.258044419, 0.000001));
  });
}
