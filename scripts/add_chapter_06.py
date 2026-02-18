# -*- coding: utf-8 -*-
"""Add chapter_06 (Bebouwde kom, zone, woonerf, speelstraat) to TheorieRoady CSV."""
import csv

CHAPTER_TITLE = "De bebouwde kom, zone, woonerf, speelstraat"

# lesson_id, title_nl, description_nl - content from gratisrijbewijsonline.be
CHAPTER_06_LESSONS = [
    (
        "lesson_06_01",
        "Wat is de bebouwde kom?",
        """De **bebouwde kom** is een gebied waarvan de **invalswegen** worden aangegeven door een **aanwijzingsbord** (begin bebouwde kom: F1a of F1b). Je **verlaat** de bebouwde kom zodra je voorbij een **einde bebouwde kom**-bord (F3a of F3b) rijdt.

**Let op:** Het **gele bord met rode rand** (administratief begin van een gemeente) geeft **geen** begin van bebouwde kom aan en heeft verder **geen verkeersbetekenis**.""",
    ),
    (
        "lesson_06_02",
        "Snelheid in de bebouwde kom",
        """**Standaard:** Binnen de bebouwde kom is de max. snelheid in **Vlaanderen en Wallonië** **50 km/u**. In het **Brusselse gewest** **30 km/u**.

**Meer dan 30 km/u** te snel in de bebouwde kom → **vervallenverklaring** van het recht tot besturen (8 dagen tot 5 jaar).

**Uitzondering:** Een verkeersbord **op** of **voorbij het beginbord** kan een andere snelheid opleggen (bijv. 70 km/u **tot het eerstvolgende kruispunt**). Een bord **30 net boven** het bord \"begin bebouwde kom\" geldt in de **hele** bebouwde kom (alleen voor 30).""",
    ),
    (
        "lesson_06_03",
        "Snelheid bij verlaten bebouwde kom",
        """Verlaat je de bebouwde kom, dan mag je op gewone wegen (tenzij borden anders zeggen):

- **Vlaams gewest:** max. **70** km/u
- **Waals gewest:** max. **90** km/u
- **Brusselse gewest** (vanaf 1/1/2021): **70** km/u buiten bebouwde kom, **30** km/u binnen bebouwde kom

Een bord kan een lagere snelheid opleggen **tot en met het eerstvolgende kruispunt**.""",
    ),
    (
        "lesson_06_04",
        "Woonerf",
        """**Begin** woonerf: eerste aanwijzingsbord (F12a). **Einde**: tweede bord (F12b).

Bestuurders (fiets, motor, auto) mogen **voetgangers** op de rijbaan **niet in gevaar brengen of hinderen**. **Dubbel voorzichtig** voor **kinderen die op de rijbaan mogen spelen**.

**Snelheid:** max. **20 km/u**. Meer dan **30 km/u** te snel in een woonerf → vervallenverklaring (8 dagen tot 5 jaar).

**Parkeren:** Alleen **op voorziene parkeerplaatsen**. Je mag daar **rechts of links** ten opzichte van je rijrichting parkeren.""",
    ),
    (
        "lesson_06_05",
        "Speelstraat",
        """In een **speelstraat** is de **ganse breedte** van de openbare weg **voorbehouden voor spelen**.

**Toegelaten:** Bestuurders van motorvoertuigen die in die straat **wonen**, of wiens **garage** in die straat ligt, en **prioritaire voertuigen**.

**Regels:** Alleen **stapvoets** rijden. **Fietsers** moeten indien nodig **afstappen** als ze voetgangers of kinderen hinderen. Alle bestuurders **dubbel voorzichtig** ten aanzien van kinderen.""",
    ),
    (
        "lesson_06_06",
        "Zone (o.a. Zone 30)",
        """Een **zone** bestaat uit **een of meerdere openbare wegen**. **Begin** = begin zonebord, **einde** = einde zonebord. De verplichting die je bij het binnenrijden meekrijgt, geldt **dag en nacht** zolang je in de zone bent.

**Elektronisch zonebord:** De verplichting geldt **alleen als het bord oplicht**.

**Zone 30:** Max. **30 km/u**. Meer dan **30 km/u** te snel in een Zone 30 → vervallenverklaring (8 dagen tot 5 jaar).""",
    ),
    (
        "lesson_06_07",
        "Schoolomgeving en schoolstraat",
        """**Schoolomgeving:** Zone van een of meerdere wegen waar de toegang tot een school in ligt, afgebakend door de bijbehorende verkeersborden.

**Schoolstraat:** Een straat nabij een school kan **twee keer per dag** afgesloten worden voor motorvoertuigen (bord **C3** + onderbord **SCHOOLSTRAAT**). Toegelaten: **voetgangers, fietsers, speed pedelecs**; **bewoners/garage** met vergunning; **prioritaire voertuigen**; voertuigen met vergunning.

**Snelheid:** **Stapvoets**. Bij snelheidsborden (bijv. 30) geldt die limiet. **Voorrang** aan voetgangers en fietsers; hen niet in gevaar brengen of hinderen.""",
    ),
    (
        "lesson_06_08",
        "Voorbehouden weg",
        """Sommige wegen zijn **voorbehouden voor bepaalde weggebruikers**. Het **begin** wordt aangeduid door een aanwijzingsbord; **emblemen** in het bord tonen wie toegelaten is.

**Max. snelheid** op zo'n weg: **30 km/u**. Bestuurders moeten **dubbel voorzichtig** zijn ten aanzien van **kinderen**.""",
    ),
    (
        "lesson_06_09",
        "Bijzondere overrijdbare bedding",
        """Een **bijzondere overrijdbare bedding** is voorbehouden voor **trams en bussen**. Andere voertuigen mogen er **niet** op rijden, behalve:
- om **omheen een hindernis** te rijden, of
- als **onderborden** aangeven dat bepaalde bestuurders het mogen (bijv. fiets, bromfiets, motor).

**Dwarsen** mag wel om: een **parkeerplaats** langs de bedding in te nemen of te verlaten, een **eigendom** op te rijden of te verlaten, en op **kruispunten**.""",
    ),
    (
        "lesson_06_10",
        "Fietszone (kort)",
        """Een **fietszone**: fietsers (en rijwielen, speed pedelecs) zijn de belangrijkste weggebruikers; motorvoertuigen zijn \"te gast\". **Motorvoertuigen** mogen **fietsers, speed pedelecs en rijwielen tot 1 m** **niet inhalen**. Max. snelheid **30 km/u**. Einde bij bord **EINDE ZONE**.

**Fietsstraat** is uit de wegcode geschrapt (KB 12/3/2023), maar **borden** mogen tot **1 januari 2032** blijven staan.""",
    ),
]


def main():
    input_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"
    output_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"

    with open(input_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)

    for lesson_id, title_nl, description_nl in CHAPTER_06_LESSONS:
        row = [
            "chapter_06",
            CHAPTER_TITLE,
            "",
            "",
            "",
            lesson_id,
            title_nl,
            description_nl,
            "",
            "",
            "",
            "",
            "",
            "",
        ]
        rows.append(row)

    with open(output_path, "w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerows(rows)

    print(f"Added chapter_06 with {len(CHAPTER_06_LESSONS)} lessons. Written to: {output_path}")


if __name__ == "__main__":
    main()
