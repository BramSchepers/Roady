# -*- coding: utf-8 -*-
"""Add chapter_10 (Lading, zitplaatsen, veiligheidsgordel) to TheorieRoady CSV."""
import csv

CHAPTER_TITLE = "Lading, zitplaatsen, veiligheidsgordel"

# lesson_id, title_nl, description_nl - content from gratisrijbewijsonline.be
CHAPTER_10_LESSONS = [
    (
        "lesson_10_01",
        "Hoogte en breedte van voertuig en lading",
        """**Hoogte:** Auto + lading mag **max. 4 m** hoog zijn. Hoger = **uitzonderlijk vervoer**. Bord **C29** kan een lagere max. hoogte opleggen (bruggen, tunnels). Zware lading of verre rit? Bandenspanning iets verhogen voor vertrek. **Skibox** of **imperiaal** best verwijderen als niet nodig (luchtweerstand, verbruik). Zware voorwerpen **in de koffer**, niet op het dak (balans in bochten). **Fiets** beter achteraan dan op het dak; lading mag **achterlichten en nummerplaat niet bedekken**.

**Breedte:** Voertuig + lading **max. 2,55 m** (breder = uitzonderlijk vervoer). Bord **C27** kan een lagere max. breedte opleggen. Bij brede lading: anderen niet hinderen, niets beschadigen, zicht niet belemmeren, lading laten vastzitten.""",
    ),
    (
        "lesson_10_02",
        "Lengte van de lading",
        """**Vooraan:** Lading mag **nooit voorbij het uiteinde** van de carrosserie uitsteken (bijv. ladder op dakdragers).

**Achteraan:** Max. **1 m** uitsteken.

**Lang ondeelbaar voorwerp** (niet vouwbaar/inschuifbaar): max. **3 m** achter het achterste uiteinde, op voorwaarde dat je het **waarschuwingsbord** voor lading achteraan bevestigt. Bij verplichte verlichting: bord met **rood achterlicht** en **oranje reflector** aan beide zijkanten.""",
    ),
    (
        "lesson_10_03",
        "Verbodsbord lengte (C25)",
        """Bord **C25** verbiedt **alle soorten voertuigen** (niet alleen vrachtwagens) met hun lading, of **slepen**, die **langer** zijn dan de aangeduide lengte, om verder te rijden.

Dit geldt ook voor een **voertuigtrein** (auto + aanhangwagen = voertuigtrein). Rij je met auto + caravan, dan mag je niet voorbij het bord als de totale lengte de limiet overschrijdt.""",
    ),
    (
        "lesson_10_04",
        "Zitplaats en ruimte",
        """**Bestuurder:** Minstens **55 cm** ruimte aan de zijkant (comfort en goed besturen).

**Passagier vooraan:** Minstens **40 cm**.

**Zitbank voor drie personen** vooraan: min. **135 cm** breed (55 + 40 + 40).

**Hoofdsteun:** Zo geplaatst dat de **bovenkant op gelijke hoogte** is met de **kruin** van je hoofd (bescherming en zitpositie).""",
    ),
    (
        "lesson_10_05",
        "Veiligheidsgordel",
        """**Elke zitplaats** moet een **veiligheidsgordel** hebben. **Bestuurder** en **passagiers** moeten de gordel **dragen**. Gordel altijd **boven** je arm, niet eronder.

**Vrijgesteld van gordel:** bestuurder die **achteruit** rijdt; **taxichauffeurs** tijdens het vervoer van klanten; **alleen postbodes** die pakjes van huis tot huis brengen (niet iedereen met pakjes); **bevoegde personen/hulpdiensten** als de job het vereist; **medische vrijstelling** (ministerie). **Zwangere vrouwen** moeten wel een gordel dragen.""",
    ),
    (
        "lesson_10_06",
        "Kinderzitje (AKBS)",
        """**Kinderen tot 18 jaar** en **kleiner dan 1,35 m** **moeten** in een **aangepast veiligheidszitje** of **kinderbeveiligingssysteem** (AKBS) dat aan de normen voldoet. Groter dan 1,35 m **mag** nog in een kinderzitje.

**Niet vooraan:** Kinderen < 18 jaar mogen **niet vooraan** in een **naar achteren gekeerd** kinderzitje, behalve als er **geen voorairbag** is of die **uitgeschakeld** kan worden.

**Uitzonderingen:** o.a. kind > 3 jaar en > 1,35 m, korte rit, niet door ouder bestuurd, uitzonderlijke situatie → gewone gordel, niet vooraan. Als 3 AKBS achterin niet passen: één kind > 3 jaar en > 1,35 m mag achteraan de gewone gordel. **Fout over gordel bij kinderen = 5 punten** op het examen.""",
    ),
    (
        "lesson_10_07",
        "Dode hoek",
        """**Elk voertuig** heeft **dode hoeken**: plekken naast of achter het voertuig die de bestuurder in de spiegels **niet** kan zien.

**Dode-hoekdetectie:** Veel auto's hebben een systeem dat waarschuwt (led in buitenspiegel). Als het **lampje brandt**, **niet** inhalen; wacht tot het uitgaat. **Kijk zelf** ook over je schouder.""",
    ),
    (
        "lesson_10_08",
        "Gevaarlijke lading",
        """**C24a:** Verboden voor voertuigen met bepaalde **gevaarlijke goederen**. **C24b:** ontvlambare/ontplofbare goederen. **C24c:** verontreinigende goederen.

De borden gaan over de **lading** die je **vervoert**, **niet** over de **brandstof** van de auto. Een auto op **LPG** mag dus **wel** voorbij deze borden (het gaat om de lading).""",
    ),
    (
        "lesson_10_09",
        "Aanhangwagen (herhaling)",
        """**Voorlopig rijbewijs:** **Geen** aanhangwagen trekken.

**Definitief rijbewijs B:** Aanhangwagen met M.T.M. tot **750 kg** mag. M.T.M. aanhangwagen **meer dan 750 kg**? Toch toegelaten als **M.T.M. auto + aanhangwagen samen max. 3500 kg** (3,5 ton).""",
    ),
]


def main():
    input_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"
    output_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"

    with open(input_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)

    for lesson_id, title_nl, description_nl in CHAPTER_10_LESSONS:
        row = [
            "chapter_10",
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

    print(f"Added chapter_10 with {len(CHAPTER_10_LESSONS)} lessons. Written to: {output_path}")


if __name__ == "__main__":
    main()
