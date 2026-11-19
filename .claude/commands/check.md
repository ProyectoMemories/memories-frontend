---
description: Corre lint, formato y pruebas del repo
---
Fase: Pruebas.

Ejecuta, en este orden:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Resume el resultado. Si algo falla, explica la causa y propone el arreglo.
**Nunca** cambies un test para que pase sin avisarlo.
