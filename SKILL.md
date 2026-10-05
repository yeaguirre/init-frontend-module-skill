---
name: init-frontend-module
user-invocable: true
description: Genera la estructura base de módulos frontend siguiendo las convenciones de TGS. Úsalo cuando el usuario pida crear un módulo frontend de categoría SPAC o MEDI.
---

# Frontend Module Skill

Genera la estructura base de un módulo frontend TGS.

## Cuándo usarlo

Cuando el usuario pida crear un nuevo módulo frontend de categoría SPAC o MEDI.

## Cómo ejecutar

### Paso 0 — Si ya hay parámetros en el mensaje

Si el usuario ya pasó parámetros (Category, ProjectPath, etc.), usalos y no los
vuelvas a preguntar. Preguntá solo lo que falte.

### Paso 1 — Recopilar parámetros

Preguntá en este orden:

1. **ModuleName**: ¿cómo se llama el nuevo módulo/pantalla?

2. **Category**: ¿`SPAC` o `MEDI`?

3. **ProjectPath**: ¿cuál es la ruta base del proyecto?
   Normalmente `src/medi` o `src/spac` según `Category`.
   **Tiene que existir.** Si no existe, avisá y no continúes.

4. **Anidamiento** (pregunta binaria explícita):
   > "¿Este módulo va dentro de una estructura anidada ya existente,
   > o es una carpeta simple de un solo nivel?"
   Opciones: **Simple** / **Anidado**.

   - **Simple** → listá con el filesystem las carpetas existentes directamente
     dentro de `ProjectPath` y ofrecélas como opciones para elegir. Ofrecé
     también **Crear una carpeta nueva**. Si el usuario la elige, preguntá su
     nombre (un solo nivel, ej. `Despacho`); el script creará esa carpeta.
     Si `ProjectPath` no tiene subcarpetas, ofrecé directamente crear una.

   - **Anidado** → navegación guiada nivel por nivel. En cada nivel mostrá:

     ```
     Estás en: <ruta acumulada>

     Subcarpetas existentes:
       1. <subcarpeta 1>
       2. <subcarpeta 2>
       ...

     ¿Qué querés hacer?
       [1-9]  Entrar a una subcarpeta de la lista
       [N]    Crear una carpeta nueva en este nivel
       [A]    Usar esta carpeta como destino final (crear el módulo acá)
       [M]    Escribir una ruta manualmente
       [C]    Cancelar
     ```

     Reglas de cada opción:

     - **`1-9`** → entrar a la subcarpeta indicada. Agregala a la ruta
       acumulada y repetí el menú sobre esa subcarpeta.
     - **`N`** → preguntá el nombre de la carpeta nueva. Agregala a la ruta
       acumulada. El script la creará si no existe. Repetí el menú sobre
       esa carpeta (que todavía no existe en disco).
     - **`A`** → terminá la navegación. `FolderName` final es la ruta acumulada.
     - **`M`** → el usuario escribe una ruta manual (ej. `Balance/Reportes`).
       Validá segmento por segmento contra el filesystem:
       - Si **todos existen** → usar esa ruta como `FolderName` final.
       - Si **alguno no existe** → preguntar:
         *"El segmento 'X' no existe. ¿Querés crearlo, corregir la ruta,
         o cancelar?"*
         - Crearlo → agregarlo a la ruta y continuar.
         - Corregir → volver a pedir la ruta.
         - Cancelar → terminar sin crear nada.
     - **`C`** → terminar la navegación sin ejecutar el script. Informar
       que se canceló.

     Si el usuario escribe una opción no reconocida, repetí el menú.

### Paso 1.5 — Recopilar parámetros de integración

Una vez resueltos `Category`, `ProjectPath`, `FolderName` y `ModuleName`, la
skill debe preparar también la integración funcional del módulo.

Preguntá o proponé, en este orden:

1. **RoutePath**: ruta web de la pantalla. Proponé una ruta derivada de la
   categoría, las carpetas y el módulo, por ejemplo:
   `/medi/balance/configuracion/protones`.
2. **MenuLabel**: texto visible en el menú, por ejemplo:
   `Balance > Configuración > Protones`.
3. **Roles**: preguntá qué roles deben proteger la pantalla.

   **Reglas de roles:**
   - El usuario **no puede crear roles nuevos**. Solo puede elegir roles que
     ya existan en `src/common/roles.js`.
   - Preguntá un rol por vez: *"¿Qué rol protege esta pantalla?"*.
   - Después de cada rol, preguntá: *"¿Querés agregar otro rol? (sí/no)"*.
   - Repetí hasta que el usuario diga que no.
   - Acumulá los roles en una lista.

4. **MenuKey**: proponé una clave en mayúsculas derivada de `ModuleName`, por
   ejemplo `PROTONES`.

**Verificación temprana de roles (antes de ejecutar el script):**

Una vez que tengas la lista de roles, **leé** `src/common/roles.js` y
verificá que cada rol exista como `export const <ROL> = ...`. **No modifiques
`roles.js`.**

- Si **todos existen** → continuá.
- Si **alguno no existe** → avisá al usuario:
  *"El rol X no está en roles.js. Agregalo manualmente y volvé a ejecutar
  la skill."*
  No ejecutes el script.

**Cómo pasar los roles al script:**

Siempre pasá la lista como array de PowerShell, incluso si hay un solo rol:

```powershell
-Roles @("ROL_A")
-Roles @("ROL_A", "ROL_B", "ROL_C")
```

### Paso 1.6 — Diferenciar rutas

No confundas estas rutas:

- `$modDir`: ruta física `ProjectPath/FolderName/ModuleName`.
- `componentPath`: import relativo desde el `Module.jsx` de la categoría.
- `RoutePath`: ruta web utilizada por React Router.

Para MEDI, el archivo de integración es `src/medi/Module.jsx`, y el módulo de
trazabilidad existente es `MODULES.MEDI`. Para SPAC, usá `src/spac/Module.jsx`
y `MODULES.SPAC`. No crees una constante `MEDI_MODULE` si no existe una
convención comprobada en el proyecto.

El import del componente generado debe quedar al final del bloque de imports:
inmediatamente antes del comentario que precede a `TracedConsultaDePuntos` en
MEDI. En SPAC, si no hay un comentario equivalente, ubicalo inmediatamente
antes de `class Module`.

### Paso 2 — Validar antes de ejecutar

Antes de correr el script, verificá con el filesystem si existe
`ProjectPath/FolderName/ModuleName`.

**Esta skill nunca sobreescribe.** Si el destino ya existe, se aborta.

- **Si no existe** → ejecutá el script normalmente.
- **Si existe y tiene contenido** → **no ejecutes el script**. Informá:
  *"Ya existe un módulo con ese nombre en esa ruta y tiene archivos.
  No se sobreescribe. Elegí otro nombre para la nueva pantalla, u otra
  carpeta destino."*
  Fin del flujo.
- **Si existe pero está vacía** → **no ejecutes el script**. Informá:
  *"Ya existe una carpeta con ese nombre en esa ruta (está vacía).
  Borrala manualmente si querés crear el módulo acá, o elegí otro nombre."*
  Fin del flujo.

### Paso 3 — Ejecutar

Ejecutá `scripts/create-tgs-module.ps1` desde el directorio base de esta skill.
**No ejecutes el script sin parámetros.**

Parámetros:

- `-ProjectPath`: ruta base del proyecto (debe existir).
- `-Category`: `SPAC` o `MEDI`.
- `-FolderName`: un solo nivel (`Despacho`) o anidado (`Balance/Configuracion`).
  El script crea la cadena de carpetas intermedias si no existe.
- `-ModuleName`: nombre del nuevo módulo.
- `-Integrate` (opcional): habilita la integración de los roles existentes
  en el import y `RouteProtected`, el menú y `Module.jsx`. La skill debe usarlo
  cuando el usuario confirme la fase completa.
- `-Roles` (opcional, array de nombres): roles existentes que se agregan al
  import y al array `roles` de `RouteProtected`. Todos deben estar declarados
  en `src/common/roles.js`; el script valida la existencia y nunca modifica
  ese archivo.
- `-RoutePath` (opcional): ruta web de la pantalla.
- `-MenuKey` (opcional): clave de `MENU_MEDI` o `MENU_SPAC`.
- `-MenuLabel` (opcional): texto visible del menú.

**No existe `-Force`.** La skill no sobreescribe bajo ninguna circunstancia.

Ejemplos:

Simple:
```powershell
.\scripts\create-tgs-module.ps1 -ProjectPath "C:\repos\etgs-ui\src\medi" -Category "MEDI" -FolderName "CalidadGas" -ModuleName "CalculoCombustible"
```

Anidado:
```powershell
.\scripts\create-tgs-module.ps1 -ProjectPath "C:\repos\etgs-ui\src\medi" -Category "MEDI" -FolderName "Balance/Configuracion" -ModuleName "CalculoCombustible"
```

Creación e integración completa:

```powershell
.\scripts\create-tgs-module.ps1 `
   -ProjectPath "C:\repos\etgs-ui\src\medi" `
   -Category "MEDI" `
   -FolderName "Balance/Configuracion" `
   -ModuleName "Protones" `
   -Integrate `
   -RoutePath "/medi/balance/configuracion/protones" `
   -MenuKey "PROTONES" `
   -MenuLabel "Balance > Configuracion > Protones" `
   -Roles @("ROLE_MEDI_VER_PROTONES", "ROLE_MEDI_EDITAR_PROTONES")
```

Cuando se usa `-Integrate`, el script intenta incorporar:

- `src/common/constants/menu-module.jsx`;
- `src/medi/Module.jsx` o `src/spac/Module.jsx`.

La integracion tolera algunos registros existentes, pero la ejecucion completa
no es idempotente: si el directorio del modulo ya existe, la validacion de
colision aborta antes de integrar. Si ya existe `MenuKey`, el script conserva
su valor actual sin comprobar que coincida con `MenuLabel`. Si la ruta ya esta
asociada al mismo componente, conserva el `RouteProtected` existente sin
reconciliar sus roles u otros valores. Los roles faltantes en el import se
agregan; el import del componente se quita y se vuelve a insertar en el ancla
correspondiente.

`src/common/roles.js` se consulta para validar los roles, pero **nunca se escribe**.
El script calcula un hash de `roles.js` antes y después de la ejecución. Si el
hash cambia, aborta con error. Esto es una red de seguridad: si el archivo
cambió, algo salió mal y hay que revisarlo manualmente. El generador crea
primero la estructura, escribe el menu y luego actualiza `Module.jsx`; si una
etapa posterior falla, no revierte los cambios anteriores. La skill debe
informar claramente cualquier modificacion parcial.

El script no debe duplicar claves de menú, imports ni rutas existentes. La
entrada del menú debe ser la única línea nueva en `menu-module.jsx`; el resto
del archivo y su encoding deben conservarse. En `Module.jsx`, el import del
componente va después del bloque de imports de roles. Los roles seleccionados
se agregan al import existente y todos se incluyen en `roles={[...]}`.

### Paso 4 — Reportar

Informá al usuario:
- Ruta final creada.
- Si fue simple o anidado.
- Si se crearon carpetas intermedias nuevas.
- Ruta web registrada.
- Roles existentes validados y reutilizados (sin modificar `roles.js`).
- Entrada agregada o reutilizada en `MENU_MEDI` o `MENU_SPAC`.
- `Module.jsx` actualizado con el import y `RouteProtected`.
- Módulo de trazabilidad utilizado (`MODULES.MEDI` o `MODULES.SPAC`).
- Validaciones ejecutadas y cualquier paso manual pendiente.

### Cancelación

En cualquier paso, si el usuario dice "cancelar" o "salir", terminá la skill
sin ejecutar el script. Informá que se canceló.
