# Marstek Venus Battery - Home Assistant Integratie Roadmap

**Laatst bijgewerkt**: 2025-11-16
**Status**: Batterij Besturing - Testing & Implementatie

---

## 🎯 Eindoel

Meerdere Marstek Venus E batterijen uitlezen en aansturen via Home Assistant, zodat:
- Real-time monitoring van batterij status (SOC, power, voltage, etc.)
- Werkingsmodus kan worden aangepast (zelfverbruik, backup, grid feeding, etc.)
- Automatiseringen mogelijk zijn (bijv. laden bij lage stroomprijs)
- Overzichtelijk dashboard met alle batterijen

---

## 📋 Architectuur Keuze

**Gekozen aanpak**: MQTT Bridge

**Waarom MQTT**:
- ✅ Schaalbaar voor meerdere batterijen
- ✅ Home Assistant autodiscovery support
- ✅ Real-time updates
- ✅ Standaard HA integratie patroon
- ✅ Community gebruikt dit ook

**Architectuur diagram**:
```
[Marstek Battery] <--UDP JSON-RPC--> [Python MQTT Bridge] <--MQTT--> [Mosquitto] <--> [Home Assistant]
   192.168.0.108                       Service/Script                   Add-on           homeassistant.local
```

---

## 🚀 Implementatie Fases

### ✅ FASE 0: Initiële Verkenning (COMPLEET)

**Status**: ✅ Afgerond op 2025-11-13

**Wat werkt**:
- ✅ Local API bereikbaar op 192.168.0.108:30000
- ✅ `Marstek.GetDevice` methode geeft correcte response
- ✅ Device info: VenusE-acd92968deb8, firmware v155
- ✅ UDP socket communicatie werkt
- ✅ JSON-RPC parsing werkt

**Wat niet werkt**:
- ❌ `Bat.GetStatus` - "Invalid params" error (-32602)
- ❌ `ES.GetStatus` - "Invalid params" error (-32602)
- ❌ `ES.GetMode` - "Invalid params" error (-32602)
- ❌ `Wifi.GetStatus` - timeout
- ❌ `BLE.GetStatus` - "Invalid params" error (-32602)
- ❌ `EM.GetStatus` - "Invalid params" error (-32602)

**Test scripts aanwezig**:
- `apiTest.py` - Basis test (gebruikt)
- `apiTest_advanced.py` - Broadcast discovery & diagnostics
- `apiTest_debug.py` - Debug versie
- `apiTest_final.py` - Final test versie

**Documentatie**:
- ✅ CLAUDE.md gemaakt met API documentatie
- ✅ BLE protocol volledig gedocumenteerd
- ✅ Community resources verzameld

---

### ✅ FASE 1: Home Assistant Verificatie (COMPLEET)

**Status**: ✅ Afgerond op 2025-11-13

**Doel**: Verifiëren dat Home Assistant en MQTT klaar zijn voor integratie

**Wat werkt**:
- ✅ Home Assistant draait: homeassistant.local:8123 (IP: 192.168.0.139)
- ✅ MQTT broker (Mosquitto) draait als HA add-on
- ✅ Python paho-mqtt library geïnstalleerd
- ✅ MQTT test script gemaakt en werkend
- ✅ MQTT connectie succesvol met authenticatie
- ✅ MQTT user aangemaakt (username: marstek)
- ✅ MQTT autodiscovery werkt perfect
- ✅ Test sensor zichtbaar in Home Assistant

**Taken**:
1. [x] MQTT connection test script maken
2. [x] Python paho-mqtt library installeren
3. [x] Test connectie met Mosquitto broker
4. [x] MQTT gebruiker aanmaken in Home Assistant
5. [x] Update mqtt_test.py met credentials
6. [x] Test connectie opnieuw (succesvol!)
7. [x] Test simpel bericht publiceren (succesvol!)
8. [x] Test Home Assistant autodiscovery met dummy sensor (succesvol!)
9. [x] Verifieer sensor verschijnt in HA (bevestigd door gebruiker!)

**Opgeloste problemen**:
- ✅ MQTT authenticatie: credentials aangemaakt en werkend
- ✅ Hostname resolution: gebruik IP adres 192.168.0.139
- ✅ Unicode encoding: emoji's verwijderd voor Windows compatibility
- ✅ Client ID conflicts: unieke random ID per connectie

**Output**:
- ✅ Werkend MQTT test script (mqtt_test.py)
- ✅ MQTT_SETUP.md met instructies
- ✅ Bevestiging dat HA autodiscovery werkt
- ✅ Test sensor "Marstek Test Device" zichtbaar in HA met waarde 300W

---

### ✅ FASE 2: API Parameters Uitzoeken (COMPLEET)

**Status**: ✅ Afgerond op 2025-11-13

**Doel**: Alle Marstek API methods werkend krijgen met correcte parameters

**Wat gedaan**:
1. [x] Geanalyseerd jaapp/ha-marstek-local-api broncode (beste implementatie)
2. [x] Ontdekt correcte parameter formats via source code analyse
3. [x] Gedocumenteerd parameter formats in CLAUDE.md
4. [x] Update apiTest.py met werkende parameters
5. [x] Getest alle methods op Venus E firmware v155

**Ontdekte Parameter Format** (api.py:225-226):
```python
# Standaard params als geen opgegeven:
if params is None:
    params = {"id": 0}

# Specifieke methods:
- Marstek.GetDevice: {"ble_mac": "0"}
- Alle andere methods: {"id": 0}
```

**Test Resultaten Venus E (firmware v155)**:
- ✅ **Marstek.GetDevice** - Werkt perfect
- ✅ **ES.GetStatus** - Werkt! (SOC, capacity, power flows, energie counters)
- ✅ **ES.GetMode** - Werkt! (mode: Manual/Auto/AI/Passive)
- ✅ **BLE.GetStatus** - Werkt! (BLE state)
- ⏸️ **Bat.GetStatus** - Timeout (niet ondersteund op Venus E)
- ⏸️ **Wifi.GetStatus** - Timeout (niet ondersteund)
- ⏸️ **EM.GetStatus** - Timeout (niet ondersteund)
- ❌ **PV.GetStatus** - Method not found (Venus E heeft geen PV)

**Belangrijke Data**:
```json
ES.GetStatus result:
{
  "bat_soc": 14,              // Battery SOC (%)
  "bat_cap": 5120,            // Capacity (Wh)
  "pv_power": 0,              // Solar (W)
  "ongrid_power": 0,          // Grid (W)
  "total_grid_output_energy": 703,  // Export (Wh)
  "total_grid_input_energy": 919    // Import (Wh)
}
```

**Output**:
- ✅ Volledige API documentatie in CLAUDE.md
- ✅ Werkende apiTest.py met alle methods
- ✅ Data structuren gedocumenteerd
- ✅ jaapp/ha-marstek-local-api repository gecloned als referentie

---

### 🔲 FASE 3: Marstek API Client Class

**Status**: 🔲 Nog te doen

**Doel**: Herbruikbare Python class voor Marstek communicatie

**Functionaliteit**:
```python
class MarstekAPI:
    - connect()
    - disconnect()
    - get_device_info()
    - get_battery_status()
    - get_energy_status()
    - get_mode()
    - set_mode(mode)
    - get_power_flow()
    # etc.
```

**Features**:
- Error handling & retries
- Connection pooling
- Rate limiting
- Data validation
- Logging
- Thread-safe operaties

**Output**:
- `marstek_api.py` module
- Unit tests
- Documentatie

---

### 🔲 FASE 4: MQTT Bridge Implementatie

**Status**: 🔲 Nog te doen

**Doel**: Service die Marstek data naar MQTT publiceert

**Componenten**:
1. **Main service** (`marstek_mqtt_bridge.py`)
   - Marstek API polling loop (elke 5-10 sec)
   - MQTT publisher
   - Error recovery
   - Logging

2. **Config file** (`config.yaml`)
   ```yaml
   marstek:
     ip: 192.168.0.108
     port: 30000
     poll_interval: 10

   mqtt:
     broker: homeassistant.local
     port: 1883
     username: ""
     password: ""

   homeassistant:
     discovery_prefix: homeassistant
   ```

3. **HA Discovery**
   - Auto-create sensors
   - Auto-create switches/selects
   - Device grouping

**Sensors om te publiceren**:
- Battery SOC (%)
- Battery voltage (V)
- Battery current (A)
- Battery power (W)
- Grid power (W)
- PV power (W)
- Load power (W)
- Temperature (°C)
- Operating mode
- Online status

**Output**:
- Werkende MQTT bridge service
- Config file
- Systemd service file (Linux) / Windows service
- Logging configuratie

---

### 🔲 FASE 5: Home Assistant Command Handler

**Status**: 🔲 Nog te doen

**Doel**: Commands vanuit HA naar batterij sturen

**Functionaliteit**:
- MQTT command subscriptions
- ES.SetMode implementatie
- Power limit controls
- Safety validations
- Command logging

**HA Entities**:
- `select.marstek_mode` - Operating mode selector
- `switch.marstek_backup` - Backup mode on/off
- `number.marstek_discharge_limit` - Max discharge power
- `number.marstek_charge_limit` - Max charge power

**Safety features**:
- Command validation
- Rate limiting
- User confirmation voor kritieke commands
- Rollback bij fouten

**Output**:
- Command handler module
- HA configuratie examples
- Veiligheids documentatie

---

### 🔲 FASE 6: Multi-Battery Support

**Status**: 🔲 Nog te doen (toekomst)

**Doel**: Meerdere batterijen tegelijk monitoren

**Aanpak**:
- Battery discovery (broadcast scan)
- Per-battery MQTT topics
- Aggregated sensors (total power, total SOC, etc.)
- Individual battery devices in HA

**Config**:
```yaml
batteries:
  - name: "Battery 1"
    ip: 192.168.0.108
  - name: "Battery 2"
    ip: 192.168.0.109
```

---

## 🎯 Stappenplan: Batterij Besturing (Session 2 - Nov 2025)

**Use Case**: Zelfverbruik optimaliseren + PV opslag
**Stroomprijzen**: Engie tarievenplan (dal/piek/superdal)
**Batterijen**: 3x Marstek Venus E (FaseA, FaseB, FaseC)

### 🔲 FASE 1: Basis Test - Handmatige Besturing
**Status**: 🔲 Ready to start
**Doel**: Verifieer dat we 1 batterij kunnen aansturen

**Stappen**:
1. [ ] Maak shell command in HA configuration.yaml voor FaseB
2. [ ] Test handmatig laden: 1000W voor 5 minuten
3. [ ] Monitor resultaten in HA:
   - Operating mode → "Passive"
   - Battery power → ~-1000W
   - SOC → moet stijgen
4. [ ] Verifieer success voordat verder gaan

**Batterij voor test**: FaseB (9a7d) - IP: 192.168.6.213 - SOC: 22% (laagst)

**Output**:
- Werkende shell command
- Bevestiging dat handmatige controle werkt
- Begrip van response times en gedrag

---

### 🔲 FASE 2: Engie Tarievenplan Integreren
**Status**: 🔲 Waiting
**Doel**: Automatisch laden tijdens dal/superdal periodes

**Stappen**:
1. [ ] Maak input_datetime helpers voor tariefperiodes:
   - Superdal start/eind
   - Dal start/eind
   - Piek (rest van de tijd)
2. [ ] Maak template sensor: huidige tarief
3. [ ] Simpele automation: laad FaseB tijdens superdal
4. [ ] Test automation 1 dag
5. [ ] Als succesvol: uitbreiden naar alle 3 batterijen
6. [ ] Fine-tune: power levels, SOC limieten

**Output**:
- Automatisch laden tijdens goedkoopste tarieven
- Logging/monitoring van tariefwissels
- Energiebesparing tracking

---

### 🔲 FASE 3: PV Zelfverbruik Optimalisatie
**Status**: 🔲 Waiting
**Doel**: PV overschot opslaan in batterijen

**Stappen**:
1. [ ] Identificeer PV productie sensor (of installeren)
2. [ ] Maak automation:
   - IF: PV productie > verbruik + 500W
   - AND: Gemiddelde SOC < 90%
   - THEN: Laad batterijen met overschot power
3. [ ] Test met echte PV productie
4. [ ] Optimaliseren: balans tussen tarieven en zelfverbruik
5. [ ] Prioriteit logica:
   - Eerst: zelfverbruik PV
   - Dan: superdal laden
   - Dan: dal laden

**Output**:
- Maximaal zelfverbruik
- Minimale netlevering
- Optimale mix PV + tarieven

---

### 🔲 FASE 4: Dashboard & Monitoring
**Status**: 🔲 Optioneel
**Doel**: Overzichtelijk dashboard

**Mogelijkheden**:
- Energy dashboard configuratie
- Custom Lovelace cards
- Grafana/InfluxDB integratie
- Notificaties bij problemen
- Kostenbesparing tracking

---

### 🔲 FASE 5: Geavanceerde Optimalisatie
**Status**: 🔲 Toekomst
**Doel**: Machine learning / voorspellende controle

**Ideeën**:
- Weersvoorspelling → PV productie voorspellen
- Verbruikspatronen leren
- Dynamische SOC targets per seizoen
- Batterij health monitoring
- Degradatie preventie (niet te vaak vol/leeg)

---

## 🐛 Bekende Issues & Problemen

### Issue #1: Invalid Params Errors
**Status**: ✅ Opgelost
**Impact**: Was hoog - blokkeerde batterij data uitlezen
**Oplossing**: Correcte params gevonden via jaapp/ha-marstek-local-api code
**Resolutie**: Alle core methods werken nu met `{"id": 0}` als params

### Issue #2: Onbekende Parameter Formats
**Status**: ✅ Opgelost
**Impact**: Was hoog - blokkeerde data uitlezen
**Oplossing**: Source code analyse van jaapp/ha-marstek-local-api
**Resolutie**: Parameters gedocumenteerd, ES.GetStatus en ES.GetMode werken perfect

### Issue #3: MQTT Authenticatie Vereist
**Status**: ✅ Opgelost
**Impact**: Was hoog - blokkeerde MQTT testing
**Oplossing**: MQTT gebruiker aangemaakt (username: marstek)
**Resolutie**: Alle MQTT tests succesvol, autodiscovery werkt perfect

---

## 📚 Resources & Links

### Werkende Community Implementaties
- **Homey App**: https://community.homey.app/t/marstek-venus-connector-app-development-thread/143139
  - Gebruikt Local API succesvol
  - Kan gebruikt worden als referentie voor parameters

- **Node-RED Flow**: https://github.com/gf78/marstek-venus-modbus-restapi-mqtt-nodered-homeassistant
  - MQTT implementatie met autodiscovery
  - Modbus alternatief

- **BLE Monitor Tool**: https://github.com/rweijnen/marstek-venus-monitor
  - Web-based BLE tool
  - Volledige protocol documentatie

### Officiële Documentatie
- **Marstek Open API**: https://eu.hamedata.com/ems/resource/agreement/MarstekDeviceOpenApi.pdf
  - PDF (moeilijk te parsen)
  - Officiële API specificatie

### Home Assistant Resources
- **MQTT Discovery**: https://www.home-assistant.io/integrations/mqtt/#mqtt-discovery
- **MQTT Sensor**: https://www.home-assistant.io/integrations/sensor.mqtt/
- **MQTT Select**: https://www.home-assistant.io/integrations/select.mqtt/

---

## 🔄 Session Log

### Session 1 - 2025-11-13

**✅ FASE 0 & FASE 1 COMPLEET**

**Gedaan**:
- ✅ Verzameld alle relevante documentatie (BLE + Local API)
- ✅ BLE protocol volledig gedocumenteerd
- ✅ CLAUDE.md gemaakt met API referentie
- ✅ ROADMAP.md gemaakt met volledige planning
- ✅ apiTest.py uitgevoerd - Marstek.GetDevice werkt perfect
- ✅ Home Assistant situatie geïnventariseerd (192.168.0.139:8123)
- ✅ paho-mqtt library geïnstalleerd
- ✅ mqtt_test.py script gemaakt en werkend
- ✅ MQTT connectie issues opgelost
- ✅ MQTT_SETUP.md gemaakt met instructies
- ✅ MQTT credentials aangemaakt (username: marstek)
- ✅ MQTT authenticatie werkend
- ✅ MQTT autodiscovery succesvol getest
- ✅ Test sensor zichtbaar in Home Assistant

**Opgeloste Issues**:
1. ✅ MQTT authenticatie (was error code 5) - opgelost met user credentials
2. ✅ Hostname resolution - opgelost door IP adres te gebruiken
3. ✅ Unicode encoding - opgelost door emoji's te verwijderen
4. ✅ Client ID conflicts - opgelost met random IDs

**Openstaande Issues**:
1. ⚠️ Marstek API methods geven "Invalid params" errors (Bat.GetStatus, ES.GetStatus, etc.)
   - Dit wordt aangepakt in Fase 2

**Fase 2 Updates**:
1. ✅ jaapp/ha-marstek-local-api repository gecloned en geanalyseerd
2. ✅ API parameter formats ontdekt via source code (api.py)
3. ✅ apiTest.py geüpdatet met correcte parameters `{"id": 0}`
4. ✅ Alle API methods getest - ES.GetStatus en ES.GetMode werken!
5. ✅ Volledige data structuren gedocumenteerd in CLAUDE.md

**Key Discovery**:
De `jaapp/ha-marstek-local-api` integratie is een volledige, werkende Home Assistant custom component met:
- 50+ sensors
- Mode controls
- Manual scheduling
- Multi-battery support
- Venus E support (met bekende firmware issues gedocumenteerd)

**Beslissing**: In plaats van zelf een MQTT bridge bouwen (Fase 3-4), kunnen we de bestaande HA integratie direct installeren via HACS. Dit bespaart significant development tijd.

**Volgende stappen**:
1. Installeer jaapp/ha-marstek-local-api via HACS
2. Configureer in Home Assistant
3. Verifieer dat alle sensors werken
4. Documenteer bevindingen
5. Optioneel later: Zelf MQTT bridge als custom functionaliteit nodig is

**Blokkerende issues**:
- Geen! Klaar voor installatie in HA

**Notes**:
- Gebruiker heeft HA + Mosquitto al draaien (scheelt tijd!)
- Focus op MQTT approach (niet REST API) ✅ Bevestigd als juiste keuze
- Documentatie eerst, dan pas code schrijven ✅ Werkt goed
- Windows encoding issues opgelost (Unicode characters vervangen)
- MQTT broker IP: 192.168.0.139 (niet homeassistant.local)
- MQTT credentials: marstek/marstek

---

### Session 2 - 2025-11-16

**✅ HACS Integratie Geïnstalleerd + Batterijen Gevonden**

**Gedaan**:
- ✅ jaapp/ha-marstek-local-api geïnstalleerd via HACS
- ✅ 3 batterijen succesvol gevonden en geïdentificeerd
- ✅ Broadcast discovery scan werkend (alle 3 batterijen antwoorden)
- ✅ test_tool.py getest - passive mode werkt! (150W ontladen FaseB)
- ✅ Mode switching getest - Auto mode switch succesvol
- ✅ IP adressen mapping compleet:
  - FaseA (d828): 192.168.6.80 - SOC: 100%
  - FaseB (9a7d): 192.168.6.213 - SOC: 22%
  - FaseC (deb8): 192.168.6.144 - SOC: 97%
- ✅ Gebruiker doelen geïdentificeerd:
  - Hoofddoel: Zelfverbruik optimaliseren + PV opslag
  - Stroomprijzen: Engie tarievenplan (dal/piek/superdal)
  - Start: Simpele test met handmatige besturing
- ✅ Stappenplan gemaakt en gedocumenteerd in ROADMAP.md

**Ontdekte Issues**:
1. ⚠️ HACS integratie services laden niet (alleen request_data_sync zichtbaar)
   - Workaround: Shell commands met test_tool.py
   - Status: Werkende alternatieve oplossing beschikbaar
2. ⚠️ Netwerk subnet veranderd tijdens sessie (192.168.0.x → 192.168.6.x)
   - Alle IP adressen opnieuw gescand en gedocumenteerd
3. ⚠️ FaseC Local API was uitgeschakeld na reset
   - Opgelost: API ingeschakeld via BLE tool
   - Nu werkend op 192.168.6.144

**Key Learnings**:
- Broadcast discovery is betrouwbaarder dan fixed IP
- test_tool.py werkt perfect voor directe controle
- Windows encoding (cp1252) vereist PYTHONIOENCODING=utf-8
- Passive mode response is direct (< 1 seconde)
- FaseB heeft lage SOC (22%) - goed voor test cases

**Beslissingen**:
1. ✅ Start met shell commands (services issue omzeilen)
2. ✅ Begin met 1 batterij testen (FaseB - laagste SOC)
3. ✅ Gefaseerde aanpak: test → tarieven → PV → optimalisatie
4. ✅ Documenteer alles in ROADMAP.md voor continuïteit

**Volgende Sessie**:
1. FASE 1 starten: Shell command maken in HA
2. Test laden FaseB (1000W, 5 min)
3. Monitor en verifieer resultaten
4. Bij success: uitbreiden naar automation

**Blokkerende issues**:
- Geen!

**Notes**:
- Gebruiker werkt gefaseerd en wil testen per stap ✅
- Plan mode gebruikt voor goedkeuring ✅
- Goede samenwerking: vraag stellen → plan → goedkeuring → execute
- Network subnet 192.168.6.x (was 192.168.0.x)
- Alle 3 batterijen bereikbaar en werkend

---

### Session 3 - 2025-11-24

**✅ BATTERIJ ROTATIE SYSTEEM VOLLEDIG WERKEND**

**Geïmplementeerde Features**:

1. **Batterij Rotatie Systeem** (`config/packages/battery-rotation.yaml`)
   - Automatisch wisselen tussen 3 batterijen op basis van P1 meter
   - Bij zonoverschot (P1 < -200W): leegste batterij actief
   - Bij netverbruik (P1 > +200W): volste batterij actief
   - Nachtmodus: rotatie automatisch uit voor nachtladen
   - Dagmodus: rotatie automatisch aan

2. **PV Voorspelling voor Nachtladen**
   - Telt zonuren morgen (07:00-20:00) via weather.forecast_home
   - Configureerbare productie per zonuur (input_number.pv_production_per_sunny_hour)
   - Berekent verwachte PV productie morgen
   - Trekt dit af van nachtlaad deficit

3. **Multi-Battery Night Charging**
   - Distribueert laad-deficit over meerdere batterijen
   - Berekent beschikbare capaciteit per batterij (5kWh - remaining)
   - Sorteert op beschikbare ruimte (leegste eerst)
   - Zet individuele laadschema's per batterij

4. **Overflow Charging** (nieuw!)
   - Bij hoge PV productie en actieve batterij < 85% SOC
   - Activeert tweede batterij in Passive mode
   - Power = |P1| met configureerbaar maximum
   - Configureerbare duration en power via dashboard
   - Stopt automatisch bij verbruik (P1 > 100W)
   - Manuele knoppen: Overflow A/B/C en Stop

5. **Dashboard** (`dashboards/battery-rotation-card.yaml`)
   - Real-time SOC gauges per batterij
   - Overflow status indicator
   - Manuele controle knoppen
   - PV voorspelling sectie
   - Overflow instellingen (power/duration)
   - Nachtladen sectie

**Device IDs** (voor marstek_local_api services):
- Fase A (schuin/d828): `c1fbfff25b11fcecf3530135b0b08f2c`
- Fase B (plat/9a7d): `79ea26ebcb0b77cc1e4acd1cc5af41f6`
- Fase C (geen/deb8): `f15b9f6024d9a2b044ca90e77824a314`

**IP Adressen**:
- Fase A: 192.168.6.80
- Fase B: 192.168.6.213
- Fase C: 192.168.6.144

**Key Sensors**:
- `sensor.battery_emptiest` / `sensor.battery_fullest`
- `sensor.marstek_sunny_hours_tomorrow` (trigger-based)
- `sensor.marstek_expected_pv_tomorrow`
- `sensor.marstek_net_charging_deficit`
- `sensor.marstek_charging_plan`
- `input_text.active_battery_fase`
- `input_text.overflow_battery_fase`

**Input Helpers**:
- `input_number.overflow_power` (100-2500W)
- `input_number.overflow_duration` (5-60 min)
- `input_number.pv_production_per_sunny_hour`
- `input_number.desired_total_capacity`
- `input_datetime.night_mode_start_time`
- `input_datetime.day_mode_start_time`

**Bekende Issues**:
- Weather entity: moet `weather.forecast_home` zijn (niet forecast_thuis)
- Trigger-based sensors: vereisen HA restart (niet alleen YAML reload)
- `clear_manual_schedules` duurt 1-2 min per batterij

**Volgende Stappen**:
- Testen overflow charging in productie
- Fine-tunen van thresholds
- Mogelijk: automatische overflow stop bij SOC > 95%
