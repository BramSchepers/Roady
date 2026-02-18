# -*- coding: utf-8 -*-
"""Add chapter_11 (Maximumsnelheid op de openbare weg) to TheorieRoady CSV."""
import csv

CHAPTER_TITLE = "Maximumsnelheid op de openbare weg"

# lesson_id, title_nl, description_nl - content from gratisrijbewijsonline.be
CHAPTER_11_LESSONS = [
    (
        "lesson_11_01",
        "Snelheid op de autosnelweg",
        """Op een **autosnelweg** (ook op- en afrit) is de max. snelheid **120 km/u**, tenzij verkeersborden anders opleggen. **Minimum** onder normale omstandigheden: **70 km/u**.

**Verkeersborden** kunnen per rijstrook verschillen (bijv. linker stroken 90, rechter 70). **Matrixborden** boven de rijstroken kunnen de limiet aanpassen. Nabij **afritten** geldt een snelheidsbeperking soms **alleen op de afrit**. Rem pas wanneer je **op de afrit** rijdt. **Slepen** op auto(snel)weg is **verboden**.

**Spijkerbanden** (1 nov–31 mrt, M.T.M. tot 3,5 ton): op autosnelwegen en 2×2-wegen met berm **max. 90 km/u**, op gewone wegen **max. 60 km/u**.""",
    ),
    (
        "lesson_11_02",
        "Snelheid op de autoweg",
        """Op een **autoweg** is **geen minimumsnelheid**; abnormaal traag rijden is wel een overtreding.

**Buiten bebouwde kom:** **120 km/u** als elke rijrichting **min. 2 rijstroken** heeft en ze gescheiden zijn door een **middenberm**. Geen middenberm maar alleen **wegmarkering**: **Vlaanderen en Brussel 70 km/u**, **Wallonië 90 km/u**. Borden kunnen anders opleggen.

**Binnen bebouwde kom:** **50 km/u** (Brussel sinds 1/1/2021: **30 km/u** binnen bebouwde kom).""",
    ),
    (
        "lesson_11_03",
        "Snelheid op gewone wegen",
        """**Buiten bebouwde kom:** **Vlaanderen** en **Brussel**: **70 km/u**. **Wallonië**: **90 km/u**. **2×2 rijstroken gescheiden door berm**: **120 km/u**.

**Brussel:** 70 km/u buiten bebouwde kom, **30 km/u** binnen bebouwde kom (tenzij anders aangegeven).

**Verbodsborden** kunnen de max. snelheid wijzigen. Een **blauw onderbord** kan aangeven **vanaf waar** de beperking geldt (bijv. 200 m verder tot het eerstvolgende kruispunt).""",
    ),
    (
        "lesson_11_04",
        "Bijzondere plaatsen – snelheidslimieten",
        """- **Woonerf:** **20 km/u**. Dubbel voorzichtig voor kinderen.
- **Bebouwde kom:** **50 km/u** (Vlaanderen, Wallonië), **30 km/u** (Brussel). Uitzondering: bord op/voorbij beginbord kan andere snelheid opleggen (bijv. tot eerstvolgende kruispunt). Bord **30** boven begin bebouwde kom = **30 km/u in hele** bebouwde kom.
- **Zone:** Verplichting **dag en nacht** zolang je in de zone bent. **Elektronisch zonebord:** geldt **alleen als het bord oplicht**.
- **Fietszone:** **30 km/u**. Motorvoertuigen mogen fietsers **niet links en niet rechts** inhalen.
- **Speelstraat:** **Stapvoets**. Doorgang vrij voor voetgangers en kinderen, voorrang verlenen, zo nodig stoppen.
- **Weg voorbehouden** (landbouw, voetgangers, fietsers, ruiters, speed pedelecs…): **30 km/u**.""",
    ),
    (
        "lesson_11_05",
        "Verhoogde inrichting",
        """**Verhoogde inrichting** (KB 12/3/2023): verhoogde aanleg **dwars op de weg** om de snelheid te matigen. Aangekondigd door **gevaarsbord A14** (150 m ervoor) en bij de inrichting **aanwijzingsbord F87** → max. **30 km/u**.

**Verbod:** Een **gespan**, **tweewielig motorvoertuig** of **voertuig met meer dan twee wielen** **links** inhalen. Vanaf 1 april 2023 mag je **fietsers** wel links inhalen op een verhoogde inrichting.

**Stilstaan en parkeren** is **verboden** op elke verhoogde aanleg die de snelheid moet matigen (ook zonder borden).""",
    ),
    (
        "lesson_11_06",
        "Trajectcontrole en te traag rijden",
        """**Trajectcontrole:** Nummerplaatherkenning (ANPR) op **twee meetpunten**; gemiddelde snelheid wordt berekend. Bij te hoge gemiddelde snelheid gaan gegevens naar de federale politie. Detecteert ook geseinde wagens en pechstrookrijders.

**Te traag rijden** is een overtreding, net als **plots remmen** zonder reden. Rij op het praktijkexamen niet zomaar 30 km/u in bebouwde kom of 50 km/u op gewone weg zonder geldige reden.

**Snelheidswedstrijden** op de openbare weg en aanzetten tot te snel rijden = **zware overtreding vierde graad**.""",
    ),
    (
        "lesson_11_07",
        "Onmiddellijke intrekking (politie)",
        """**Onmiddellijke tijdelijke intrekking** van je rijbewijs door de **politie** bij een zware overtreding:

- **Autosnelweg, autoweg, gewone weg:** meer dan **30 km/u** te snel.
- **Bebouwde kom, zone 30, woonerf:** meer dan **20 km/u** te snel.

Bij **elke** zware overtreding kan je rijbewijs onmiddellijk worden ingetrokken.""",
    ),
    (
        "lesson_11_08",
        "Vervallenverklaring (rechter)",
        """**Vervallenverklaring** van het recht tot besturen door de **rechter** (rechtbank):

- **Autosnelweg, autoweg, gewone weg:** meer dan **40 km/u** te snel → **8 dagen tot 5 jaar** geen motorvoertuig besturen.
- **Bebouwde kom, zone 30, woonerf:** meer dan **30 km/u** te snel → idem.

Ook voertuigen waarvoor geen rijbewijs vereist is, mag je dan niet besturen. **Beginnende bestuurders** (< 2 jaar rijbewijs B): strengere regels. Let bij examenvragen op het verschil tussen **intrekking** (politie) en **vervallenverklaring** (rechter).""",
    ),
]


def main():
    input_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"
    output_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"

    with open(input_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)

    for lesson_id, title_nl, description_nl in CHAPTER_11_LESSONS:
        row = [
            "chapter_11",
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

    print(f"Added chapter_11 with {len(CHAPTER_11_LESSONS)} lessons. Written to: {output_path}")


if __name__ == "__main__":
    main()
