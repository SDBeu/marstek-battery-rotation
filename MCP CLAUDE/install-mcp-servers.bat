@echo off
REM MCP Server Installatie Script voor Claude Code
REM Dit script installeert Sequential Thinking en Context7 MCP servers

echo ==================================
echo MCP Server Installatie voor Claude Code
echo ==================================
echo.

REM Controleer of Claude CLI beschikbaar is
echo Controleren of Claude CLI beschikbaar is...
claude --version >nul 2>&1
if errorlevel 1 (
    echo X Claude CLI niet gevonden. Installeer eerst Claude Code.
    exit /b 1
)
echo + Claude CLI gevonden
echo.

REM Controleer of Node.js beschikbaar is
echo Controleren of Node.js beschikbaar is...
node --version >nul 2>&1
if errorlevel 1 (
    echo X Node.js niet gevonden. Installeer Node.js v18 of hoger.
    exit /b 1
)
for /f "delims=" %%i in ('node --version') do set NODE_VERSION=%%i
echo + Node.js gevonden: %NODE_VERSION%
echo.

REM Controleer of NPX beschikbaar is
echo Controleren of NPX beschikbaar is...
npx --version >nul 2>&1
if errorlevel 1 (
    echo X NPX niet gevonden. Installeer NPM/NPX.
    exit /b 1
)
for /f "delims=" %%i in ('npx --version') do set NPX_VERSION=%%i
echo + NPX gevonden: %NPX_VERSION%
echo.

echo Verwijderen van eventuele oude configuraties...
REM Verwijder oude configuraties (negeer errors als ze niet bestaan)
claude mcp remove sequential-thinking >nul 2>&1
claude mcp remove context7 >nul 2>&1
echo.

echo Installeren van MCP servers...

REM Installeer Sequential Thinking
echo   - Sequential Thinking...
claude mcp add sequential-thinking npx -- -y @modelcontextprotocol/server-sequential-thinking
if errorlevel 1 (
    echo     X Fout bij installatie van Sequential Thinking
) else (
    echo     + Sequential Thinking geinstalleerd
)

REM Installeer Context7
echo   - Context7...
claude mcp add context7 npx -- -y @upstash/context7-mcp
if errorlevel 1 (
    echo     X Fout bij installatie van Context7
) else (
    echo     + Context7 geinstalleerd
)
echo.

echo Controleren van MCP server status...
echo.
claude mcp list
echo.

echo ==================================
echo Installatie voltooid!
echo ==================================
echo.
echo De volgende MCP servers zijn geinstalleerd:
echo   * Sequential Thinking - Gestructureerd denken en probleemoplossing
echo   * Context7 - Up-to-date code documentatie
echo.
echo Zie readmeMCP.md voor meer informatie.
echo.
pause
