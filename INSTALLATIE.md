# 🔋 Marstek Batterij Rotatie - Installatie Handleiding

## Stap 1: Verifieer Button Entity Names

**BELANGRIJK:** Voordat je de configuratie toevoegt, moet je checken of de button entity names kloppen!

### Optie A: Via Home Assistant Developer Tools (Makkelijkst)

1. Ga naar **Developer Tools → Template**
2. Plak deze code en klik **Render Template**:

```jinja2
Marstek Button Entities:
{% for entity in states.button %}
  {%- if 'marstek' in entity.entity_id %}
- {{ entity.entity_id }} ({{ entity.name }})
  {%- endif %}
{%- endfor %}

Marstek SOC Sensors:
{% for entity in states.sensor %}
  {%- if 'marstek' in entity.entity_id and ('soc' in entity.entity_id or 'charge' in entity.entity_id) %}
- {{ entity.entity_id }} = {{ entity.state }}%
  {%- endif %}
{%- endfor %}
```

3. **Controleer** of deze buttons bestaan:
   - ✅ `button.marstek_venuse_d828_auto_mode`
   - ✅ `button.marstek_venuse_d828_manual_mode`
   - ✅ `button.marstek_venuse_3_0_9a7d_auto_mode`
   - ✅ `button.marstek_venuse_3_0_9a7d_manual_mode`
   - ✅ `button.marstek_venuse_auto_mode`
   - ✅ `button.marstek_venuse_manual_mode`

4. Als de namen NIET kloppen, noteer de juiste namen en pas deze aan in `ha-marstek-battery-rotation.yaml`

### Optie B: Via Python Script (Geavanceerd)

1. Edit `verify-entities.py`:
   ```python
   HA_URL = "http://192.168.0.XXX:8123"  # Je HA IP adres
   HA_TOKEN = "eyJhbG..."  # Long-Lived Access Token
   ```

2. Run het script:
   ```bash
   pip install requests
   python verify-entities.py
   ```

---

## Stap 2: Installeer de Configuratie

### Optie A: Via packages (Aanbevolen - Alles in 1 file)

1. Controleer of packages enabled zijn in `configuration.yaml`:
   ```yaml
   homeassistant:
     packages: !include_dir_named packages
   ```

2. Maak de packages map aan (als die nog niet bestaat):
   ```bash
   mkdir config/packages
   ```

3. Kopieer het configuratie bestand:
   ```bash
   cp ha-marstek-battery-rotation.yaml config/packages/
   ```

4. Herstart Home Assistant

### Optie B: Via gesplitste configuratie

1. Open je Home Assistant configuratie (bijv. via File Editor add-on)

2. **Voeg toe aan `configuration.yaml`:**
   ```yaml
   # Template sensors
   template: !include templates.yaml

   # Input helpers
   input_text: !include input_text.yaml
   input_number: !include input_number.yaml
   input_datetime: !include input_datetime.yaml
   input_boolean: !include input_boolean.yaml

   # Automations
   automation manual: !include automations.yaml

   # Scripts
   script: !include scripts.yaml
   ```

3. Maak de individuele files aan en kopieer de relevante secties uit `ha-marstek-battery-rotation.yaml`

4. Check configuratie: **Developer Tools → YAML → Check Configuration**

5. Herstart Home Assistant

---

## Stap 3: Eerste Start

Na herstart verschijnen er automatisch:

### Input Helpers (Instellingen → Apparaten en diensten → Helpers)
- ✅ Batterij Rotatie Systeem (aan/uit)
- ✅ Switch Hysteresis - Zon (500W)
- ✅ Switch Hysteresis - Net (200W)
- ✅ Minimale Tijd Tussen Switches (5 min)
- ✅ Minimale SOC voor Ontladen (15%)
- ✅ Maximale SOC voor Laden (90%)

### Sensors (Developer Tools → States)
- ✅ `sensor.battery_emptiest`
- ✅ `sensor.battery_fullest`
- ✅ `sensor.battery_status_overview`

### Automations (Instellingen → Automations)
- ✅ Marstek: Morning Battery A Start
- ✅ Marstek: Solar Excess - Switch to Emptiest
- ✅ Marstek: Grid Consumption - Switch to Fullest

### Scripts (Developer Tools → Services)
- ✅ `script.marstek_activate_fase_a`
- ✅ `script.marstek_activate_fase_b`
- ✅ `script.marstek_activate_fase_c`
- ✅ `script.marstek_all_batteries_auto`
- ✅ `script.marstek_all_batteries_manual`

---

## Stap 4: Testen

### Test 1: Manuele Script Test

1. Ga naar **Developer Tools → Services**
2. Test elk script:
   ```yaml
   service: script.marstek_activate_fase_a
   ```
3. Controleer of:
   - ✅ Fase A naar Auto mode gaat
   - ✅ Fase B en C naar Manual mode gaan
   - ✅ `input_text.active_battery_fase` = "fase_a"

### Test 2: Emergency Stop

Test de emergency stop:
```yaml
service: script.marstek_all_batteries_manual
```
**Alle batterijen moeten naar Manual mode gaan.**

### Test 3: Sensor Test

Ga naar **Developer Tools → Template** en test:
```jinja2
Leegste batterij: {{ states('sensor.battery_emptiest') }} ({{ state_attr('sensor.battery_emptiest', 'soc') }}%)
Volste batterij: {{ states('sensor.battery_fullest') }} ({{ state_attr('sensor.battery_fullest', 'soc') }}%)

SOC's:
- Fase A: {{ states('sensor.marstek_venuse_d828_state_of_charge') }}%
- Fase B: {{ states('sensor.marstek_venuse_3_0_9a7d_state_of_charge') }}%
- Fase C: {{ states('sensor.marstek_venuse_state_of_charge') }}%
```

### Test 4: Automation Test (DRY RUN)

**⚠️ Zet eerst het systeem UIT om ongewenste switches te voorkomen!**

1. Zet `input_boolean.battery_rotation_enabled` op **OFF**
2. Ga naar **Developer Tools → States**
3. Wijzig **manueel** `sensor.p1_meter_power` naar:
   - `-1000` (zou solar excess moeten triggeren na 2 min)
   - `+500` (zou grid consumption moeten triggeren na 2 min)
4. Check of de automations correct triggeren (zie logboek)
5. Zet het systeem weer **ON** als alles werkt

---

## Stap 5: Dashboard Maken (Optioneel)

Maak een mooi dashboard om alles te monitoren:

```yaml
type: vertical-stack
cards:
  # Status Header
  - type: markdown
    content: >
      ## 🔋 Marstek Batterij Rotatie

      **Actieve Batterij:** {{ states('input_text.active_battery_fase')|replace('fase_a', 'Fase A (schuin)')|replace('fase_b', 'Fase B (plat)')|replace('fase_c', 'Fase C (geen)') }}

      **P1 Meter:** {{ states('sensor.p1_meter_power') }}W
      {% if states('sensor.p1_meter_power')|float < 0 %}
        ☀️ Teruglevering
      {% else %}
        ⚡ Verbruik
      {% endif %}

  # Systeem aan/uit
  - type: entities
    title: Systeem
    entities:
      - entity: input_boolean.battery_rotation_enabled
        name: Batterij Rotatie

  # SOC Overzicht
  - type: horizontal-stack
    cards:
      - type: gauge
        entity: sensor.marstek_venuse_d828_state_of_charge
        name: Fase A (schuin)
        min: 0
        max: 100
        severity:
          green: 50
          yellow: 20
          red: 0

      - type: gauge
        entity: sensor.marstek_venuse_3_0_9a7d_state_of_charge
        name: Fase B (plat)
        min: 0
        max: 100
        severity:
          green: 50
          yellow: 20
          red: 0

      - type: gauge
        entity: sensor.marstek_venuse_state_of_charge
        name: Fase C (geen)
        min: 0
        max: 100
        severity:
          green: 50
          yellow: 20
          red: 0

  # Sensor Info
  - type: entities
    title: Automatische Selectie
    entities:
      - entity: sensor.battery_emptiest
        name: Leegste Batterij
      - entity: sensor.battery_fullest
        name: Volste Batterij
      - entity: input_datetime.last_battery_switch
        name: Laatste Switch

  # Manuele Controles
  - type: horizontal-stack
    cards:
      - type: button
        name: Fase A
        icon: mdi:battery-charging-50
        tap_action:
          action: call-service
          service: script.marstek_activate_fase_a

      - type: button
        name: Fase B
        icon: mdi:battery-charging-50
        tap_action:
          action: call-service
          service: script.marstek_activate_fase_b

      - type: button
        name: Fase C
        icon: mdi:battery-charging-50
        tap_action:
          action: call-service
          service: script.marstek_activate_fase_c

  # Emergency Stop
  - type: button
    name: 🛑 STOP - Alle naar Manual
    icon: mdi:stop-circle
    tap_action:
      action: call-service
      service: script.marstek_all_batteries_manual
    hold_action:
      action: none

  # Instellingen
  - type: entities
    title: ⚙️ Instellingen
    entities:
      - entity: input_number.battery_switch_hysteresis_solar
        name: Hysteresis Zon
      - entity: input_number.battery_switch_hysteresis_grid
        name: Hysteresis Net
      - entity: input_number.battery_switch_delay_minutes
        name: Switch Delay
      - entity: input_number.battery_min_soc_discharge
        name: Min SOC Ontladen
      - entity: input_number.battery_max_soc_charge
        name: Max SOC Laden
```

---

## Stap 6: Live Monitoring

### Logboek Bekijken

1. Ga naar **Instellingen → Systeem → Logboeken**
2. Filter op "Marstek" om alle battery switches te zien

### Notifications

Alle battery switches genereren een **persistent notification** met:
- ☀️ Zonoverschot detectie
- ⚡ Netverbruik detectie
- Details over welke batterij actief wordt

---

## Troubleshooting

### ❌ Automation triggert niet

**Check:**
1. Is `input_boolean.battery_rotation_enabled` **ON**?
2. Is laatste switch > 5 minuten geleden?
3. Is P1 power boven/onder de hysteresis drempel?
4. Check automation traces: **Instellingen → Automations → [Automation] → Traces**

### ❌ Button press faalt

**Check:**
1. Zijn de button entity names correct? (zie Stap 1)
2. Is de batterij online in Home Assistant?
3. Check de logs voor API errors

### ❌ Template sensors tonen 0% of Unknown

**Check:**
1. Zijn de SOC sensor names correct?
2. Zijn de batterijen zichtbaar in HA?
3. Test de template in Developer Tools → Template

### ⚠️ Batterij blijft switchen (flapping)

**Verhoog:**
- `input_number.battery_switch_hysteresis_solar` (bijv. 1000W)
- `input_number.battery_switch_hysteresis_grid` (bijv. 500W)
- `input_number.battery_switch_delay_minutes` (bijv. 10 min)

---

## Fine-tuning

Na een paar dagen monitoren kun je de instellingen aanpassen:

### Bij veel zon
- Verlaag `battery_switch_hysteresis_solar` → Switch sneller naar leegste batterij

### Bij weinig verbruik
- Verhoog `battery_min_soc_discharge` → Houd meer reserve in batterijen

### Bij frequent switchen
- Verhoog `battery_switch_delay_minutes` → Minder vaak switchen

---

## Veiligheid

### Emergency Stop
Gebruik altijd `script.marstek_all_batteries_manual` om het systeem te stoppen bij problemen!

### Monitoring
- Controleer de eerste week dagelijks de logs
- Let op batterij temperaturen
- Monitor SOC gedrag

### Disable Rotatie
Zet `input_boolean.battery_rotation_enabled` op **OFF** om:
- Te testen
- Handmatig batterijen te beheren
- Bij problemen

---

## Support

Heb je problemen? Check:
1. Home Assistant logs (Instellingen → Systeem → Logboeken)
2. Marstek Local API diagnostics (Instellingen → Integraties → Marstek → Diagnostics)
3. Automation traces (Instellingen → Automations → [Select] → Traces)

Voor vragen over de Marstek API:
- GitHub: https://github.com/jaapp/ha-marstek-local-api
- Home Assistant Community: https://community.home-assistant.io/

---

**Succes met je intelligente batterij rotatie systeem! 🔋⚡**
