# Regenera el cliente de la API (packages/memories_api) desde el OpenAPI del
# backend (D57, D79). El cliente generado no se edita a mano: si la API cambia,
# se corre este script y se sube el resultado.
#
# Requisitos: Docker Desktop abierto, el backend levantado (docker compose up)
# y Flutter en el PATH.
#
# Uso, desde la raíz del repo:
#   powershell -ExecutionPolicy Bypass -File packages/generate_memories_api.ps1

param(
    # Docker llega a la API de tu PC por host.docker.internal, no por localhost.
    [string]$SpecUrl = 'http://host.docker.internal:8001/openapi.json'
)

$ErrorActionPreference = 'Stop'

# Versión fija: todo el equipo genera el mismo código.
$GeneratorImage = 'openapitools/openapi-generator-cli:v7.27.0'
$PackageName = 'memories_api'
$PackagesDir = $PSScriptRoot
$PackageDir = Join-Path $PackagesDir $PackageName

function Invoke-Step([string]$Description, [scriptblock]$Command) {
    Write-Host "==> $Description"
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "Falló: $Description (código $LASTEXITCODE)"
    }
}

$LockFile = Join-Path $PackageDir 'pubspec.lock'
$SavedLock = $null

# El pubspec.lock fija las versiones de build_runner y built_value_generator:
# se conserva para que regenerar otro día dé el mismo código.
if (Test-Path $LockFile) {
    $SavedLock = [System.IO.File]::ReadAllBytes($LockFile)
}

# Se borra entero para que no queden archivos de endpoints que ya no existen.
if (Test-Path $PackageDir) {
    Remove-Item -Recurse -Force $PackageDir
}

Invoke-Step 'Generando el cliente con openapi-generator' {
    docker run --rm -v "${PackagesDir}:/local" $GeneratorImage generate `
        -i $SpecUrl `
        -g dart-dio `
        -o "/local/$PackageName" `
        --global-property 'apiTests=false,modelTests=false' `
        --additional-properties "pubName=$PackageName,pubPublishTo=none,pubHomepage=https://github.com/ProyectoMemories/memories-frontend,pubDescription=Cliente de la API de Memories generado desde OpenAPI. No se edita a mano."
}

if ($null -ne $SavedLock) {
    [System.IO.File]::WriteAllBytes($LockFile, $SavedLock)
}

Push-Location $PackageDir
try {
    # Sin lock guardado (primera vez) resuelve las versiones y crea uno nuevo.
    Invoke-Step 'Instalando las dependencias del paquete' { flutter pub get }
    # built_value necesita los archivos .g.dart; se suben al repo para que el
    # CI compile sin correr build_runner.
    Invoke-Step 'Generando los serializadores (build_runner)' {
        dart run build_runner build --delete-conflicting-outputs
    }
    # El CI revisa el formato de todo el repo, también del paquete generado.
    Invoke-Step 'Formateando el código generado' { dart format . }
}
finally {
    Pop-Location
}

Write-Host "Listo: $PackageDir. Revisa el diff antes de hacer commit."
