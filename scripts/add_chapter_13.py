# -*- coding: utf-8 -*-
"""Add chapter_13 (Kruisen van voertuigen, wegversmalling) to TheorieRoady CSV."""
import csv

CHAPTER_TITLE = "Kruisen van voertuigen, wegversmalling"

# lesson_id, title_nl, description_nl - content from gratisrijbewijsonline.be
CHAPTER_13_LESSONS = [
    (
        "lesson_13_01",
        "Rechts kruisen – waar mag je rijden?",
        """**Kruisen** = een **tegenligger passeren**. Voertuigen moeten **zo veel mogelijk rechts** op de rijbaan rijden (bij rijstroken: **rechterrijstrook**), zodat er **rechts** veilig gekruist kan worden.

Is de rijbaan **erg smal**, dan mag je tijdens het kruisen ook over de **gelijkgrondse berm** rijden.""",
    ),
    (
        "lesson_13_02",
        "Waar mag je niet rijden om te kruisen?",
        """**Niet** gebruiken om te kruisen:
- Het gedeelte **rechts van de brede witte streep** (de **denkbeeldige rand van de rijbaan**): daar kunnen voertuigen parkeren of stilstaan; daar mag je **niet** rijden om te kruisen.
- Een **fietspad** (geen onderdeel van de rijbaan).

**Wel** toegelaten: op een **fietssuggestiestrook** rijden om te kruisen (die is wél onderdeel van de rijbaan).""",
    ),
    (
        "lesson_13_03",
        "Onderlinge afstand en fietsers",
        """Bij het kruisen moet je een **voldoende zijdelingse afstand** laten. Indien nodig **naar rechts uitwijken**. Je mag daarbij de **gelijkgrondse berm** gebruiken, **niet** het fietspad of de parkeerplaatsen rechts van de denkbeeldige rand.

**Fietser kruisen:** **1 m** afstand **binnen** de bebouwde kom, **1,5 m** **buiten** de bebouwde kom.

Als de rijbaan het kruisen **niet gemakkelijk** toelaat, mag je de **vlakke berm** gebruiken, op voorwaarde dat je de gebruikers daar **niet in gevaar** brengt.""",
    ),
    (
        "lesson_13_04",
        "Tram kruisen en kruispunt",
        """**Tram** kruisen gebeurt normaal **rechts**. Je mag een tram **links** kruisen **alleen** als: de doorgang te **eng** is om rechts te kruisen; er een **geparkeerd of stilstaand** voertuig staat; of er een **hindernis** is. Bij links kruisen **geen tegenligger** hinderen of in gevaar brengen — check **op voorhand** of er een tegenligger aankomt.

**Kruispunt zonder pijlen** op het wegdek → kruisen **langs rechts**. **Met pijlen** → kruisen **volgens de pijlen**.""",
    ),
    (
        "lesson_13_05",
        "Rijbaanversmalling – voorrang",
        """**Gevaarsborden A7a, A7b, A7c** kondigen een **rijbaanversmalling** aan (versmalling, links of rechts).

**Zonder borden:** De bestuurder **langs wiens zijde de hindernis** is, moet **voorrang verlenen**. De andere mag eerst.

**Met borden:** **B19** (rood) = **voorrang verlenen** aan tegenliggers. **B21** (blauw) = je hebt **voorrang** en mag als eerste. Verwar **B19** niet met **A39** (verkeer weer in twee richtingen na eenrichtingsgedeelte).""",
    ),
    (
        "lesson_13_06",
        "Eenrichtingsverkeer",
        """**Bord F19** (of gelijkaardig) = **weg met eenrichtingsverkeer**. Je kruist daar normaal geen tegenliggers. Een **wit onderbord** kan aangeven dat **fietsers** of **bromfietsers klasse A** in **tegengestelde richting** mogen rijden.

Op een eenrichtingsweg **rechts houden** (tenzij uitzondering). **Parkeren** mag **rechts én links**, op voorwaarde dat er **min. 3 m** vrije ruimte blijft tussen de voertuigen.

**Verschil:** **F19** = aanwijzingsbord (eenrichtings**weg**). **D1a** = gebodsbord (**verplicht** de aangeduide richting te volgen).""",
    ),
    (
        "lesson_13_07",
        "Naar links afslaan",
        """Wil je **naar links** afslaan, dan moet je je **zo veel mogelijk links** opstellen; bij meerdere rijstroken op de **linker rijstrook** (voorsorteren).

Als **fietsers of bromfietsen** in **tegengestelde richting** mogen rijden (onderbord), moet je **voldoende plaats** voor hen laten.""",
    ),
]


def main():
    input_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"
    output_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"

    with open(input_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)

    for lesson_id, title_nl, description_nl in CHAPTER_13_LESSONS:
        row = [
            "chapter_13",
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

    print(f"Added chapter_13 with {len(CHAPTER_13_LESSONS)} lessons. Written to: {output_path}")


if __name__ == "__main__":
    main()
