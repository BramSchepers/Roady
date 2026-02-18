# -*- coding: utf-8 -*-
"""Add chapter_05 (Autoweg, snelheid, verkeersborden, regels) to TheorieRoady CSV."""
import csv

CHAPTER_TITLE = "Autoweg, snelheid, verkeersborden, regels"

# lesson_id, title_nl, description_nl - content from gratisrijbewijsonline.be
CHAPTER_05_LESSONS = [
    (
        "lesson_05_01",
        "Wat is een autoweg?",
        """Een **autoweg** is een openbare weg: **begin** wordt aangegeven door het eerste aanwijzingsbord, **einde** door het tweede bord.

**Verschil met autosnelweg:** Op een autoweg kunnen **kruispunten** en **verkeerslichten** voorkomen.

**Niet toegelaten** op een autoweg:
- Bromfietsen
- Landbouwvoertuigen
- Vierwielers zonder passagiersruimte
- Slepen van kermisvoertuigen

**Rijbanen:** De rijrichtingen kunnen gescheiden zijn door een **wegmarkering** of door een **middenberm**. Een rijbaan kan twee of meer rijstroken hebben. Bestuurders mogen niet rijden op de **links gelegen rijbaan** (bij wegen met twee of meer rijbanen gescheiden door berm of ontoegankelijke ruimte).""",
    ),
    (
        "lesson_05_02",
        "Snelheid – middenberm (120 km/u)",
        """**Buiten de bebouwde kom** mag je **120 km/u** rijden als:
- elke rijrichting **minstens 2 rijstroken** heeft, en
- de rijrichtingen gescheiden zijn door een **middenberm**.

**Verkeersborden** kunnen een **lagere** maximumsnelheid opleggen.

**Binnen de bebouwde kom:** max. **50 km/u** (in het **Brusselse gewest 30 km/u**).""",
    ),
    (
        "lesson_05_03",
        "Snelheid – wegmarkering (geen middenberm)",
        """Op wegen **buiten de bebouwde kom** waar de rijrichtingen alleen door **wegmarkering** gescheiden zijn (geen middenberm):

- **Vlaams en Brussels gewest:** **70 km/u**
- **Waals gewest:** **90 km/u**

Verkeersborden kunnen andere maximumsnelheden opleggen.

**Binnen de bebouwde kom:** max. **50 km/u** (Brussels gewest **30 km/u**).""",
    ),
    (
        "lesson_05_04",
        "Minimumsnelheid en te snel rijden",
        """Op een autoweg geldt **geen minimumsnelheid**. **Te traag** rijden zodat je anderen hindert en iedereen je moet inhalen, is wel een **overtreding**.

**Te snel rijden – gevolgen:**
- **Meer dan 40 km/u** te snel (buiten bebouwde kom) of **meer dan 30 km/u** (binnen bebouwde kom): **vervallenverklaring** van het recht tot besturen (**8 dagen tot 5 jaar**).
- **Voorlopig rijbewijs B:** normaal **opnieuw theorie- en praktijkexamen** afleggen.""",
    ),
    (
        "lesson_05_05",
        "Pech of ongeval op de autoweg",
        """**Gevarendriehoek:** Bij pech of ongeval op een **autoweg** op **min. 30 m** vóór de auto plaatsen (op **autosnelweg 100 m**). Altijd **zichtbaar vanop 50 m** voor aankomende bestuurders.

**Fluojasje:** Als je op een autoweg stopt op een plaats waar je **niet mag parkeren** (pech/ongeval), moet de **bestuurder** een **fluojasje** dragen zodra hij uitstapt. Passagiers hoeft niet, maar dragen het best ook.

**Verplicht in de auto:** fluojasje, gevarendriehoek, verbanddoos, brandblustoestel.""",
    ),
    (
        "lesson_05_06",
        "Inhalen op de autoweg",
        """**Rechterrijstrook** zoveel mogelijk gebruiken. Trager rijdende bestuurder **links** inhalen. **Rechts inhalen** is een **zware overtreding**.

**File:** Bij zeer druk verkeer en file telt het niet als inhalen als het verkeer op de rechterrijstrook iets sneller gaat dan op de linker (wegcode).""",
    ),
    (
        "lesson_05_07",
        "Verboden op de autoweg",
        """**Op een autoweg is verboden:**

- **Parkeren** of **stoppen** op de rijbaan of de pechstrook (ook op **in- en uitritten**).
- Rijden op de **middenberm** of **dwarsverbindingen**.
- **Achteruit** rijden (ook als je een afrit hebt gemist).
- **Tegen de rijrichting** in rijden (spookrijder).
- Een voertuig **slepen met noodoplossing** (bijv. touw). Op een gewone weg mag dat wel, max. **25 km/u**.""",
    ),
]


def main():
    input_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"
    output_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"

    with open(input_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)

    for lesson_id, title_nl, description_nl in CHAPTER_05_LESSONS:
        row = [
            "chapter_05",
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

    print(f"Added chapter_05 with {len(CHAPTER_05_LESSONS)} lessons. Written to: {output_path}")


if __name__ == "__main__":
    main()
