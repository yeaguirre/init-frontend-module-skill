# init-frontend-module

Skill para crear modulos frontend TGS de categoria MEDI o SPAC. Puede generar
la estructura base y, con `-Integrate`, registrar menu, import, roles y ruta
protegida.

## Archivos

- [Instrucciones de la skill](SKILL.md): flujo interactivo y uso del generador.
- [Script](scripts/create-tgs-module.ps1): creacion e integracion del modulo.
- [Estado del flujo de anidamiento](ANALISIS_FLUJO_ANIDAMIENTO.md): comportamiento actual y limites.
- [Estado y alcance de integracion](FASE_SIGUIENTE_INTEGRACION_MODULO.md): capacidades presentes y requisitos pendientes.

## Limites actuales

- Un destino que ya existe provoca un error, incluso si esta vacio. El script
	no tiene `-Force` ni sobrescribe modulos.
- La integracion requiere uno o mas roles ya definidos en `src/common/roles.js`;
	ese archivo no se modifica.
- El tratamiento de registros existentes no reconcilia valores de menu o
	`RouteProtected`; consulta el documento de estado para los detalles.
- Si falla una etapa de integracion, el script no revierte las etapas previas.

