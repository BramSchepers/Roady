# -*- coding: utf-8 -*-
"""Add chapter_04 (Autosnelweg, oprit, afrit, pechstrook, spitsstrook) to TheorieRoady CSV."""
import csv

CHAPTER_TITLE = "Autosnelweg, oprit, afrit, pechstrook, spitsstrook"

# lesson_id, title_nl, description_nl - content from gratisrijbewijsonline.be
CHAPTER_04_LESSONS = [
    (
        "lesson_04_01",
        "Wat is een autosnelweg?",
        """Een **autosnelweg** is een openbare weg: **begin/oprit** wordt aangeduid door het eerste aanwijzingsbord (**F5**), **einde/afrit** door het tweede bord (**F7**).

Er zijn geen verkeerslichten of voorrangskruispunten.

**Niet toegelaten** op de autosnelweg:
- Bromfietsen
- Landbouwvoertuigen
- Vierwielers zonder passagiersruimte
- Slepen van kermisvoertuigen""",
    ),
    (
        "lesson_04_02",
        "Snelheid op de autosnelweg",
        """**Maximum:** Tot **120 km/u** op de rijstroken (als omstandigheden en borden/bevoegde personen het toelaten). Verkeersborden kunnen per rijstrook verschillen (bijv. linker stroken 90, rechter 70).

**Minimum:** **70 km/u** (als omstandigheden het toelaten). Voertuigen die dat niet halen (bromfiets, tractor, slepen) mogen niet op de autosnelweg.

**Afrit:** Soms geldt op de afrit een lagere limiet (bijv. **90 km/u**), aangegeven met borden.

**Smog:** Bij windstil weer kan tijdelijk **max. 90 km/u** op autosnelwegen worden opgelegd (elektronische borden of **C43 + onderbord SMOG**).

**Spijkerbanden** (1 nov–31 mrt, voertuigen tot 3,5 ton): op autosnelwegen en 2×2-wegen **max. 90 km/u**, op gewone wegen **max. 60 km/u**.""",
    ),
    (
        "lesson_04_03",
        "Te snel rijden – gevolgen",
        """**Meer dan 40 km/u te snel op autosnelweg** (of autoweg/gewone weg): **vervallenverklaring** van het recht tot besturen (rechter): **8 dagen tot 5 jaar** geen rijbewijs. In bebouwde kom/zone 30/woonerf: al bij **meer dan 30 km/u** te snel.

**Meer dan 30 km/u te snel** op autosnelweg/autoweg/gewone weg: **onmiddellijke tijdelijke intrekking** door de **politie**. In bebouwde kom/zone 30/woonerf: al bij **meer dan 20 km/u** te snel.

**Voorlopig rijbewijs:** Bij zware overtreding meestal **opnieuw theorie- en praktijkexamen** afleggen.""",
    ),
    (
        "lesson_04_04",
        "Pechstrook",
        """Aan de buitenrand van de rechterrijstrook: **dikke witte doorlopende lijn** → daarnaast de **pechstrook**.

Op de pechstrook mag je **niet rijden**, **niet stilstaan**, **niet parkeren** (ook niet voor een kaart of gsm). Alleen **politie** en **takeldiensten** (naar een ongeval) mogen er rijden.

**Gebruik:** Alleen **bij pech of ongeval**. Passagiers en bestuurder wachten het best **achter de vangrails**. Op autosnelwegen en autowegen mag je **niet zelf slepen** (op gewone wegen met noodkoppeling max. **25 km/u**).

**Gevarendriehoek:** Op de pechstrook op **min. 100 m** vóór je voertuig plaatsen (op gewone wegen **30 m**); zichtbaar vanop **50 m**.

**Fluojasje:** Bestuurder die uitstapt **moet** een fluojasje dragen (verplicht in de auto). **Alarmnummer: 112**.""",
    ),
    (
        "lesson_04_05",
        "Reddingsstrook en spookrijders",
        """**Reddingsstrook:** Bij file moeten bestuurders op een rijbaan met **twee of meer doorgaande rijstroken** in hun rijrichting **preventief** een reddingsstrook vormen (vóór het verkeer stilstaat). Twee rijstroken: tussen **links en rechts**. Drie rijstroken: tussen **links en midden**. Rechterrijstrook mag in principe niet uitwijken naar spitsstrook, pechstrook of busstrook.

**Spookrijder:** **Vertragen** en **rechts rijden** (in uiterste nood op de pechstrook). Eventueel **knipperen met lichten** wanneer je de spookrijder kruist (niet eerder). **Spookrijder melden** bij de politie.""",
    ),
    (
        "lesson_04_06",
        "Spitsstrook",
        """Een **spitsstrook** is een **extra rijstrook** waar niet altijd mag gereden worden. Gescheiden door een **streeplijn** (lange witte strepen 10 m, tussenafstand 2,5 m).

- **Groene pijl** boven de strook: je **mag** erop rijden. Vaak een lagere max. snelheid. Bij pech **niet** op de spitsstrook stoppen maar naar een **vluchthaven** rijden.
- **Rood kruis**: je **mag er niet** op rijden (behalve diensten met toelating). Andere bestuurders alleen om op te rijden of te verlaten.""",
    ),
    (
        "lesson_04_07",
        "Inhalen op de autosnelweg",
        """**Rechterrijstrook** zoveel mogelijk gebruiken. Trager rijdende bestuurder **links** inhalen. **Rechts inhalen** is een **zware overtreding**.

**File:** Als het verkeer op de rechterrijstrook iets sneller gaat dan links, geldt dat in de wegcode **niet** als inhalen.

**Motorfietsen bij file:** Mogen **tussen de twee linkse rijstroken** rijden, max. **20 km/u** sneller dan het verkeer en max. **50 km/u**. Autobestuurders rijden best **links op de linkerrijstrook** zodat motorfietsers kunnen passeren.""",
    ),
    (
        "lesson_04_08",
        "Oprijden – invoegstrook",
        """Naast de rijstroken ligt de **invoegstrook**. Bij zeer druk verkeer: geleidelijk vertragen en eventueel op de invoegstrook stoppen tot je veilig kunt invoegen.

- **Versnel** op de invoegstrook tot je ongeveer dezelfde snelheid hebt als het verkeer op de rechterrijstrook. Je hoeft **niet** tot het einde van de strook te rijden om in te voegen.
- **Voorrang verlenen** aan bestuurders die al op de autosnelweg rijden. Bestuurders op de rechterrijstrook mogen vrijwillig naar links uitwijken. Wie net heeft ingehaald, mag even links blijven om invoegen mogelijk te maken.
- **Niet ritsen:** Bij invoegen wordt er **geen** geritst; richtingaanwijzer aan en voorrang verlenen.""",
    ),
    (
        "lesson_04_09",
        "Afrit",
        """Een autosnelweg verlaat je via de **afrit**. Rijd **zo vroeg mogelijk** op de afrit (dicht bij waar hij begint), niet in het midden of pas op het einde.

**Afremmen** doe je **pas op de afrit**, niet op de rijstroken.""",
    ),
    (
        "lesson_04_10",
        "Verboden en verkeerswisselaar",
        """**Verboden op de autosnelweg:**
- Parkeren op de rijstrook, pechstrook, **oprit of afrit**
- Over de **dwarsverbinding** of **middenberm** rijden
- **Achteruit** rijden (ook als je een afrit hebt gemist)
- In **tegenovergestelde richting** rijden (spookrijden)
- **Slepen** met noodkoppeling (sinds 1 maart 2014)

**Verkeerswisselaar:** Plaats waar **twee autosnelwegen** samenkomen; je kunt er van de ene naar de andere rijden. Wordt op voorwegwijzers aangekondigd (bijv. 1600 m verder).

**Voorlopig rijbewijs B:** Je mag in België met de auto of motorfiets op de autosnelweg rijden.""",
    ),
]


def main():
    input_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"
    output_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"

    with open(input_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)

    for lesson_id, title_nl, description_nl in CHAPTER_04_LESSONS:
        row = [
            "chapter_04",
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

    print(f"Added chapter_04 with {len(CHAPTER_04_LESSONS)} lessons. Written to: {output_path}")


if __name__ == "__main__":
    main()
