Param()

# 1) Ruta del proyecto
$projectPath = Read-Host "Ingrese la ruta del proyecto (p.ej. C:\Repositorios\etgs-ui\src\medi)"

# 2) Categoría SPAC o MEDI
do {
    $category = Read-Host "¿La carpeta es de SPAC o de MEDI? (SPAC/MEDI)"
} until ($category -match '^(?i:SPAC|MEDI)$')
$category = $category.ToUpper()

# 3) Carpeta (camelCase)
if ($category -eq 'SPAC') {
    $folderName = Read-Host "Nombre carpeta SPAC (p.ej. Control)"
} else {
    $folderName = Read-Host "Nombre carpeta MEDI (p.ej. CalidadGas)"
}

# Validar existencia
$folderPath = Join-Path $projectPath $folderName
if (-not (Test-Path $folderPath)) {
    Write-Host "La carpeta '$folderName' no existe en '$projectPath'" -ForegroundColor Yellow
    do {
        $createFolder = Read-Host "¿Desea crear la carpeta? (S/N)"
    } until ($createFolder -match '^(?i:S|N|SI|NO)$')
    
    if ($createFolder -match '^(?i:S|SI)$') {
        try {
            New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
            Write-Host "Carpeta '$folderName' creada exitosamente en '$projectPath'" -ForegroundColor Green
        }
        catch {
            Write-Host "Error al crear la carpeta: $($_.Exception.Message)" -ForegroundColor Red
            Read-Host -Prompt "Presione Enter para cerrar..."
            exit 1
        }
    } else {
        Write-Host "Operación cancelada por el usuario." -ForegroundColor Red
        Read-Host -Prompt "Presione Enter para cerrar..."
        exit 1
    }
}

# 4) Nombre del módulo
$moduleName = Read-Host "Nombre del nuevo módulo (p.ej. CalculoCombustible)"

# 5) Crear estructura de carpetas
$modDir = Join-Path $folderPath $moduleName
New-Item -ItemType Directory -Path $modDir -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'components') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'hooks') -Force | Out-Null

# Subcarpetas dentro de components
New-Item -ItemType Directory -Path (Join-Path $modDir 'components\buttons') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'components\combos') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'components\modals') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'components\tables') -Force | Out-Null

# 6) Contenido JSX del componente principal
$jsxContent = @"
import React from 'react';
import StateProvider from './Context';
import CommonHeader from '../../../components/CommonHeader';
import moment from 'moment';

const $moduleName = (props) => {
    const { roles, fechaMinima, fechaMaxima } = props.context;

    return (
        <StateProvider
            roles={roles}
            fechaMinima={moment(fechaMinima)}
            fechaMaxima={moment(fechaMaxima)}
            props={props}
        >
            <CommonHeader navPath={['$category','$folderName','$moduleName']} />
            Hello From $moduleName
        </StateProvider>
    );
};

export default $moduleName;
"@

$jsxPath = Join-Path $modDir "$moduleName.jsx"
Set-Content -Path $jsxPath -Value $jsxContent -Encoding UTF8

# 7) Context.jsx
$ctxContent = @"
import React from 'react';

export const StateContext = React.createContext();

const StateProvider = ({children, roles, fechaMinima, fechaMaxima}) => {

    return (
        <StateContext.Provider value={{
            // aquí tus exports
        }}>
            {children}
        </StateContext.Provider>
    );
};

export default StateProvider;
"@
$ctxPath = Join-Path $modDir 'Context.jsx'
Set-Content -Path $ctxPath -Value $ctxContent -Encoding UTF8

# 8) Service.js
$svcContent = @"
import axios from './../../../common/Axios';

export default {
    // aquí tus exports
};
"@
$svcPath = Join-Path $modDir 'Service.js'
Set-Content -Path $svcPath -Value $svcContent -Encoding UTF8

Write-Host "Módulo '$moduleName' creado en '$modDir' ✅"
Read-Host -Prompt "Presione Enter para cerrar..."
