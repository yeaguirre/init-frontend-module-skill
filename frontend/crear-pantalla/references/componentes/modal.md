# CommonDialog y modal local

## Proposito

`src/components/CommonDialog.jsx` exporta por defecto `CommonDialog`. Usarlo
para componer el contenido y acciones de un modal local. Este piloto documenta
su uso directo; no necesita crear otro hook useModal.

## Props

Contrato minimo verificado para el piloto; no es el listado exhaustivo.
Tipos inferidos del consumo, ya que el componente no declara tipos.

| Prop | Tipo | Requerido | Descripcion |
|------|------|-----------|-------------|
| open | boolean | Si | Control de apertura del Dialog. |
| children | ReactNode | Para contenido propio | Cuerpo proporcionado por la pantalla. |
| title | ReactNode | No | Titulo condicional. |
| onClose | function | Segun cierre previsto | Callback reenviado al Dialog. |
| onClickAceptar | function | Si se ofrece Aceptar | Accion del boton; no cierra automaticamente. |
| onClickCancelar | function | Si se ofrece Cancelar | Accion del boton; no cierra automaticamente. |
| disabledAceptar | boolean | No | Deshabilita Aceptar. |
| disabledCancelar | boolean | No | Deshabilita Cancelar. |
| aceptarText | string | No | Texto; por defecto Aceptar. |
| cancelarText | string | No | Texto; por defecto Cancelar. |
| noAceptar | boolean | No | Oculta Aceptar. |
| noCancelar | boolean | No | Oculta Cancelar. |
| hideIcon | boolean | No | Omite el img interno; usar si no se proporciona icono. |
| fullWidth | boolean | No | Ancho completo; por defecto false. |
| maxWidth | string | No | Limite de ancho del Dialog; por defecto lg. |

## Ejemplo minimo

```jsx
<CommonDialog
    open={open}
    title="Editar registro"
    hideIcon
    onClose={onCancelar}
    onClickAceptar={onAceptar}
    onClickCancelar={onCancelar}
>
    <TextField value={nombre} onChange={event => setNombre(event.target.value)} />
</CommonDialog>
```

Los callbacks y estado pertenecen a la pantalla. Mantener un borrador para
que Cancelar no modifique el registro original. Usar imports calculados desde
el archivo local; TextField pertenece a Material UI.

## Campos controlados y estado de formulario

Este proyecto usa React 16 (confirmar la version vigente en `package.json`).
Al actualizar un objeto de estado desde `onChange`, leer `event.target.value`
sincronicamente en el manejador y pasar el valor al actualizador. No acceder a
`event.target` dentro de la funcion del actualizador: React 16 recicla los
eventos sinteticos al finalizar el manejador.

```jsx
const handleChange = field => event => {
  const value = event.target.value;

  setFormValues(currentValues => ({
    ...currentValues,
    [field]: value
  }));
};
```

## Composicion interna (no necesitas consultarlos)

- `Dialog`, `DialogTitle`, `DialogContent` y `DialogContentText` de Material UI:
  estructura del dialogo.
- `DialogActions` y `Button` de Material UI: acciones Aceptar/Cancelar.
- `img`: icono opcional, omitido mediante hideIcon.

## Componentes relacionados (consulta estas referencias)

- [Action Bar](./action-bar.md): si una accion externa abre el modal.
- [Tabla](./tabla.md): si se edita un registro mostrado en ella.

## Cuando NO usarlo

- No asumir que incluye CommonActionBar ni que gestiona el estado open.
- No asumir que disableBackdropClick=false habilita cierre por fondo: la
  implementacion actual usa `props.disableBackdropClick || true`.
- No copiar un hook useModal sin verificar su ruta y callbacks; hay variantes
  en `src/medi/components` y `src/components/hooks`.