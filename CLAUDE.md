# Marstek Venus E Battery API Project

> **📋 Zie [ROADMAP.md](./ROADMAP.md) voor het volledige stappenplan, status tracking en session logs**

## Huidige Setup (November 2024)

| Component | Status | Details |
|-----------|--------|---------|
| **SOC Data** | ✅ Actief | HA Marstek Local API integratie ([ha-marstek-local-api](https://github.com/jaapp/ha-marstek-local-api)) |
| **Batterij Rotatie** | ✅ Actief | `config/packages/battery-rotation.yaml` via symlink in HA |
| **MQTT Poller** | ❌ Niet in gebruik | Gearchiveerd in `archive/poller/` (fallback optie) |

## Project Overview
Dit project biedt een API interface voor het uitlezen en aansturen van een Marstek Venus E batterij via de Local API (UDP JSON-RPC). Het eindoel is een MQTT bridge voor Home Assistant integratie met support voor meerdere batterijen.

## Batterij Details
- **Model**: Marstek Venus E
- **IP Adres**: 192.168.0.108
- **API Port**: 30000 (UDP)
- **BLE MAC**: acd92968deb8
- **WiFi MAC**: 8c9a8f96ed1f
- **Device ID**: VenusE-acd92968deb8

## API Protocol

### Communicatie Methode
- **Protocol**: JSON-RPC over UDP
- **Port**: 30000 (source én destination moeten hetzelfde zijn!)
- **Format**: UTF-8 encoded JSON

### Request Structuur
```json
{
  "id": 1,
  "method": "Component.Action",
  "params": {"ble_mac": "0"}
}
```

### Response Structuur
```json
{
  "id": 1,
  "src": "VenusE-acd92968deb8",
  "result": { ... }
}
```

Of bij fouten:
```json
{
  "id": 1,
  "src": "VenusE-acd92968deb8",
  "error": {
    "code": -32602,
    "message": "Invalid params",
    "data": 412
  }
}
```

## Beschikbare API Methods

### ✅ Werkende Methods

1. **Marstek.GetDevice** - Device discovery en basis info
   - Params: `{"ble_mac": "0"}`
   - Returns: device type, versie, MAC adressen, IP, WiFi naam
   ```json
   {
     "device": "VenusE",
     "ver": 155,
     "ble_mac": "acd92968deb8",
     "wifi_mac": "8c9a8f96ed1f",
     "wifi_name": "MestTelenet",
     "ip": "192.168.0.108"
   }
   ```

2. **ES.GetStatus** - Energy System status ⭐ BELANGRIJKSTE METHOD
   - Params: `{"id": 0}`
   - Returns: SOC, capaciteit, power flows, energie counters
   ```json
   {
     "id": 0,
     "bat_soc": 14,           // Battery State of Charge (%)
     "bat_cap": 5120,         // Battery Capacity (Wh)
     "pv_power": 0,           // Solar power (W)
     "ongrid_power": 0,       // Grid power (W)
     "offgrid_power": 0,      // Off-grid power (W)
     "total_pv_energy": 0,    // Total PV energy (Wh)
     "total_grid_output_energy": 703,  // Grid export (Wh)
     "total_grid_input_energy": 919,   // Grid import (Wh)
     "total_load_energy": 0   // Load energy (Wh)
   }
   ```

3. **ES.GetMode** - Huidige werkingsmodus
   - Params: `{"id": 0}`
   - Returns: mode, power flows, SOC
   ```json
   {
     "id": 0,
     "mode": "Manual",        // Auto/AI/Manual/Passive
     "ongrid_power": 0,
     "offgrid_power": 0,
     "bat_soc": 14
   }
   ```

4. **BLE.GetStatus** - Bluetooth status
   - Params: `{"id": 0}`
   - Returns: BLE state
   ```json
   {
     "id": 0,
     "state": "disconnect",   // connect/disconnect
     "ble_mac": "acd92968deb8"
   }
   ```

### ⏸️ Methods met Timeout (Mogelijk Niet Ondersteund op Venus E)
- **Bat.GetStatus** - Timeout (geen response)
- **Wifi.GetStatus** - Timeout (geen response)
- **EM.GetStatus** - Energy Meter - Timeout (geen response)

### ❌ Niet Beschikbare Methods
- **PV.GetStatus** - "Method not found" (Venus E heeft geen ingebouwde PV)

### BLE Protocol (Alternatief)
Voor directe hardware controle via Bluetooth Low Energy:

**Service UUID**: `0000ff00-0000-1000-8000-00805f9b34fb`
- TX (Write): `0000ff01-0000-1000-8000-00805f9b34fb`
- RX (Notify): `0000ff02-0000-1000-8000-00805f9b34fb`

**Frame Format**: `[0x73][LENGTH][0x23][CMD][PAYLOAD...][XOR_CHECKSUM]`

**Belangrijke BLE Commands**:
- `0x03` - Runtime Info (power flow, temperaturen)
- `0x04` - Device Info (firmware versies)
- `0x14` - BMS Data (batterij voltage, capaciteit, cel voltages)
- `0x28` - Local API enable/disable + poort configuratie

## Data Structuren

### BMS Data (via BLE 0x14)
- Voltage: bytes 14-15 (÷100 voor V)
- Current: bytes 16-17 (÷10 voor A)
- SOC: bytes 8-9 (percentage)
- SOH: bytes 10-11 (percentage)
- Cell Voltages: bytes 48+ (2 bytes per cel, ÷1000 voor V)
- Temperaturen: bytes 38-47

### Runtime Info (via BLE 0x03)
- Input Power 1: bytes 2-3 (W)
- Input Power 2: bytes 4-5 (÷100 voor W)
- Output Power 1: bytes 20-21 (W)
- Output Power 2: bytes 24-25 (÷10 voor W)
- Temperatuur: bytes 33-34 (÷10 voor °C)

## Belangrijke Opmerkingen

### Socket Configuration
```python
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(("0.0.0.0", 30000))  # Belangrijk: bind op 0.0.0.0!
sock.settimeout(1.5)
```

### Multiple Packet Collection
De batterij kan meerdere response packets sturen. Verzamel ze allemaal:
```python
packets = []
while len(packets) < 16:
    try:
        resp, addr = sock.recvfrom(65535)
        packets.append((resp, addr))
    except socket.timeout:
        break
```

### Echo Responses
De batterij stuurt soms de request terug als echo. Filter deze eruit:
```python
if response == request:
    # Dit is een echo, skip
    pass
```

## Veiligheidsoverwegingen

### Veilige Commands (Read-Only)
- Marstek.GetDevice
- Bat.GetStatus
- ES.GetStatus
- ES.GetMode
- Alle BLE read commands (0x03, 0x04, 0x08, 0x0D, 0x13, 0x14, etc.)

### Gevaarlijke Commands
- **ES.SetMode** - Wijzigt werkingsmodus
- **BLE 0x15** - Set Power Mode (800W/2500W)
- **BLE 0x16/0x17** - Set Power Limits
- **BLE 0x0C** - System Reset (data loss!)
- **BLE 0x1F** - Firmware Update Mode (kan device bricken!)

## Development Guidelines

### Bij het Implementeren van Nieuwe Features
1. Test eerst met read-only commands
2. Gebruik altijd try-except voor socket operaties
3. Valideer responses op JSON format
4. Check for error codes in responses
5. Implementeer proper timeout handling

### Bij het Aansturen van de Batterij
1. Vraag altijd bevestiging van gebruiker
2. Valideer parameters vooraf
3. Implementeer rate limiting
4. Log alle write operations
5. Implementeer rollback mechanisme waar mogelijk

### Code Style
- Gebruik duidelijke variabele namen
- Documenteer alle API calls met docstrings
- Error messages in het Nederlands
- Comments in het Nederlands

## Resources & Documentatie

### Primary Sources
- BLE Protocol: https://rweijnen.github.io/marstek-venus-monitor/
- GitHub Repository: https://github.com/rweijnen/marstek-venus-monitor
- Modbus Integration: https://github.com/gf78/marstek-venus-modbus-restapi-mqtt-nodered-homeassistant

### Community Forums
- Domoticz Plugin: https://forum.domoticz.com/viewtopic.php?t=43761
- Home Assistant: https://community.home-assistant.io/t/marstek-venus-e-first-version-of-a-cloud-integration/929840
- Homey App: https://community.homey.app/t/marstek-venus-connector-app-development-thread/143139

## Testing
Test scripts aanwezig in project:
- `apiTest.py` - Basis API test met meerdere methods
- `apiTest_advanced.py` - Broadcast discovery + diagnostics
- `apiTest_debug.py` - Debug versie
- `apiTest_final.py` - Final test versie

Run test: `python apiTest.py`

## TODO / Known Issues
- [ ] Correcte parameters vinden voor Bat.GetStatus
- [ ] Correcte parameters vinden voor ES.GetStatus
- [ ] Correcte parameters vinden voor ES.GetMode
- [ ] API client class implementeren
- [ ] Rate limiting implementeren
- [ ] Error handling verbeteren
- [ ] Logging systeem opzetten
