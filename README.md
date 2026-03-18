# 🗄️ ABD2026 — Sistema de Automatización de Bases de Datos

Sistema de sincronización automática de bases de datos SQL Server mediante Git y Git LFS. Permite trabajar en múltiples PCs manteniendo las bases de datos siempre actualizadas sin intervención manual.

---

## 📋 Tabla de Contenidos

- [¿Cómo funciona?](#cómo-funciona)
- [Requisitos](#requisitos)
- [Instalación en una PC nueva](#instalación-en-una-pc-nueva)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Archivos importantes](#archivos-importantes)
- [Uso diario](#uso-diario)
- [Solución de problemas](#solución-de-problemas)

---

## ¿Cómo funciona?

```
┌─────────────────────────────────────────────────────────┐
│                     FLUJO COMPLETO                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  PC 1                          PC 2                     │
│  ─────                         ─────                    │
│  1. Modificas una BD           5. git pull              │
│  2. git add + git commit    ←──── baja el .bak          │
│  3. hook pre-commit activa        6. post-merge activa  │
│  4. backup.ps1 genera .bak        7. Restaura BD en     │
│     y lo sube via LFS                SQL Server         │
│  5. git push                                            │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Componentes del sistema

| Componente | Función |
|---|---|
| `git-hooks/pre-commit` | Se ejecuta antes de cada commit. Llama al backup.ps1 |
| `git-hooks/backup.ps1` | Detecta qué BDs cambiaron y genera solo sus `.bak` |
| `git-hooks/post-merge` | Se ejecuta después de cada `git pull` con cambios. Restaura las BDs |
| `git-hooks/server.conf` | Guarda el nombre de la instancia SQL local (NO se sube al repo) |
| `backups/` | Carpeta donde se guardan los `.bak` (subidos via Git LFS) |

---

## Requisitos

Antes de instalar, asegúrate de tener:

| Herramienta | Versión mínima | Descarga |
|---|---|---|
| Git | 2.x | https://git-scm.com |
| Git LFS | 3.x | https://git-lfs.com |
| Git Bash | Incluido con Git | — |
| SQL Server | 2019+ | https://www.microsoft.com/sql-server |
| sqlcmd | Incluido con SQL Server | — |

---

## Instalación en una PC nueva

### Paso 1 — Verificar requisitos

Abre **Git Bash** y verifica:

```bash
git --version
git lfs version
sqlcmd -?
```

Si falta Git LFS, instálalo desde https://git-lfs.com antes de continuar.

### Paso 2 — Clonar el repositorio

```bash
git clone https://github.com/IscTepas/ABD2026.git C:\ABD2026
cd C:\ABD2026
```

### Paso 3 — Descargar los archivos .bak via LFS

```bash
git lfs pull
```

### Paso 4 — Configurar los hooks de Git

```bash
git config core.hooksPath git-hooks
```

### Paso 5 — Configurar la instancia de SQL Server local

Abre **PowerShell** y ejecuta:

```powershell
# Si tu instancia es la default (localhost)
[System.IO.File]::WriteAllText("C:\ABD2026\git-hooks\server.conf", ".\SQLEXPRESS")

# Si tienes una instancia con nombre (ejemplo: .\NUÑEZ)
[System.IO.File]::WriteAllText("C:\ABD2026\git-hooks\server.conf", ".\TUNOMBRE")
```

> ⚠️ El `server.conf` es local — cada PC tiene el suyo y **no se sube al repositorio**.

> ⚠️ Si tienes la Ñ u otros caracteres especiales en el nombre de tu instancia, usa siempre **PowerShell** para crear este archivo.

### Paso 6 — Restaurar las bases de datos por primera vez

Abre **CMD como Administrador** y ejecuta:

```cmd
cd C:\ABD2026
ActualizarProyecto.bat
```

Esto restaurará todas las BDs desde los `.bak` descargados.

### Paso 7 — Verificar que todo funciona

```bash
# En Git Bash — hace un commit de prueba
echo "test" >> test.txt
git add test.txt
git commit -m "Prueba instalacion"
```

Deberías ver:
```
Generando respaldos automaticos (.bak)...
Instancia: MSSQL17.XXXX en puerto XXXX
   Sin cambios, omitiendo: ...
Listo. Guardando en Git...
```

---

## Estructura del proyecto

```
C:\ABD2026\
├── UNIDAD 3\                  ← Scripts y archivos de Unidad 3
├── UNIDAD 4\                  ← Scripts y archivos de Unidad 4
├── UNIDAD 5\                  ← Scripts y archivos de Unidad 5
├── backups\                   ← Backups .bak (subidos via Git LFS)
│   ├── BDPARTICIONES.bak
│   ├── AdventureWorks2022.bak
│   └── ...
├── git-hooks\                 ← Automatizaciones de Git
│   ├── pre-commit             ← Hook: genera backups antes del commit
│   ├── post-merge             ← Hook: restaura BDs después del pull
│   ├── backup.ps1             ← Script PowerShell de respaldo inteligente
│   ├── server.conf            ← Instancia SQL local (NO se sube al repo)
│   └── backups/*.stamp        ← Control de cambios (NO se sube al repo)
├── .gitattributes             ← Configuración Git LFS para .bak
├── .gitignore                 ← Archivos ignorados por Git
├── ActualizarProyecto.bat     ← Script de instalación inicial
└── README.md                  ← Este archivo
```

---

## Archivos importantes

### `git-hooks/backup.ps1`
Detecta automáticamente todas las instancias SQL Server instaladas buscando sus puertos en el registro de Windows. Por cada BD, compara el `@@DBTS` (contador de transacciones) con el último backup para determinar si hubo cambios reales. Solo respalda las BDs modificadas.

### `git-hooks/server.conf`
Contiene el nombre de la instancia SQL Server local. **Es diferente en cada PC** y nunca se sube al repositorio. Debe crearse manualmente con PowerShell al instalar en una PC nueva.

### `.gitattributes`
Configura Git LFS para los archivos `.bak`:
```
*.bak filter=lfs diff=lfs merge=lfs -text
```

---

## Uso diario

### En la PC donde trabajas (commit)

```bash
# Después de modificar una BD, simplemente haz commit
git add .
git commit -m "Descripción de tus cambios"
git push
```

El sistema automáticamente:
- Detecta qué BDs cambiaron usando `@@DBTS`
- Genera solo los `.bak` necesarios
- Los sube via Git LFS

### En la otra PC (pull)

```bash
git pull
```

El sistema automáticamente:
- Descarga los `.bak` actualizados
- Restaura las BDs en SQL Server via `post-merge`

---

## Solución de problemas

### ❌ `cannot spawn git-hooks/pre-commit: No such file or directory`
El hook no tiene permisos de ejecución:
```bash
chmod +x git-hooks/pre-commit
chmod +x git-hooks/post-merge
```

### ❌ `SSL Provider: La cadena de certificación fue emitida por una entidad en la que no se confía`
Falta el parámetro `-No` en los comandos `sqlcmd`. Verifica que el `backup.ps1` use `-No` en todas las conexiones.

### ❌ El backup.ps1 no encuentra ninguna instancia
Verifica que SQL Server esté corriendo:
```powershell
Get-Service | Where-Object { $_.Name -like "MSSQL*" }
```

### ❌ Los .bak no se suben a GitHub
Verifica que Git LFS esté configurado:
```bash
git lfs track
git lfs status
```

### ❌ Error al restaurar: `Access denied` o `Permission denied`
Ejecuta Git Bash o CMD **como Administrador**.

### ❌ La Ñ u otros caracteres especiales en el nombre de instancia
Usa siempre **PowerShell** para crear/modificar el `server.conf`:
```powershell
[System.IO.File]::WriteAllText("C:\ABD2026\git-hooks\server.conf", ".\TUNOMBRE")
```

### ❌ El hook genera backup de todas las BDs aunque no hubo cambios
Los archivos `.stamp` controlan qué BDs cambiaron. Si se borraron, el sistema respaldará todo una vez y luego volverá a funcionar correctamente.

---

## 📝 Notas importantes

- Los archivos `.mdf` y `.ldf` están en `.gitignore` — nunca se suben al repo
- Los archivos `.stamp` y `server.conf` son locales — nunca se suben al repo
- El sistema detecta automáticamente todas las instancias SQL instaladas en cualquier PC
- Solo se respaldan las BDs que tuvieron cambios reales desde el último backup
- Git LFS maneja los archivos `.bak` para no inflar el repositorio

---

*Sistema desarrollado para ABD2026 — Automatización de Bases de Datos*