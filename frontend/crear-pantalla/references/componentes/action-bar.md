# CommonActionBar y ActionBarContainer

## Proposito

`src/components/CommonActionBar.jsx` exporta por defecto `CommonActionBar`,
un wrapper visual. ActionBarContainer es una pieza local que compone botones
y conecta callbacks/estado al contexto de la pantalla.

## Props

| Prop | Tipo | Requerido | Descripcion |
|------|------|-----------|-------------|
| children | ReactNode (inferido) | Para mostrar controles | Contenido que renderiza el wrapper. |

La implementacion solo consume `children`; no reenvia `className`, `style`
ni callbacks del wrapper. Las props del contenedor local se definen aparte.

## Ejemplo minimo

```jsx
<CommonActionBar>
    <Button onClick={onEditar} disabled={!seleccion}>Editar</Button>
</CommonActionBar>
```

Importar el wrapper desde su ruta real y Button desde Material UI. El
consumidor proporciona `onEditar` y `seleccion`, o los obtiene del contexto.

## Composicion interna (no necesitas consultarlos)

- `Grid` de Material UI: alinea hijos a la derecha con clase `actionBars`.

## Componentes relacionados (consulta estas referencias)

- [Tabla](./tabla.md): si una accion opera sobre un registro seleccionado.
- [Modal](./modal.md): si la accion abre un formulario o confirmacion.

## Cuando NO usarlo

- No esperar que implemente permisos, seleccion o persistencia.
- No usarlo como sustituto de las acciones internas de CommonDialog por defecto.