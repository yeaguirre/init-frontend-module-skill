---
name: frontend-module-skill
description: Genera la estructura base de módulos frontend siguiendo las convenciones de TGS. Úsalo cuando el usuario pida crear un módulo frontend de categoría SPAC o MEDI.
---

# Frontend Module Skill

Genera la estructura base de un módulo frontend TGS.

## Cuándo usarlo

Cuando el usuario pida crear un nuevo módulo frontend de categoría SPAC o MEDI, proporcionando nombre de módulo, carpeta padre y ruta del proyecto.

## Cómo ejecutar

Ejecuta el script `scripts/create-tgs-module.ps1` desde el directorio base de esta skill. **No ejecutes el script sin parámetros.**

Parámetros requeridos:

- `-ProjectPath`: ruta base del proyecto (debe existir). Ejemplo: `C:\repos\etgs-ui\src\medi`
- `-Category`: `SPAC` o `MEDI`
- `-FolderName`: nombre de la carpeta padre. Ejemplo: `CalidadGas`
- `-ModuleName`: nombre del nuevo módulo. Ejemplo: `CalculoCombustible`

Ejemplo de invocación:

```powershell
.\scripts\create-tgs-module.ps1 -ProjectPath "C:\repos\etgs-ui\src\medi" -Category "MEDI" -FolderName "CalidadGas" -ModuleName "CalculoCombustible"
