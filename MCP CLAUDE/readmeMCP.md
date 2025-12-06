# MCP Server Installatie

## Overzicht

Dit document beschrijft de geïnstalleerde MCP (Model Context Protocol) servers voor Claude Code en hoe je deze kunt installeren in andere projecten.

## Geïnstalleerde Servers

### 1. Sequential Thinking
- **Package**: `@modelcontextprotocol/server-sequential-thinking`
- **Beschrijving**: Biedt gestructureerd denken en probleemoplossing voor complexe taken
- **Functionaliteit**:
  - Breekt complexe problemen op in beheersbare stappen
  - Ondersteunt dynamische aanpassing van denkstappen
  - Maakt alternatieve redeneringspaden mogelijk
  - Helpt bij het genereren en verifiëren van oplossingen

### 2. Context7
- **Package**: `@upstash/context7-mcp`
- **Beschrijving**: Levert up-to-date documentatie voor LLMs en AI code editors
- **Functionaliteit**:
  - Dynamisch injecteren van actuele, versie-specifieke documentatie
  - Haalt officiële documentatie en code voorbeelden op
  - Activeert automatisch wanneer je "use context7" in een prompt gebruikt

## Vereisten

- **Node.js**: v18.0.0 of hoger
- **NPM/NPX**: Geïnstalleerd met Node.js
- **Claude Code CLI**: Geïnstalleerd en geconfigureerd

## Handmatige Installatie

### Stap 1: Verwijder oude configuraties (indien aanwezig)
```bash
claude mcp remove sequential-thinking
claude mcp remove context7
```

### Stap 2: Voeg de correcte servers toe
```bash
claude mcp add sequential-thinking npx --  @modelcontextprotocol/server-sequential-thinking
claude mcp add context7 npx --  @upstash/context7-mcp
```

### Stap 3: Verifieer de installatie
```bash
claude mcp list
```

Je zou moeten zien:
```
sequential-thinking: npx -y @modelcontextprotocol/server-sequential-thinking - ✓ Connected
context7: npx -y @upstash/context7-mcp - ✓ Connected
```

## Geautomatiseerde Installatie

Gebruik het meegeleverde script voor snelle installatie:

### Windows (PowerShell)
```powershell
.\install-mcp-servers.ps1
```

### Windows (Command Prompt)
```cmd
install-mcp-servers.bat
```

## Troubleshooting

### Servers verbinden niet
1. Controleer of Node.js en NPX geïnstalleerd zijn:
   ```bash
   node --version
   npx --version
   ```

2. Verwijder en herinstalleer de servers:
   ```bash
   claude mcp remove sequential-thinking
   claude mcp remove context7
   ```
   Voer dan de installatiestappen opnieuw uit.

### Package niet gevonden fout
Zorg ervoor dat je de correcte package namen gebruikt:
- ❌ `@anthropic-ai/mcp-server-sequential-thinking` (oude/incorrecte naam)
- ✅ `@modelcontextprotocol/server-sequential-thinking` (correcte naam)
- ❌ `@upstash/context7-server` (oude/incorrecte naam)
- ✅ `@upstash/context7-mcp` (correcte naam)

## Configuratie

De MCP servers worden opgeslagen in `~/.claude.json` onder de project-specifieke configuratie. De configuratie ziet er als volgt uit:

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "env": {}
    },
    "context7": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "env": {}
    }
  }
}
```

## Meer Informatie

- [MCP Protocol Documentatie](https://modelcontextprotocol.io)
- [Sequential Thinking op NPM](https://www.npmjs.com/package/@modelcontextprotocol/server-sequential-thinking)
- [Context7 op NPM](https://www.npmjs.com/package/@upstash/context7-mcp)
- [Claude Code Documentatie](https://docs.claude.com/en/docs/claude-code)

## Datum

Laatste update: 7 oktober 2025
