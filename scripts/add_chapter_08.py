# -*- coding: utf-8 -*-
"""Add chapter_08 (De bestuurders van motorvoertuigen) to TheorieRoady CSV."""
import csv

CHAPTER_TITLE = "De bestuurders van motorvoertuigen"

# lesson_id, title_nl, description_nl - content from gratisrijbewijsonline.be
CHAPTER_08_LESSONS = [
    (
        "lesson_08_01",
        "Wie is een bestuurder?",
        """Volgens de wegcode is een **bestuurder** een persoon die:

- **een voertuig bestuurt** (motorloze voertuigen of motorvoertuigen), of
- **trek-, last- of rijdieren of vee** op de openbare weg **geleidt** of **bewaakt**.

**Motorloze voertuigen** en **motorvoertuigen** vallen dus onder \"bestuurder\" zodra je ze bestuurt.""",
    ),
    (
        "lesson_08_02",
        "Voortduwen: voetganger of bestuurder?",
        """**Defecte bromfiets of fiets voortduwen** → die persoon is een **voetganger**. Geen rijbewijs of helm verplicht; het voortduwen moet op het **trottoir** gebeuren.

**Motorfiets duwen** → die persoon is een **bestuurder**. Rijbewijs en **helm** verplicht; op de **rijbaan** stappen.

**Auto duwen** (bestuurder stapt uit en duwt) → blijft **bestuurder**.""",
    ),
    (
        "lesson_08_03",
        "Dieren geleiden of bewaken",
        """Iemand die **trek-, last- of rijdieren of vee** op de openbare weg **geleidt** of **bewaakt**, is een **bestuurder**. Voorbeelden: **ruiter**, begeleider naast een jonge ruiter, **boer bij koeien**, iemand met een **huifkar**.

**Regel:** Elke bestuurder moet **meteen vertragen** wanneer hij trek-, last- of rijdieren of vee op de weg nadert. Hij moet **stoppen** indien deze dieren **tekenen van angst** vertonen.""",
    ),
    (
        "lesson_08_04",
        "Weggebruikers vs bestuurders",
        """**Belangrijk voor de volgende lessen:**

- **Weggebruikers** = iedereen die de openbare weg gebruikt: **voetgangers** én **bestuurders** (motorloze en motorvoertuigen).
- **Bestuurders** = alleen bestuurders van voertuigen of van dieren; **voetgangers zijn niet inbegrepen**.

Verkeersregels en borden kunnen voor **alleen bestuurders** gelden, niet voor voetgangers (of omgekeerd).""",
    ),
    (
        "lesson_08_05",
        "Verbodsborden per type bestuurder",
        """Een verkeersregel of verkeersbord geldt **niet altijd voor elke bestuurder**, maar soms alleen voor **bepaalde** bestuurders.

**Voorbeelden verbodsborden:** C7 (motorfietsen), C9 (bromfietsen), C11 (rijwielen), C19 (voetgangers), C22 (autocars), C23 (vrachtvervoer), C39, C13 (gespannen). Zo weet je welk type voertuig of weggebruiker ergens niet mag.""",
    ),
    (
        "lesson_08_06",
        "Rijbewijs B – voertuigen tot 3,5 ton",
        """De volgende lessen gaan vooral over **bestuurders van voertuigen met een M.T.M. van maximaal 3,5 ton**. Dat zijn de voertuigen waarmee je met een **voorlopig of definitief rijbewijs B** mag rijden:

- **Personenauto**
- **Auto voor dubbel gebruik**
- **Minibus** (max. 8 zitplaatsen passagiers + 1 bestuurder)
- **Lichte vrachtauto**""",
    ),
]


def main():
    input_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"
    output_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"

    with open(input_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)

    for lesson_id, title_nl, description_nl in CHAPTER_08_LESSONS:
        row = [
            "chapter_08",
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

    print(f"Added chapter_08 with {len(CHAPTER_08_LESSONS)} lessons. Written to: {output_path}")


if __name__ == "__main__":
    main()
