# MediCommonTable y tabla local

## Proposito

`src/medi/mediComponents/MediCommonTable.jsx` exporta por defecto
`MediCommonTable`. Es una opcion presente en muchas pantallas MEDI. La tabla
local define columnas y adapta registros; el contexto/hook consulta el
servicio y TableContainer conecta datos y callbacks cuando sea necesario.

## Props

Contrato minimo verificado del piloto, no API exhaustiva. Tipos inferidos.

| Prop | Tipo | Requerido | Descripcion |
|------|------|-----------|-------------|
| columns | Array de objetos | Si | Headers con label y key; admite style y sortable. |
| data | Array de objetos | Si | Celdas como `{ value, style? }`, en orden de columnas. |
| disableSort | boolean | No | Desactiva ordenamiento interno y controles de orden. |
| sortColumn | boolean | No | Evita ordenar internamente el body; no oculta controles de headers. |
| order | function(col, sort) | No | Callback cuando se pide ordenar una columna. |
| pagination | object | No | count, rowsPerPage y onChangePage(event, newPage). No corta data. |
| className | string | No | Clase externa; su presencia activa modo compacto. |
| paperClassName | string | No | Clase del Paper interno; defecto tables. |
| style | object | No | Estilo del Paper interno. |

`Object.values(row.data || row)` determina el orden de celdas. No agregar id
o metadatos al mismo nivel de celdas: se renderizarian como columnas extras.
Mantener el registro original y su identificador en estado de dominio.

## Ejemplo minimo

```jsx
const columns = [
    { label: 'Nombre', key: 'nombre' },
    { label: 'Estado', key: 'estado' }
];

const data = registros.map(registro => ({
    nombre: { value: registro.nombre },
    estado: { value: registro.estado }
}));

<MediCommonTable columns={columns} data={data} disableSort />
```

Importar MediCommonTable desde su ruta real. El servicio mock devuelve
registros de dominio; la transformacion vive en la tabla local. Para estilos
locales usar el makeStyles existente y las props realmente consumidas.

## Responsabilidades locales

Cuando la pantalla separa `TableContainer` y tabla local, mantener un solo
renderizado de tabla: el contenedor consume el contexto, muestra carga/error/
vacio y conecta callbacks; la tabla local adapta registros y define columnas.
No duplicar la implementacion de la tabla en ambos archivos. Si el contenedor
resuelve el estado vacio y retorna un mensaje, no renderizar ademas otra tabla
vacia salvo que el requerimiento pida conservar sus encabezados.

## Composicion interna (no necesitas consultarlos)

- `MediCommonTableHead`: headers y controles de orden.
- `MediCommonPaper`: envoltorio y controles de paginacion opcionales.
- `Table`, `TableBody`, `TableRow`, `TableCell`, `Paper`: estructura Material UI.
- `CommonSearch`: control opcional de busqueda.
- `CommonDialog`: alerta interna de busqueda sin resultados.

## Componentes relacionados (consulta estas referencias)

- [Panel Container](./panel-container.md): controles que disparan la consulta.
- [Action Bar](./action-bar.md): acciones sobre los registros de pantalla.
- [Modal](./modal.md): edicion o detalle cuando el requerimiento lo pide.

## Cuando NO usarlo

- No pasar objetos de dominio sin adaptar las celdas a value.
- No asumir seleccion incorporada: componer un control/callback explicito
  si el requerimiento necesita seleccionar registros.
- No asumir que paginacion recorta registros: pasar la pagina calculada y
  total correcto si se habilita; para el piloto simple omitirla.
- No activar filtros por el icono filter: su handler actual esta vacio.
- No prometer busqueda correcta sobre celdas value: searcher recorre valores
  string/number directos del row. Omitir search en el piloto minimo.
- No intercambiar con CommonTable o variantes SPAC sin revisar contratos.