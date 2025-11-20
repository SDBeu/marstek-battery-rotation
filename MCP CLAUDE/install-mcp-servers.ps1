# MCP Server Installatie Script voor Claude Code
# Dit script installeert Sequential Thinking en Context7 MCP servers

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "MCP Server Installatie voor Claude Code" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Controleer of Claude CLI beschikbaar is
Write-Host "Controleren of Claude CLI beschikbaar is..." -ForegroundColor Yellow
try {
    $claudeVersion = claude --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Claude CLI niet gevonden"
    }
    Write-Host "✓ Claude CLI gevonden" -ForegroundColor Green
} catch {
    Write-Host "✗ Claude CLI niet gevonden. Installeer eerst Claude Code." -ForegroundColor Red
    exit 1
}

# Controleer of Node.js beschikbaar is
Write-Host "Controleren of Node.js beschikbaar is..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Node.js niet gevonden"
    }
    Write-Host "✓ Node.js gevonden: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Node.js niet gevonden. Installeer Node.js v18 of hoger." -ForegroundColor Red
    exit 1
}

# Controleer of NPX beschikbaar is
Write-Host "Controleren of NPX beschikbaar is..." -ForegroundColor Yellow
try {
    $npxVersion = npx --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "NPX niet gevonden"
    }
    Write-Host "✓ NPX gevonden: $npxVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ NPX niet gevonden. Installeer NPM/NPX." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Verwijderen van eventuele oude configuraties..." -ForegroundColor Yellow

# Verwijder oude configuraties (negeer errors als ze niet bestaan)
claude mcp remove sequential-thinking 2>&1 | Out-Null
claude mcp remove context7 2>&1 | Out-Null

Write-Host ""
Write-Host "Installeren van MCP servers..." -ForegroundColor Yellow

# Installeer Sequential Thinking
Write-Host "  - Sequential Thinking..." -ForegroundColor Yellow
$result = claude mcp add sequential-thinking npx -- -y @modelcontextprotocol/server-sequential-thinking 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "    ✓ Sequential Thinking geïnstalleerd" -ForegroundColor Green
} else {
    Write-Host "    ✗ Fout bij installatie van Sequential Thinking" -ForegroundColor Red
    Write-Host "    $result" -ForegroundColor Red
}

# Installeer Context7
Write-Host "  - Context7..." -ForegroundColor Yellow
$result = claude mcp add context7 npx -- -y @upstash/context7-mcp 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "    ✓ Context7 geïnstalleerd" -ForegroundColor Green
} else {
    Write-Host "    ✗ Fout bij installatie van Context7" -ForegroundColor Red
    Write-Host "    $result" -ForegroundColor Red
}

Write-Host ""
Write-Host "Controleren van MCP server status..." -ForegroundColor Yellow
Write-Host ""
claude mcp list

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Installatie voltooid!" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "De volgende MCP servers zijn geïnstalleerd:" -ForegroundColor Green
Write-Host "  • Sequential Thinking - Gestructureerd denken en probleemoplossing" -ForegroundColor White
Write-Host "  • Context7 - Up-to-date code documentatie" -ForegroundColor White
Write-Host ""
Write-Host "Zie readmeMCP.md voor meer informatie." -ForegroundColor Cyan
