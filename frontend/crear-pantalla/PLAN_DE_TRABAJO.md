# Guía de avance: inicializar un módulo y construir su pantalla

Fecha de actualización: 2026-10-07.

## 1. Objetivo

Probar que Copilot Agent Mode puede construir una pantalla modular sobre la
estructura que genera `init-frontend-module`, reutilizando componentes del
proyecto y creando los contenedores y la lógica local necesarios.

Primero validaremos una pantalla básica. Después profundizaremos en los
contratos, preguntas y referencias de cada componente. No necesitamos
documentar todo el catálogo antes de realizar esa primera prueba.

Este documento es una guía de trabajo, no una skill ejecutable ni una orden
para implementar todas las fases de una sola vez.

## 2. Estado actual

- Existe la skill `init-frontend-module` para MEDI y SPAC y su generador
  `scripts/create-tgs-module.ps1`.
- Esa skill resuelve la ubicación y genera el componente principal, contexto,
  servicio y carpetas base. Admite integración opcional con roles existentes,
  menú y ruta protegida; tiene límites documentados y no hace rollback.
- Se revisaron ejemplos de MEDI para comprender Panel Container, Modal,
  Action Bar y Tabla. Esa revisión inicial no equivale a un catálogo completo
  ni a una aprobación de todas las variantes encontradas.
- Existe ahora `SKILL.md` de `/crear-pantalla`, con invocación manual y
  referencias mínimas para contenedores, tabla, acciones, modal y servicio
  mock asíncrono. No se ha validado todavía su invocación en una nueva
  conversación ni se ha ejecutado un piloto de construcción.
- Esta guía registra el flujo acordado. El requerimiento y módulo concreto
  del piloto todavía deben elegirse.

## 3. Dos invocaciones independientes

### Paso A: inicialización, cuando el dev lo decide

El dev invoca `/init-frontend-module`. Esa skill pregunta los parámetros
faltantes, guía la elección de carpetas y ejecuta su script.

El destino de la prueba estará bajo `src/medi`, en la ubicación elegida por
el dev, como las otras pantallas. No habrá una carpeta fija `PruebasAgente`.

La inicialización rechaza un destino existente. No debemos modificar ese
comportamiento ni la skill actual como parte de este trabajo.

### Paso B: construcción, cuando el dev decide continuar

El dev invoca `/crear-pantalla` en otro momento, incluso en otra conversación.
La nueva skill debe preguntar sobre qué módulo existente trabajará y qué
requerimiento funcional debe implementar, salvo que ya se hayan proporcionado.

No debe asumir que el destino es el último módulo generado. Debe comprobar
su ruta, inspeccionar los archivos y confirmar la pantalla elegida.

`/crear-pantalla` no invoca automáticamente la primera skill, no ejecuta su
script y no vuelve a inicializar el módulo. Si falta la base, informa qué
falta y pide al dev resolverlo antes de continuar.

## 4. Construcción sobre la base existente

La segunda skill necesita poder completar el componente principal, contexto
y servicio existentes, además de agregar componentes locales. Por lo tanto,
no debe rechazar el módulo solo porque su directorio ya existe.

Antes de editar, distingue archivos base, implementación existente y cambios
del dev. Presenta los archivos que creará o modificará y espera confirmación.
No reemplaza archivos completos indiscriminadamente ni elimina trabajo previo.

La estructura concreta depende del requerimiento y de las convenciones
verificadas. Un piloto podría incluir:

```text
<ModuloExistente>/
    <NombrePantalla>.jsx
    Context.jsx
    Service.js
    components/
        containers/
            PanelContainer.jsx
            TableContainer.jsx
            ActionBarContainer.jsx
        tables/
            <NombrePantalla>Table.jsx
        modals/
            <NombreAccion>Modal.jsx
        buttons/
        combos/
    hooks/
```

Es una propuesta, no una obligación de crear archivos o carpetas vacíos.
Los componentes comunes se importan; no se copian dentro de cada pantalla.

## 5. Qué representa cada pieza

| Pieza | Responsabilidad a documentar y probar |
|-------|--------------------------------------|
| Panel Container | Contenedor local que compone filtros, fechas, selectores y botones, y coordina sus acciones. |
| Tabla local | Define columnas y adapta registros al contrato de la tabla común elegida. |
| Table Container | Conecta datos, estado y callbacks de pantalla con la tabla local cuando esa separación sea necesaria. |
| Action Bar | Usa `CommonActionBar` para presentar controles; las acciones y reglas viven en lógica local o contexto. |
| Modal local | Compone un diálogo existente con campos, validaciones y callbacks propios de la pantalla. |
| Contexto/hook local | Coordina estado compartido, carga, errores, selección y operaciones según la necesidad. |
| Servicio local | Encapsula llamadas con endpoints y contratos confirmados; no inventa una API. |

MEDI usa componentes propios y comunes heredados de otras ubicaciones.
`CommonDialog`, los distintos hooks `useModal`, `CommonTable`,
`MediCommonTable` y variantes SPAC no deben tratarse como equivalentes sin
verificar implementación y uso. Estar en uso no garantiza ser la opción
recomendada para una pantalla nueva.

## 6. Entradas de la skill

- Ruta del módulo inicializado, elegida por el dev.
- Requerimiento funcional en Markdown: controles, datos, acciones y resultados
  esperados. El agente pregunta solo por información faltante o contradictoria.
- Referencias mínimas verificadas de los componentes y patrones necesarios.
- Datos de ejemplo o contrato de servicio, según el alcance confirmado.
- Imágenes opcionales para interpretar distribución y controles visibles,
  si el modelo utilizado admite visión. No sustituyen reglas funcionales ni
  contratos de backend; las ambigüedades se consultan al dev.

A futuro, el Markdown podrá provenir de un documento funcional de SharePoint
y complementarse con requerimientos de Jira. La obtención, permisos de acceso
y conversión de esas fuentes se definirán aparte. El piloto no depende de
conectarse a SharePoint o Jira y no usa RAG.

## 7. Fases de avance

### Fase 1: preparar y ejecutar el piloto básico

1. Acordar un requerimiento pequeño que ejercite Panel, Tabla, Action Bar y
   Modal, con comportamiento observable y datos de ejemplo definidos.
2. Preparar solo las referencias indispensables, respaldadas por código real.
3. Implementar `SKILL.md` para probar la invocación `/crear-pantalla`, con
   `name: crear-pantalla`, invocación manual habilitada y
   `disable-model-invocation: true`. El dev decide cuándo iniciarla.
4. El dev inicializa el módulo con la primera skill y luego invoca la segunda.
5. La segunda inspecciona el destino, lee el requerimiento, propone piezas y
   conexiones y espera confirmación antes de editar.
6. Construye y conecta las piezas una por una, validando cada paso. Si falta
   información imprescindible, pregunta; no espera una fase futura para
   corregir imports, props o contratos básicos necesarios para funcionar.
7. Reporta resultados y límites. No presenta archivos vacíos como una
   pantalla funcional terminada.

Para aislar la prueba de composición, se propone usar datos locales de ejemplo
con confirmación del dev. Si se elige un GET real, necesita su contrato antes
de implementarlo. Los datos locales no demuestran integración con backend.

### Fase 2: profundizar la construcción guiada por componente

Después del piloto, ampliar las referencias y preguntas de cada pieza.
Dentro de la misma skill, resolver un componente por vez: entender, preguntar,
proponer, confirmar, implementar y validar. No crear una skill por componente.

Para Tabla, por ejemplo, resolver columnas, nombres, tipos, formato, selección,
ordenamiento y paginación. La cantidad de registros proviene de los datos;
las filas por página son una configuración. Para el GET, confirmar endpoint,
parámetros y respuesta, incluida la paginación local o de servidor.

Documentar por separado composición interna y componentes relacionados.
Las referencias vivirán en `references/componentes/` y usarán enlaces
relativos válidos. La skill leerá las pertinentes al requerimiento, no todo
el catálogo. Registrar procedencia, ejemplos y recomendaciones justificadas;
marcar incertidumbres con `<!-- VERIFICAR: ... -->`.

### Fase 3: incorporar contexto externo

Definir cómo recibir documentación funcional de SharePoint y requerimientos
de Jira, identificar sus versiones y consultar contradicciones con el dev.
Esas fuentes enriquecen el requerimiento; no cambian automáticamente el
destino, los permisos ni el alcance de implementación.

## 8. Integración y validación visual

La construcción inicial no cambia menú, roles ni el módulo raíz de rutas.
Si el dev integró la base al inicializarla, se conserva esa integración y
podrá utilizarse para probar, sujeto a permisos y configuración disponibles.

Si la base no está integrada, no se afirma que sea navegable: habrá que
acordar una prueba de renderizado o autorizar integración por separado.
No modificar `roles.js` ni agregar una ruta temporal sin autorización.

## 9. Cómo sabremos que el piloto funcionó

- La segunda skill se inicia por decisión del dev y selecciona el módulo
  existente correcto, sin ejecutar de nuevo el generador.
- Crea componentes locales y reutiliza los comunes mediante imports válidos.
- El componente principal monta las piezas bajo el contexto correspondiente.
- Los datos llegan a la tabla con el formato que exige su implementación.
- Las acciones, habilitación y apertura/cierre del modal funcionan conforme
  al requerimiento; aceptar y cancelar tienen resultados verificables.
- Se preservan los cambios existentes y solo se editan archivos confirmados.
- Se ejecutan los chequeos acotados disponibles. Compilar o revisar
  diagnósticos no sustituye una prueba de interacción.
- Se informa qué se probó realmente, qué sigue pendiente y si los datos son
  locales o provienen de un servicio real.

## 10. Próximo paso

Acordar el requerimiento del piloto, el módulo inicializado y cómo observar
su funcionamiento. Invocar `/crear-pantalla` para conectar los contenedores
con un array mock mediante una promesa del servicio local, sin un GET HTTP.
La skill y las referencias mínimas ya están creadas; todavía no hay una
pantalla de prueba ni se modificó `init-frontend-module`.