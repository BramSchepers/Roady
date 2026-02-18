# -*- coding: utf-8 -*-
"""Add chapter_07 (Voetpad en oversteekplaats voor voetgangers) to TheorieRoady CSV."""
import csv

CHAPTER_TITLE = "Voetpad en oversteekplaats voor voetgangers (zebrapad)"

# lesson_id, title_nl, description_nl - content from gratisrijbewijsonline.be
CHAPTER_07_LESSONS = [
    (
        "lesson_07_01",
        "Weggebruikers",
        """Volgens de wegcode is een **weggebruiker** **elke persoon** die gebruikmaakt van de openbare weg. Het gaat om **personen** — een dier (paard, hond) of een ding (fiets, auto) is geen weggebruiker.

**Weggebruikers zijn:**
- **voetgangers**
- **bestuurders** van voertuigen""",
    ),
    (
        "lesson_07_02",
        "Wat zijn voetgangers?",
        """Een **voetganger** is een persoon die zich **te voet** op de openbare weg verplaatst. Hij moet dat doen op het **trottoir**, het **voetpad** of de **berm**. Geen voetpad of berm? Dan bij voorkeur op het **fietspad**, of op de **rijbaan**.

Ook **voetgangers**: iemand die een winkelkarretje of kruiwagen voortduwt; iemand die zich met een **rolstoel** of voortbewegingstoestel **stapvoets** verplaatst; iemand die een **defecte bromfiets of fiets voortduwt** (bijv. op het trottoir).

Een **ruiter** of iemand die een **paard begeleidt** is **geen** voetganger maar een **bestuurder**.""",
    ),
    (
        "lesson_07_03",
        "Oversteekplaats – borden en verplichting",
        """**Borden:** **F49** (blauw, bij de oversteekplaats) en **A21** (rood gevaarsbord, ca. **150 m** vóór de oversteekplaats).

Binnen **20 meter** (tot 31/5/19: 30 m) een oversteekplaats voor voetgangers of zebrapad? Dan **moeten** voetgangers die gebruiken.

**Gevleugeld zebrapad:** In Vlaanderen bestaan er bredere zebrapaden (8–9 m i.p.v. 3–4 m) voor meer veiligheid en betere zichtbaarheid voor o.a. vrachtwagenbestuurders.""",
    ),
    (
        "lesson_07_04",
        "Voorrang en inhalen",
        """**Voorrang:** Voetgangers die **op het zebrapad** stappen of het **willen gaan gebruiken**, moet je **altijd voorrang geven**. Rijd dus **heel voorzichtig** als je een oversteekplaats nadert.

**Inhalen:** Je mag **nooit** een bestuurder inhalen die **vertraagt** of **stopt** voor een zebrapad. Dat is een ernstige overtreding.""",
    ),
    (
        "lesson_07_05",
        "Stilstaan en parkeren bij oversteekplaats",
        """**Verboden:**
- **Op** de oversteekplaats (niet op de rijbaan, niet op de berm) parkeren of stilstaan (bijv. om iemand in- of uit te laten stappen).
- **Op de rijbaan** (wel op de berm) parkeren of stilstaan **tot 5 meter vóór** de oversteekplaats.

**Vóórbij** de oversteekplaats mag je wel parkeren en stilstaan (tenzij borden het verbieden).

**Let op (file):** In een file mag je **niet** stoppen **op** de oversteekplaats; stop **vóór** de oversteekplaats. Hetzelfde geldt bij een oversteekplaats voor fietsers en tweewielige bromfietsen.""",
    ),
    (
        "lesson_07_06",
        "Geen oversteekplaats",
        """Een voetganger die de rijbaan wil oversteken **op een plaats waar geen zebrapad** is, moet **zelf voorrang verlenen** aan het verkeer.

Toch moet je als bestuurder **altijd voorzichtig** zijn.""",
    ),
    (
        "lesson_07_07",
        "Voetgangerszone",
        """In een **voetgangerszone** (begin F103n, einde F105n) moeten bestuurders die er mogen rijden:

- **Stapvoets** rijden.
- De **doorgang vrij** laten voor voetgangers en **indien nodig stoppen**.
- Voetgangers **niet in gevaar brengen of hinderen**.""",
    ),
    (
        "lesson_07_08",
        "Halteplaats tram of bus",
        """Als een **tram** of **bus** stopt op de rijbaan en er is **geen vluchtheuvel** bij de halteplaats, moet de bestuurder die rijdt langs de kant waar reizigers **in- en uitstappen**:

- **Stoppen**.
- De reizigers de kans geven de rijbaan **veilig over te steken**.
- Daarna met **matige snelheid** weer vertrekken.""",
    ),
    (
        "lesson_07_09",
        "Schoolbus",
        """Voertuigen voor **schoolvervoer** zijn herkenbaar aan een **geel bord** (min. 0,40 m) aan voor- en achterzijde. Het bord wordt verwijderd of afgedekt wanneer het voertuig niet voor schoolvervoer wordt gebruikt.

**Hoe reageren?** Wees **extra voorzichtig** en **verminder je snelheid**. **Stop indien nodig** wanneer je een schoolbus ziet die zijn **richtingaanwijzers** aanzet — dat betekent dat kinderen gaan in- of uitstappen. Geldt zowel voor stilstaande als voor rijdende schoolbussen die stoppen.""",
    ),
]


def main():
    input_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"
    output_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"

    with open(input_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)

    for lesson_id, title_nl, description_nl in CHAPTER_07_LESSONS:
        row = [
            "chapter_07",
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

    print(f"Added chapter_07 with {len(CHAPTER_07_LESSONS)} lessons. Written to: {output_path}")


if __name__ == "__main__":
    main()
