# -*- coding: utf-8 -*-
"""Add chapter_03 (Fietspad, fietssuggestiestrook, oversteekplaats) to TheorieRoady CSV."""
import csv

CHAPTER_TITLE = "Fietspad, fietssuggestiestrook, oversteekplaats voor fietsers"

# lesson_id, title_nl, description_nl - content from gratisrijbewijsonline.be
CHAPTER_03_LESSONS = [
    (
        "lesson_03_01",
        "Wat is een fietspad?",
        """Een **fietspad** is een **onderdeel van de openbare weg** waarop **fietsers** en **bromfietsers klasse A** moeten rijden. **Bakfietsen** en **drie- en vierwielers** (< 1 m breed) worden gelijkgesteld met fietsen.

Soms moeten ook bromfietsers **klasse B** op een fietspad rijden (onderbord).

**Aanduiding:** door een **gebodsbord** (D7, D9 of D10) of door **twee evenwijdige onderbroken strepen** waartussen geen autoverkeer mogelijk is. Het fietspad kan **links of rechts** van de rijbaan liggen. Rood kleuren mag, maar is niet verplicht.""",
    ),
    (
        "lesson_03_02",
        "Gebodsborden fietspad",
        """- **D9** (voetgangers en fiets naast elkaar): **Fietsers**, **bromfietsers klasse A** en **voetgangers** moeten dit deel gebruiken. **Bromfietsen klasse B** mogen hier **niet** rijden.

- **D10** (voetgangers en fiets onder elkaar): **Fietsers** en **voetgangers** moeten dit deel gebruiken. **Bromfietsen klasse A en B** mogen hier **niet** rijden.

Een **wit onderbord** kan aangeven wanneer bromfietsen klasse B verplicht op het fietspad moeten of wanneer ze het niet mogen.""",
    ),
    (
        "lesson_03_03",
        "Fietsers op het voetpad",
        """**Binnen de bebouwde kom:** Met de fiets op het **trottoir** (voetpad) rijden is **verboden**. **Kinderen jonger dan 10 jaar** mogen wel op het trottoir of de **verhoogde berm** rijden.

**Buiten de bebouwde kom:** Als er **geen berijdbaar fietspad** is, mogen fietsers op het trottoir en de verhoogde berm rijden, op voorwaarde **rechts in de rijrichting**.

Als er een fietspad is, moet de fietser het volgen (behalve als het niet berijdbaar is).""",
    ),
    (
        "lesson_03_04",
        "Fietspad en auto's",
        """Het fietspad is een **onderdeel van de openbare weg**, maar **geen onderdeel van de rijbaan**.

Met de **auto** mag je **niet** op een fietspad rijden. Je mag er ook **niet stilstaan** (bijv. om vlug een passagier te laten in- of uitstappen).""",
    ),
    (
        "lesson_03_05",
        "Oversteekplaats voor fietsers",
        """**Borden:** **F50** (blauw, bij de oversteekplaats) en **A25** (rood gevaarsbord, ca. **150 m** vóór de oversteekplaats).

**Voorrang:** Fietsers/bromfietsers die **nog niet op** de oversteekplaats zijn, hebben **geen** voorrang. Eenmaal **op** de oversteekplaats hebben ze **wel** voorrang.

**Regels voor bestuurders op de rijbaan:**
- **Niet stilstaan** en **niet parkeren op** de oversteekplaats.
- **Niet parkeren** op de rijbaan op **minder dan 5 m vóór** de oversteekplaats.
- **Niet inhalen** van een bestuurder die vertraagt of stopt voor de oversteekplaats (behalve bij verkeerslichten of bevoegde personen).
- Oversteekplaats met **matige snelheid** naderen.""",
    ),
    (
        "lesson_03_06",
        "Fietssuggestiestrook",
        """Op een deel van de rijbaan wordt soms een **gekleurde strook** (roze, groen, beige, enz.) geschilderd. Dat is een **fietssuggestiestrook** — **geen fietspad** (geen twee evenwijdige strepen of fietspadborden).

Het is gewoon **geverfd rijbaan**. Met de auto **moet** je er rijden en je **mag** er stilstaan of parkeren.""",
    ),
    (
        "lesson_03_07",
        "Middenrijbaan",
        """Bij een **middenrijbaan** wordt op smalle wegen het autoverkeer naar het **midden** geleid, afgebakend door **twee evenwijdige onderbroken lijnen**.

De **zijdelingse strook** links en rechts is bestemd voor **fietsers**, **bromfietsers klasse A**, **speed pedelecs**, niet ingespannen trekdieren/rijdieren/vee en **voetgangers** (links in de rijrichting).

Auto's mogen naar de zijdelingse strook **uitwijken** om te kruisen of in te halen, zonder andere weggebruikers te hinderen. **Parkeren** op de middenrijbaan of zijdelingse strook is **verboden**. **Stilstaan** mag op de zijdelingse strook als de berm niet breed genoeg is.

**Snelheid:** Ook in Wallonië **70 km/u** op wegen met middenrijbaan.""",
    ),
    (
        "lesson_03_08",
        "Einde fietspad",
        """Het **gevaarsbord A25** heeft **twee betekenissen**: (1) oversteekplaats voor fietsers (ca. 150 m ervoor), (2) **fietsers/bromfietsers verlaten het fietspad** omdat het **ophoudt**.

**Belangrijk:** Als een fietser/bromfietser de rijbaan oprijdt **omdat het fietspad ophoudt**, heeft hij **voorrang**; bestuurders van auto's en motorfietsen moeten voorrang geven. (Alleen als het fietspad ophoudt, niet bij een hindernis op het fietspad.)

**Verbod:** Niet stilstaan en niet parkeren op de **rijbaan** en op de **berm**, tot **5 m vóór** en **vóórbij** de plaats waar het fietspad ophoudt.""",
    ),
    (
        "lesson_03_09",
        "Fietsers in groep",
        """**Groep 15–50 deelnemers:** Niet verplicht fietspaden te volgen; mogen **met twee naast elkaar** op de rijbaan rijden, gegroepeerd. Alleen van de **rechter rijstrook** gebruikmaken (of max. één strookbreedte / max. helft rijbaan). Mogen voor- en nagevolgd worden door een begeleidende auto (ca. 30 m).

**Groep 51–150 deelnemers:** Zelfde rechten, maar **twee wegkapiteins** verplicht. **Moeten** voor- en nagevolgd worden door **een begeleidende auto**; op het dak een **blauw bord** met A51 en fiets-symbool.

**Kruispunten** zonder verkeerslichten: minstens één wegkapitein mag het verkeer in de dwarswegen stilleggen zodat de groep met begeleidende voertuigen kan oversteken.""",
    ),
    (
        "lesson_03_10",
        "Fietszone (fietsstraat)",
        """**Fietszone** (vervangt “fietsstraat” in de wegcode; overgangsperiode 9 jaar): begint bij **BEGIN zone**, eindigt bij **EINDE zone**.

- **Fietsers, rijwielen, speed pedelecs** mogen de **ganse breedte** van de rijbaan gebruiken (bij tweerichtingsverkeer alleen de **rechter helft**).
- **Motorvoertuigen** mogen rijden maar **mogen fietsers niet inhalen**. Max. snelheid **30 km/u**.

**Fietsstraat** (oude benaming): fietsers zijn de belangrijkste weggebruikers; motorvoertuigen mogen **fietsers, speed pedelecs en rijwielen tot 1 m** niet inhalen. Snelheid **30 km/u**. Gemotoriseerde voertuigen mogen een **bromfiets** wel links inhalen als de snelheid niet wordt overschreden.""",
    ),
]


def main():
    input_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"
    output_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"

    with open(input_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)

    for lesson_id, title_nl, description_nl in CHAPTER_03_LESSONS:
        row = [
            "chapter_03",
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

    print(f"Added chapter_03 with {len(CHAPTER_03_LESSONS)} lessons. Written to: {output_path}")


if __name__ == "__main__":
    main()
