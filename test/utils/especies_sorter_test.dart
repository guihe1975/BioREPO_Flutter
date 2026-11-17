import 'package:flutter_test/flutter_test.dart';
import 'package:biorepo/utils/especies_sorter.dart';

void main() {
  test('ordena Pinus, Quercus y otros generos en el orden solicitado', () {
    final resultados = <Map<String, dynamic>>[
      {'nombre': 'Cedrus atlantica'},
      {'nombre': 'Quercus suber'},
      {'nombre': 'Pinus radiata'},
      {'nombre': 'Abies pinsapo'},
      {'nombre': 'Quercus ilex'},
      {'nombre': 'Pinus nigra'},
      {'nombre': 'Abies alba'},
    ];

    final ordenados = ordenarResultadosPorEspecie(resultados);

    expect(
      ordenados.map((item) => item['nombre']).toList(),
      [
        'Pinus nigra',
        'Pinus radiata',
        'Quercus ilex',
        'Quercus suber',
        'Abies alba',
        'Abies pinsapo',
        'Cedrus atlantica',
      ],
    );
  });

  test('ordena nombres ignorando mayusculas y minusculas', () {
    expect(
      ordenarNombresEspecies([
        'Abies alba',
        'quercus ilex',
        'pinus nigra',
        'Pinus radiata',
      ]),
      [
        'pinus nigra',
        'Pinus radiata',
        'quercus ilex',
        'Abies alba',
      ],
    );
  });
}
