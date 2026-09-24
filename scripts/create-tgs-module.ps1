
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,

    [Parameter(Mandatory=$true)]
    [ValidateSet('SPAC','MEDI')]
    [string]$Category,

    [Parameter(Mandatory=$true)]
    [string]$FolderName,

    [Parameter(Mandatory=$true)]
    [string]$ModuleName
)

# Validar que la ruta base existe
if (-not (Test-Path $ProjectPath)) {
    Write-Error "La ruta del proyecto no existe: $ProjectPath"
    exit 1
}

# Normalizar categoría
$Category = $Category.ToUpper()

# Crear carpeta padre si no existe
$folderPath = Join-Path $ProjectPath $FolderName
if (-not (Test-Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
    Write-Host "Carpeta '$FolderName' creada en '$ProjectPath'" -ForegroundColor Green
}

# Crear estructura del módulo
$modDir = Join-Path $folderPath $ModuleName
New-Item -ItemType Directory -Path $modDir -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'components') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'hooks') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'components\buttons') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'components\combos') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'components\modals') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'components\tables') -Force | Out-Null

# Generar ModuleName.jsx
$jsxContent = @"
import React from 'react';
import StateProvider from './Context';
import CommonHeader from '../../../components/CommonHeader';
import moment from 'moment';

const $ModuleName = (props) => {
    const { roles, fechaMinima, fechaMaxima } = props.context;

    return (
        <StateProvider
            roles={roles}
            fechaMinima={moment(fechaMinima)}
            fechaMaxima={moment(fechaMaxima)}
            props={props}
        >
            <CommonHeader navPath={['$Category','$FolderName','$ModuleName']} />
            Hello From $ModuleName
        </StateProvider>
    );
};

export default $ModuleName;
"@
Set-Content -Path (Join-Path $modDir "$ModuleName.jsx") -Value $jsxContent -Encoding UTF8

# Generar Context.jsx
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
Set-Content -Path (Join-Path $modDir 'Context.jsx') -Value $ctxContent -Encoding UTF8

# Generar Service.js
$svcContent = @"
import axios from './../../../common/Axios';

export default {
    // aquí tus exports
};
"@
Set-Content -Path (Join-Path $modDir 'Service.js') -Value $svcContent -Encoding UTF8

Write-Host "Módulo '$ModuleName' creado en '$modDir'" -ForegroundColor Green
