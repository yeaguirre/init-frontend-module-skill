---
name: crear-pantalla
description: 'Construye una pantalla piloto MEDI sobre un modulo ya inicializado, componiendo contenedores, tabla, acciones y modal con componentes existentes y datos mock asincronos. Usar cuando el dev invoque /crear-pantalla para implementar un requerimiento funcional.'
argument-hint: 'Ruta del modulo existente y requerimiento funcional .md'
user-invocable: true
disable-model-invocation: true
---

# Crear pantalla: piloto MEDI

## Alcance

Construir y conectar componentes locales de una pantalla existente usando
referencias verificadas y un servicio mock que devuelve una promesa con datos.
No basta con crear carpetas o contenedores vacios.

El dev invoca primero `init-frontend-module` cuando desea inicializar el
modulo. Luego decide cuando invocar esta skill. No ejecutar esa otra skill,
su script ni volver a inicializar el destino. No elegir automaticamente el
ultimo modulo creado.

## 1. Resolver destino y requerimiento

Preguntar solo lo que falte, en este orden:

1. Sobre que modulo/pantalla existente bajo `src/medi` se trabajara. Permitir
   indicar una ruta o navegar carpetas existentes nivel por nivel hasta elegir
   el modulo. No crear otra ubicacion ni una carpeta fija de pruebas.
2. Que requerimiento funcional implementar: archivo Markdown, adjunto o texto
   del dev. No solicitar acceso a SharePoint/Jira en este piloto.
3. Que datos de ejemplo usar. Si no fueron proporcionados, proponer un array
   coherente con el requerimiento para que el dev lo confirme.

Comprobar que el destino este dentro de `src/medi` y existan componente
principal, contexto y servicio. Si falta la base, informar y detenerse para
que el dev la resuelva; no ejecutar el inicializador por su cuenta.

Inspeccionar los archivos y usos vecinos necesarios. Distinguir estructura
generada y trabajo ya implementado. Un directorio existente es esperado:
completar archivos mediante cambios acotados, no reemplazar trabajo del dev.
Si hay componentes ya creados, proponer reutilizarlos antes de duplicarlos.

Las imagenes adjuntas pueden complementar el requerimiento si el modelo
admite vision; preguntar por reglas o detalles que no sean visibles.

## 2. Elegir las piezas y leer sus referencias

Leer solo los recursos pertinentes, antes de implementar la pieza:

| Necesidad | Recurso |
|-----------|---------|
| Panel de filtros y controles | [Panel Container](./references/componentes/panel-container.md) |
| Tabla y adaptacion de registros | [MediCommonTable](./references/componentes/tabla.md) |
| Barra de acciones local | [Action Bar](./references/componentes/action-bar.md) |
| Dialogo con contenido propio | [Modal](./references/componentes/modal.md) |
| Datos y contrato asincrono del piloto | [Servicio mock](./references/servicio-mock.md) |

Estas son referencias minimas para el piloto, no un catalogo completo. Para
selectores, fechas u otra variante no documentada, verificar la implementacion
real y un uso cercano antes de elegir props; no inventar APIs. No copiar logica
de negocio de una pantalla ajena. Importar componentes comunes, no clonarlos.

## 3. Resolver dudas y confirmar

Extraer del requerimiento los campos, columnas, acciones y estados. Preguntar
solo por ambiguedades imprescindibles, por bloques y paso a paso. Para la
tabla, confirmar nombres/keys/tipos y datos. No preguntar por seleccion o
paginacion si no se solicitaron; declararlas omitidas en la confirmacion.
No exigir un endpoint real: este piloto utiliza un mock local.

Aplicar estos defaults antes de preguntar:

- Si se pide un panel de filtros y ya se definieron columnas de datos, usar
   filtros locales de texto por inclusion, sin distinguir mayusculas/minusculas,
   sobre esas columnas; excluir columnas de acciones y agregar Limpiar filtros.
   Presentar este criterio como supuesto en la confirmacion, no como pregunta
   bloqueante.
- No agregar seleccion ni paginacion si no se solicitaron y la pantalla no las
   necesita para cumplir el requerimiento. Declarar su omision en el resumen.
- Preguntar si falta una regla que cambie el resultado funcional, por ejemplo
   rangos de fecha, inclusividad, normalizacion especial o filtro remoto. No
   preguntar por decisiones visuales reversibles cuando existe un default local.

Antes de crear componentes, asignar una unica responsabilidad a cada archivo.
Si se usan ambos, `TableContainer` consume el contexto y presenta carga, error
o vacio, y conecta callbacks; la tabla local define columnas, adapta celdas y
renderiza `MediCommonTable`. No implementar ni pegar dos variantes del mismo
componente. Si un archivo ya existe, modificarlo en lugar de volver a agregar
una segunda implementacion.

Presentar para confirmacion:

- Ruta del modulo y resumen de comportamiento.
- Contenedores y componentes a crear o reutilizar.
- Archivos existentes a completar (principal, contexto, servicio).
- Array de ejemplo y funcion de servicio que simula el GET sin HTTP.
- Acciones esperadas, alcance local y comprobaciones de funcionamiento.

Esperar aprobacion antes de escribir. Si el dev cancela, no editar ni reiniciar
el flujo. No agregar funcionalidades no acordadas solo para cubrir el catalogo.

## 4. Implementar incrementalmente

1. Completar el servicio local con una operacion asincrona que devuelva el
   array mock confirmado y respete los filtros acordados. No inventar endpoints
   ni realizar HTTP. Mantener intactas operaciones existentes ajenas al piloto.
2. Completar el contexto o hook local: datos, carga, error, acciones y estado
   compartido necesarios. Consumir la promesa con manejo de error y finalizacion
   de carga; no introducir una segunda fuente contradictoria de estado.
3. Crear el Panel Container y sus controles con callbacks reales de pantalla.
4. Crear Table Container y tabla local si se necesitan ambos; adaptar los
   registros de dominio al contrato de la tabla comun elegida.
5. Crear Action Bar y Modal locales cuando el requerimiento los necesite.
   Conectar habilitacion, apertura, aceptar y cancelar. Una edicion mock solo
   modifica estado local; no afirmar persistencia en backend. Para campos
   controlados, seguir el patron de la referencia del Modal y capturar el
   valor del evento antes de llamar a un actualizador funcional.
6. Conectar las piezas al componente principal bajo su proveedor existente.
   Preservar props/contexto recibidos desde la aplicacion y convenciones locales.

Despues de cada cambio significativo, ejecutar la comprobacion acotada
disponible antes de seguir. No dejar imports rotos entre pasos. Reutilizar
helpers y estilos existentes; calcular imports desde cada archivo real.
Crear solo carpetas y abstracciones que la pantalla necesite.

Al terminar cada archivo editado, comprobar que tenga una sola declaracion del
componente esperado, un solo `export default`, imports al inicio y ningun
bloque duplicado o concatenado despues del export. Ejecutar diagnosticos del
archivo antes de editar el siguiente; corregir ahi mismo cualquier error.

## 5. Verificar y reportar

- Validar imports, sintaxis y diagnosticos de archivos tocados con las
  herramientas y comandos disponibles del repo. No instalar dependencias
  adicionales para este piloto sin justificar y confirmar la necesidad.
- Antes de ejecutar un comando en terminal, explicar el comando exacto, el shell,
   que valida y si crea o modifica archivos. Por ejemplo, `npm run build-js`
   compila la app y genera artefactos en `build/`; no es una prueba visual ni un
   despliegue. Pedir aprobacion antes de comandos que escriban artefactos o
   levanten procesos. Si el dev omite una comprobacion, no volver a solicitarla:
   continuar con diagnosticos disponibles y reportar que quedo sin verificar.
- Verificar que los registros mock llegan del servicio al contexto y a la
  tabla, y que carga, vacio y errores tienen un tratamiento apropiado.
- Probar las interacciones acordadas con tests existentes o en navegador si
  la pantalla ya tiene una ruta y el ambiente lo permite. Aceptar/cancelar
   deben producir los efectos establecidos por el requerimiento. En el modal,
   escribir varios caracteres en al menos un campo y comprobar que el valor
   permanece antes de aceptar o cancelar.
- Si no hay ruta integrada, acordar una prueba de renderizado o reportar
  explicitamente la falta de validacion visual. No crear rutas temporales.
- Informar archivos creados/modificados, componentes comunes reutilizados,
  datos mock, comprobaciones ejecutadas y pasos no verificados. No confundir
  compilacion con prueba de interaccion ni mock con un GET real.

## Limites

No modificar `init-frontend-module`, componentes compartidos, `roles.js`, menu
ni el modulo raiz de rutas. Conservar la integracion previa del modulo si
existe. No obtener documentos de servicios externos ni implementar backend.
No ejecutar todas las fases futuras: este alcance prueba composicion local.