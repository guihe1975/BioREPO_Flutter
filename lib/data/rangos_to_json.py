import pandas as pd
import json

# 🔹 Leer el EXCEL
df = pd.read_excel("C:/Users/madrigal/Nextcloud/Flutter/Mi_App/mi_primera_app/lib/data/rangos.xlsx")

# 🔹 Limpiar nombres columnas
df.columns = df.columns.str.strip()

resultado = {"especies": []}

# 🔹 Agrupar por especie
for especie, grupo in df.groupby("Especie/Grupo"):
    especie_data ={
        "nombre": especie,
    }

    for _, row in grupo.iterrows():
        variable = row["Variable"].strip()


        datos = {
            "media": float(row["Media"]),
            "min": float(row["Mín"]),
            "max": float(row["Máx"])
        }
        # 🔹 Mapear nombres
        if variable.startswith("Edad"):
            especie_data["edad"] = datos
        elif variable.startswith("N"):
            especie_data["densidad"] = datos
        elif variable.lower():
            especie_data["precipitación"] = datos
        elif "Tm" in variable:
            especie_data["temperatura"] = datos
    resultado["especies"].append(especie_data)

# 🔹 Guardar JSON
with open("rangos.json", "w", encoding="utf-8") as f:
    json.dump(resultado, f, indent=2, ensure_ascii=False)
