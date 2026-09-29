---
name: frontend-module-skill
description: Genera la estructura base de módulos frontend siguiendo las convenciones de TGS. Úsalo cuando el usuario pida crear un módulo frontend de categoría SPAC o MEDI.
---

# Frontend Module Skill

Genera la estructura base de un módulo frontend TGS.

## Cuándo usarlo

Cuando el usuario pida crear un nuevo módulo frontend de categoría SPAC o MEDI, proporcionando nombre de módulo, carpeta padre y ruta del proyecto.

## Cómo ejecutar

### Paso 1 — Recopilar parámetros

Si el usuario invocó la skill sin parámetros (por ejemplo `/frontend-module-skill` solo),
pregunta en este orden:

1. **ModuleName**: ¿cómo se llama el nuevo módulo/pantalla?
2. **Anidamiento** (pregunta binaria explícita):
   "¿Este módulo va dentro de una estructura anidada ya existente (por ejemplo,
   adentro de un módulo padre que ya tiene submódulos), o es una carpeta simple
   de un solo nivel?" — opciones: **Simple** / **Anidado**.
3. Según la respuesta:
   - **Simple** → pregunta `FolderName` (carpeta padre de un solo nivel, ej.
     `Despacho`). Si no existe todavía, el script la crea.
   - **Anidado** → **no le pidas al usuario que escriba la ruta completa a mano**:
     a. Preguntá cuál es el módulo/carpeta padre raíz (ej. `Balance`).
     b. Listá el contenido real de esa carpeta (`ProjectPath/<raíz>`) con la
        herramienta de listado de directorio.
     c. Presentá las subcarpetas existentes como opciones para elegir (más una
        opción "Crear una carpeta nueva acá" por si quiere agregar un nivel que
        todavía no existe).
     d. Si el usuario elige una subcarpeta existente, repetí b-c listando *esa*
        subcarpeta, preguntando si quiere anidar un nivel más adentro, hasta que
        elija "acá" o "carpeta nueva".
     e. Armá el `FolderName` final concatenando los niveles elegidos con `/`
        (ej. `Balance/Configuracion`).
4. **Category**: ¿SPAC o MEDI?
5. **ProjectPath**: ¿cuál es la ruta base del proyecto? (normalmente `src/medi`
   o `src/spac` según `Category`).

Si el usuario ya pasó los parámetros en el mensaje, no preguntes: úsalos directamente.

### Paso 2 — Validar antes de ejecutar

Antes de correr el script, verificá si `ProjectPath/FolderName/ModuleName` ya
existe y tiene archivos (el script sobreescribe `.jsx`/`Context.jsx`/`Service.js`
sin avisar). Si ya existe, pedí confirmación explícita al usuario antes de
continuar; si no confirma, no ejecutes el script.

### Paso 3 — Ejecutar

Ejecuta el script `scripts/create-tgs-module.ps1` desde el directorio base de esta skill.
**No ejecutes el script sin parámetros.**

Parámetros requeridos:

- `-ProjectPath`: ruta base del proyecto (debe existir). Ejemplo: `C:\repos\etgs-ui\src\medi`
- `-Category`: `SPAC` o `MEDI`
- `-FolderName`: carpeta padre. Acepta **un solo nivel** (`CalidadGas`) o **anidamiento con `/`** (`Despacho/Sub1/Sub2`). El script crea toda la cadena de carpetas intermedias.
- `-ModuleName`: nombre del nuevo módulo. Ejemplo: `CalculoCombustible`

Ejemplos de invocación:

Un nivel:
```powershell
.\scripts\create-tgs-module.ps1 -ProjectPath "C:\repos\etgs-ui\src\medi" -Category "MEDI" -FolderName "CalidadGas" -ModuleName "CalculoCombustible"
```

Anidado:
```powershell
.\scripts\create-tgs-module.ps1 -ProjectPath "C:\repos\etgs-ui\src\medi" -Category "MEDI" -FolderName "Despacho/Sub1/Sub2" -ModuleName "CalculoCombustible"
```
