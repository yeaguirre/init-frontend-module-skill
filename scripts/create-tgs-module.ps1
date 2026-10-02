param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,

    [Parameter(Mandatory=$true)]
    [ValidateSet('SPAC','MEDI')]
    [string]$Category,

    [Parameter(Mandatory=$true)]
    [string]$FolderName,

    [Parameter(Mandatory=$true)]
    [string]$ModuleName,

    [switch]$Integrate,

    [string]$RoutePath,

    [string]$MenuKey,

    [string]$MenuLabel,

    [string[]]$Roles
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $ProjectPath)) {
    Write-Error "La ruta del proyecto no existe: $ProjectPath"
    exit 1
}

$Category = $Category.ToUpper()
$projectPathResolved = (Resolve-Path $ProjectPath).Path
$moduleNameKey = [regex]::Replace($ModuleName, '[^A-Za-z0-9]', '_').Trim('_').ToUpper()
$folderSegments = if ([string]::IsNullOrWhiteSpace($FolderName)) { 0 } else { @($FolderName -split '[/\\]' | Where-Object { $_ }).Count }

function Get-RelativePrefix {
    param([int]$Levels)

    $prefix = ''
    for ($index = 0; $index -lt $Levels; $index++) {
        $prefix += '../'
    }
    return $prefix
}

function ConvertTo-RouteSegment {
    param([string]$Value)

    return ([regex]::Replace($Value.Trim().ToLowerInvariant(), '[^a-z0-9]+', '-')).Trim('-')
}

function Read-Utf8File {
    param([string]$Path)

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $hasUtf8Bom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
    $byteOffset = if ($hasUtf8Bom) { 3 } else { 0 }
    $encoding = [System.Text.UTF8Encoding]::new($hasUtf8Bom)
    $content = [System.Text.UTF8Encoding]::new($false).GetString($bytes, $byteOffset, $bytes.Length - $byteOffset)

    return [pscustomobject]@{
        Content = $content
        Encoding = $encoding
    }
}

function Write-Utf8File {
    param(
        [string]$Path,
        [string]$Content,
        [System.Text.Encoding]$Encoding
    )

    [System.IO.File]::WriteAllText($Path, $Content, $Encoding)
}

# --- Validación de colisión: NUNCA sobreescribir ---
$modDir = Join-Path (Join-Path $ProjectPath $FolderName) $ModuleName
if (Test-Path $modDir) {
    $hasContent = (Get-ChildItem -Path $modDir -Force | Measure-Object).Count -gt 0
    if ($hasContent) {
        Write-Error "Ya existe un módulo con ese nombre en esa ruta y tiene archivos: $modDir. No se sobreescribe. Elegí otro nombre para la nueva pantalla, u otra carpeta destino."
    }
    else {
        Write-Error "Ya existe una carpeta con ese nombre en esa ruta (está vacía): $modDir. Borrala manualmente si querés crear el módulo acá, o elegí otro nombre."
    }
    exit 1
}
# --- fin validación de colisión ---

# --- Validación de integración + hash de roles.js ---
$rolesHashBefore = $null
if ($Integrate) {
    if ([string]::IsNullOrWhiteSpace($RoutePath)) {
        $routeSegments = @($FolderName -split '[/\\]' | Where-Object { $_ } | ForEach-Object { ConvertTo-RouteSegment $_ })
        $routePath = '/' + $Category.ToLowerInvariant() + '/' + (($routeSegments + (ConvertTo-RouteSegment $ModuleName)) -join '/')
    }

    if ([string]::IsNullOrWhiteSpace($MenuKey)) {
        $MenuKey = $moduleNameKey
    }

    if ([string]::IsNullOrWhiteSpace($MenuLabel)) {
        $MenuLabel = (($FolderName -replace '[/\\]', ' > ') + ' > ' + $ModuleName).Trim(' ', '>')
    }

    $roleNames = @($Roles | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Select-Object -Unique)
    if ($roleNames.Count -eq 0) {
        throw 'Indicá al menos un rol existente con -Roles. El generador no crea ni modifica roles.'
    }

    foreach ($roleName in $roleNames) {
        if ($roleName -notmatch '^[A-Za-z_$][A-Za-z0-9_$]*$') {
            throw "El nombre de rol no es un identificador válido: $roleName"
        }
    }

    $repoRoot = Split-Path -Parent (Split-Path -Parent $projectPathResolved)
    $rolesPath = Join-Path $repoRoot 'src\common\roles.js'
    $menuPath = Join-Path $repoRoot 'src\common\constants\menu-module.jsx'
    $rootModulePath = Join-Path $projectPathResolved 'Module.jsx'

    foreach ($requiredPath in @($rolesPath, $menuPath, $rootModulePath)) {
        if (-not (Test-Path $requiredPath)) {
            throw "No se encontro el archivo requerido para integrar el modulo: $requiredPath"
        }
    }

    $rolesContent = (Read-Utf8File -Path $rolesPath).Content
    foreach ($roleName in $roleNames) {
        $rolePattern = '(?m)^\s*export\s+const\s+' + [regex]::Escape($roleName) + '\s*='
        if (-not [regex]::IsMatch($rolesContent, $rolePattern)) {
            throw "El rol '$roleName' no existe en src/common/roles.js. Agregalo manualmente y volve a ejecutar la skill."
        }
    }

    # Hash de roles.js antes de cualquier modificación
    $rolesHashBefore = (Get-FileHash -Path $rolesPath -Algorithm SHA256).Hash
}
# --- fin validación de integración ---

# --- Creación de estructura ---
$folderPath = Join-Path $ProjectPath $FolderName
if (-not (Test-Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
    Write-Host "Carpeta '$FolderName' creada en '$ProjectPath'" -ForegroundColor Green
}

New-Item -ItemType Directory -Path $modDir -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'components') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'hooks') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'components\buttons') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'components\combos') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'components\modals') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'components\tables') -Force | Out-Null

$sharedImportPrefix = Get-RelativePrefix ($folderSegments + 2)

$jsxContent = @"
import React from 'react';
import StateProvider from './Context';
import CommonHeader from '${sharedImportPrefix}components/CommonHeader';
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

$svcContent = @"
import axios from '${sharedImportPrefix}common/Axios';

export default {
    // aquí tus exports
};
"@
Set-Content -Path (Join-Path $modDir 'Service.js') -Value $svcContent -Encoding UTF8

Write-Host "Módulo '$ModuleName' creado en '$modDir'" -ForegroundColor Green

# --- Integración ---
if ($Integrate) {
    $menuName = "MENU_$Category"
    $menuFile = Read-Utf8File -Path $menuPath
    $menuContent = $menuFile.Content
    $menuNewline = if ($menuContent.Contains("`r`n")) { "`r`n" } else { "`n" }
    $menuMatch = [regex]::Match($menuContent, "(?s)(export const $menuName = \{.*?)(\r?\n\})")
    if (-not $menuMatch.Success) {
        throw "No se encontro el bloque $menuName en $menuPath"
    }
    $menuBlock = $menuMatch.Value
    if (-not [regex]::IsMatch($menuBlock, "(?m)^\s*$([regex]::Escape($MenuKey))\s*:")) {
        $escapedMenuLabel = $MenuLabel.Replace("'", "\'")
        $newMenuBlock = $menuMatch.Groups[1].Value + $menuNewline + "    ${MenuKey}: '$escapedMenuLabel'," + $menuMatch.Groups[2].Value
        $menuContent = $menuContent.Remove($menuMatch.Index, $menuMatch.Length).Insert($menuMatch.Index, $newMenuBlock)
        Write-Utf8File -Path $menuPath -Content $menuContent -Encoding $menuFile.Encoding
    }

    $moduleFile = Read-Utf8File -Path $rootModulePath
    $moduleContent = $moduleFile.Content
    $componentPath = $FolderName.Replace('\', '/') + "/$ModuleName/$ModuleName"
    $componentImport = 'import ' + $ModuleName + ' from "./' + $componentPath + '";'
    $newline = if ($moduleContent.Contains("`r`n")) { "`r`n" } else { "`n" }
    $componentImportPattern = '(?m)^import\s+' + [regex]::Escape($ModuleName) + '\s+from\s+[^;]+;\r?\n?'
    $moduleContent = [regex]::Replace($moduleContent, $componentImportPattern, '')

    $rolesImportMatch = [regex]::Match($moduleContent, '(?s)import \{.*?\} from "\.\./common/roles";')
    if (-not $rolesImportMatch.Success) {
        throw "No se encontro el import de roles en $rootModulePath"
    }
    $rolesImport = $rolesImportMatch.Value
    $missingRoles = @()
    foreach ($roleName in $roleNames) {
        if ($rolesImport -notmatch "\b$([regex]::Escape($roleName))\b") {
            $missingRoles += $roleName
        }
    }
    if ($missingRoles.Count -gt 0) {
        $closingBrace = $rolesImport.LastIndexOf('}')
        $rolesImportBody = $rolesImport.Substring(0, $closingBrace).TrimEnd("`r", "`n", ' ', "`t")
        $rolesImportBody = $rolesImportBody.TrimEnd(',') + ',' + $newline
        $rolesImportBody += (($missingRoles | ForEach-Object { "    $_" }) -join ",$newline") + $newline
        $rolesImport = $rolesImportBody + $rolesImport.Substring($closingBrace)
    }
    $moduleContent = $moduleContent.Remove($rolesImportMatch.Index, $rolesImportMatch.Length).Insert($rolesImportMatch.Index, $rolesImport)

    $importAnchor = if ($Category -eq 'MEDI') {
        $moduleContent.IndexOf('// Se declara una sola vez fuera de renderModule')
    }
    else {
        $moduleContent.IndexOf('class Module')
    }
    if ($importAnchor -lt 0) {
        throw "No se encontro el final esperado del bloque de imports en $rootModulePath"
    }
    $moduleContent = $moduleContent.Insert($importAnchor, $componentImport + $newline)

    $menuReference = "$menuName.$MenuKey"
    $rolesExpression = ($roleNames -join ', ')
    $routeComponent = "withActivityLog($ModuleName, MODULES.$Category, $menuReference)"
    $routeBlock = @"
            <RouteProtected exact path="$RoutePath"
                            roles={[$rolesExpression]}
                            component={$routeComponent}/>
"@
    $routePattern = '(?m)path="' + [regex]::Escape($RoutePath) + '"'
    $existingRoute = [regex]::Match($moduleContent, $routePattern)
    if ($existingRoute.Success) {
        $routeStart = $moduleContent.LastIndexOf('<RouteProtected', $existingRoute.Index)
        $routeEnd = $moduleContent.IndexOf('/>', $existingRoute.Index)
        $routeSnippet = if ($routeStart -ge 0 -and $routeEnd -ge $routeStart) {
            $moduleContent.Substring($routeStart, $routeEnd - $routeStart + 2)
        } else {
            ''
        }
        if ($routeSnippet -notmatch [regex]::Escape($ModuleName)) {
            throw "La ruta '$RoutePath' ya esta registrada para otro componente en $rootModulePath"
        }
    }
    else {
        $closingFragment = "        </>"
        $closingIndex = $moduleContent.IndexOf($closingFragment)
        if ($closingIndex -lt 0) {
            throw "No se encontro el cierre del bloque de rutas en $rootModulePath"
        }
        $moduleContent = $moduleContent.Insert($closingIndex, $routeBlock)
    }

    Write-Utf8File -Path $rootModulePath -Content $moduleContent -Encoding $moduleFile.Encoding
    Write-Host "Integracion agregada en menu y $rootModulePath. Los roles se validaron sin modificar roles.js." -ForegroundColor Green

    # --- Verificación de integridad de roles.js ---
    $rolesHashAfter = (Get-FileHash -Path $rolesPath -Algorithm SHA256).Hash
    if ($rolesHashBefore -ne $rolesHashAfter) {
        Write-Error "roles.js fue modificado durante la ejecucion. Esto no deberia pasar. Revisa el archivo manualmente."
        exit 1
    }
}
