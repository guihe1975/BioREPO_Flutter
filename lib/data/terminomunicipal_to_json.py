import pandas as pd
import json

df = pd.read_excel("C:/Users/madrigal/Nextcloud/Flutter/Mi_App/mi_primera_app/lib/data/provincias.xlsx")

resultado = {"provincias": []}

for provincia, grupo in df.groupby("PROV.NOMBRE"):

    provincia_data = {
        "nombre": provincia,
        "municipios": []
    }

    for _, row in grupo.iterrows():

        municipio = {
            "nombre": row["T.M.NOMBRE"],
            "pt": float(row["Pt (mm)"]),
            "tm": float(row["Tm(ºC)"]),
            "martonne": float(row["Martonne"])
        }

        provincia_data["municipios"].append(municipio)

    resultado["provincias"].append(provincia_data)

with open("terminomunicipal.json", "w", encoding="utf-8") as f:
    json.dump(resultado, f, indent=2, ensure_ascii=False)
