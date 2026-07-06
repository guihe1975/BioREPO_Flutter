import pandas as pd
import json

archivo = "C:/Users/madrigal/Nextcloud/Flutter/Mi_App/mi_primera_app/lib/data/exante_parametros.xlsx"

# ✅ leer hojas
df_especies = pd.read_excel(archivo, sheet_name="modelo")
df_param = pd.read_excel(archivo, sheet_name="parametros")

# limpiar columnas
df_especies.columns = df_especies.columns.str.strip()
df_param.columns = df_param.columns.str.strip()

# obtener provincias (todas menos las 2 primeras)
provincias = df_param.columns[2:]

resultado = {"provincias": []}

# ✅ recorrer provincias
for prov in provincias:

    provincia_data = {
        "nombre": prov,
        "especies": []
    }

    # recorrer especies
    for _, row_esp in df_especies.iterrows():

        nombre = row_esp["Especie"]
        modelo = row_esp["Modelo"]
        xcl1 = row_esp["Xcl1"]
        xcl2 = row_esp["Xcl2"]
        carbono = row_esp["Carbono"]

        # filtrar parámetros de esa especie
        bloque = df_param[df_param["Especie"] == nombre]

        parametros = {}

        for _, row_par in bloque.iterrows():

            param = row_par["Parametro"]
            val = row_par[prov]

            if pd.isna(val):
                parametros[param] = None
            else:
                parametros[param] = float(val)

        especie_data = {
            "nombre": nombre,
            "modelo": modelo,
            "xcl1": xcl1,
            "xcl2": xcl2,
            "carbono": float(carbono),
            "parametros": parametros
        }

        provincia_data["especies"].append(especie_data)

    resultado["provincias"].append(provincia_data)

# ✅ guardar JSON
with open("exante_parametros.json", "w", encoding="utf-8") as f:
    json.dump(resultado, f, indent=2, ensure_ascii=False)

print("✅ JSON generado correctamente 🚀")
