# Servicio mock asincrono del piloto

## Contrato

Usar el `Service.js` local existente para exponer una funcion equivalente a
obtener registros. Devuelve `Promise<Array<Registro>>`, sin Axios, endpoint,
latencia artificial ni llamada HTTP. La firma y campos deben responder al
requerimiento confirmado, no a este ejemplo ilustrativo.

```js
const registrosMock = [
    { id: 1, nombre: 'Registro A', estado: 'Activo' },
    { id: 2, nombre: 'Registro B', estado: 'Inactivo' }
];

const getRegistros = async ({ estado } = {}) => {
    const registros = estado
        ? registrosMock.filter(registro => registro.estado === estado)
        : registrosMock;
    return registros.map(registro => ({ ...registro }));
};

export default { getRegistros };
```

Si el servicio ya tiene exports, incorporar la operacion sin reemplazarlos.
Copiar los registros evita modificar accidentalmente el fixture; si contienen
objetos anidados, adaptar la copia a ese contrato.

## Consumo

El contexto/hook local espera la promesa, guarda registros de dominio y maneja
carga, error y finalizacion con `try/catch/finally`. Al iniciar otra carga,
limpiar el error anterior. No llamar servicios durante render ni dejar
promesas rechazadas sin tratamiento.

Definir segun el requerimiento si Listar ejecuta la consulta o si la pantalla
carga al montar. No implementar ambos por defecto. Si hay solicitudes
concurrentes o desmontaje, aplicar la proteccion local adecuada.

La [tabla](./componentes/tabla.md) adapta registros para renderizado. No guardar
elementos JSX en el fixture ni acoplar el servicio al formato de celdas.

Una edicion mock modifica el estado local de pantalla y puede perderse al
volver a listar o recargar; confirmar esa semantica y reportarla. No simular
persistencia, POST o PUT sin requerimiento.

## Sustitucion futura

El dev proporcionara endpoint, parametros, respuesta y errores del GET real.
Si se conserva la firma y el retorno normalizado, la sustitucion puede
concentrarse en el servicio. No prometerlo si cambia el contrato.

Comprobar respuesta con y sin filtros, array vacio, forma de registros y
propagacion de errores al consumidor. Un mock exitoso no prueba la red.