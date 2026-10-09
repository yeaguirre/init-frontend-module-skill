# Panel Container

## Proposito

Patron de contenedor local, no componente global para importar. Crear la pieza
de la pantalla que compone controles y conecta sus acciones al contexto/hook.
Ejemplo real: `src/medi/CalidadGas/DatosCalidadGas/components/containers/PanelContainer.jsx`.
Ese ejemplo usa `MediCommonAC`, `CommonDatePicker`, `CommonListarButton` y
contexto propio; no copiar sus reglas de negocio al piloto.

## Props

No hay una API universal. Definir las props locales segun el requerimiento,
o consumir el contexto de pantalla. El ejemplo real recibe `history`,
`realActiveTab` y `onActiveTabChange`; no son requisitos para un panel nuevo.

## Ejemplo minimo

```jsx
import React from 'react';
import { Button, Grid } from '@material-ui/core';

const PanelContainer = ({ onListar, loading }) => (
    <Grid container>
        <Button onClick={onListar} disabled={loading}>Listar</Button>
    </Grid>
);

export default PanelContainer;
```

Este ejemplo ilustra el patron; los filtros reales y sus componentes se
eligen leyendo el requerimiento y verificando sus implementaciones.

## Default para filtros no especificados

Si el requerimiento pide un panel de filtros y ya define columnas de datos,
usar un filtro local de texto por inclusion, sin distinguir mayusculas o
minusculas, para cada campo de datos; no filtrar por columnas de acciones.
Agregar un control para limpiar los filtros. Informar este supuesto al dev en
la confirmacion. Preguntar solo si el requerimiento necesita reglas distintas,
como rangos de fechas, normalizacion especial o consulta remota.

## Composicion interna (no necesitas consultarlos)

- `Grid` de Material UI: distribucion de los controles del ejemplo minimo.

## Componentes relacionados (consulta estas referencias)

- [Tabla](./tabla.md): recibe el resultado de la consulta iniciada desde el panel.
- [Modal](./modal.md): si la accion requiere confirmacion o presenta un dialogo.

## Cuando NO usarlo

- No importar un PanelContainer de otra pantalla que dependa de su contexto.
- No incluir operaciones HTTP o configuracion de columnas solo por proximidad;
  mantener responsabilidades en servicio y tabla locales.