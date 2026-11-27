# Fuentes de la app (D79)

Fraunces (títulos) y Nunito Sans (texto), licencia SIL Open Font License 1.1:
ver el `OFL.txt` de cada carpeta. Ninguna declara "Reserved Font Name", así
que las versiones fijas conservan su nombre.

## Origen

`github.com/google/fonts`, commit `5026800714d07231937d92eb4cceabf06e05d74e`:

| Archivo de origen | sha256 |
|---|---|
| `ofl/fraunces/Fraunces[SOFT,WONK,opsz,wght].ttf` | `177ff6c0f14e5550a3c624247cd1189611d4eb65d000b14944c63d967958abbb` |
| `ofl/fraunces/Fraunces-Italic[SOFT,WONK,opsz,wght].ttf` | `b24448c43702fac4ee856781d461a0dfba8d8e594b6e8e190234b75fed2c0e01` |
| `ofl/nunitosans/NunitoSans[YTLC,opsz,wdth,wght].ttf` | `f934d7142fb4784bf828da485b7dcbd90c0c80d514e9d49a5da0ed3a1ae2491d` |

## Por qué versiones fijas

En Flutter el peso de una fuente variable no sigue a `fontWeight`, así que se
sacan los pesos que usa el mockup como archivos fijos con fonttools 4.60.1. Los
ejes que no son el peso quedan en el valor que sirve Google Fonts al mockup;
el tamaño óptico se fija en 36 para Fraunces (títulos de 25 a 38 px) y en 12
para Nunito Sans (texto de 12 a 16 px).

```powershell
python -m pip install fonttools==4.60.1
# Fraunces: -Medium (500), -Bold (700) y, desde la cursiva, -MediumItalic (500)
python -m fontTools.varLib.instancer "Fraunces[SOFT,WONK,opsz,wght].ttf" wght=500 opsz=36 SOFT=0 WONK=1 --static -o fraunces/Fraunces-Medium.ttf
# Nunito Sans: -Regular (400), -SemiBold (600), -Bold (700), -ExtraBold (800)
python -m fontTools.varLib.instancer "NunitoSans[YTLC,opsz,wdth,wght].ttf" wght=400 wdth=100 opsz=12 YTLC=500 --static -o nunito_sans/NunitoSans-Regular.ttf
```

Si se necesita otro peso, se genera igual y se declara en `pubspec.yaml`.
