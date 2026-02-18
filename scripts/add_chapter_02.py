# -*- coding: utf-8 -*-
"""Add chapter_02 (De rijstroken, busstrook, verdrijvingsvlak) to TheorieRoady CSV."""
import csv

CHAPTER_TITLE = "De rijstroken, busstrook, verdrijvingsvlak"

# lesson_id, title_nl, description_nl - content from gratisrijbewijsonline.be
CHAPTER_02_LESSONS = [
    (
        "lesson_02_01",
        "Rijstroken",
        """Een rijbaan kan met **een wegmarkering** in rijstroken worden onderverdeeld.

**Wegmarkering** betekent hier:
- De **witte onderbroken streep**, of
- De **witte doorgetrokken of doorlopende streep** in het midden van de rijbaan.

Met zo'n wegmarkering kan een rijbaan in **twee, drie of meer** rijstroken worden onderverdeeld.""",
    ),
    (
        "lesson_02_02",
        "Pijlen op de rijstroken",
        """Nabij kruispunten worden op het wegdek soms **pijlen** geschilderd die de rijrichting aangeven. Deze pijlen zijn ook wegmarkeringen.

Bij meerdere rijstroken staat vaak een **blauw aanwijzingsbord** (F13) naast de rijbaan dat de keuze van rijstrook en richting voorschrijft.""",
    ),
    (
        "lesson_02_03",
        "Waar rijden?",
        """Ook bij rijstroken moeten bestuurders in normale omstandigheden **zo veel mogelijk op de rechterrijstrook** rijden. Zomaar op de linkerrijstrook rijden is een **overtreding**.

**Uitzondering in bebouwde kom:** Bij **2 rijstroken in jouw rijrichting** mag je ook op de linker rijstrook blijven rijden als die het best aansluit bij je bestemming (bijv. je wilt verderop links afslaan of links parkeren).""",
    ),
    (
        "lesson_02_04",
        "Snelheid op de rijbaan",
        """De **maximaal toegelaten snelheid** op een gewone rijbaan:

- **Vlaams en Brussels gewest:** **70** km/u
- **Waals gewest:** **90** km/u

**Verkeersborden** of **verkeersregels** kunnen een andere maximumsnelheid opleggen.""",
    ),
    (
        "lesson_02_05",
        "Inhalen",
        """**Over een witte onderbroken streep** mag je rijden om in te halen als de bestuurder voor je trager rijdt dan de toegelaten snelheid (tenzij verkeersborden het verbieden).

- De **ingeehaalde bestuurder** mag zijn **snelheid niet verhogen** en moet **zo veel mogelijk rechts** rijden.

**Over een witte doorlopende streep** mag je **niet** inhalen.

**Onderbroken + doorlopende streep naast elkaar:** Als de **onderbroken streep aan jouw zijde** is, mag je daarover inhalen. Daarna ga je terug naar de rechterrijstrook.""",
    ),
    (
        "lesson_02_06",
        "Rijstrookvermindering",
        """**Aanwijzingsborden** (F97) geven een rijstrookvermindering aan:
- **F97 links:** rijstrookvermindering **langs links**
- **F97 rechts:** rijstrookvermindering **langs rechts**

Het aantal rijstroken vermindert; bestuurders moeten tijdig de vrije strook kiezen.""",
    ),
    (
        "lesson_02_07",
        "Ritsen",
        """**Wanneer ritsen?** Bij **sterk vertraagd verkeer** wanneer een rijstrook ophoudt door:
- vermindering van rijstroken
- wegenwerken
- hindernis of ongeval

**Drie voorwaarden:** (1) er zijn rijstroken, (2) het aantal (bruikbare) rijstroken vermindert, (3) er is sterk vertraagd verkeer. Zijn die niet vervuld, dan wordt er **niet** geritst. Bij **invoegen op de autosnelweg** wordt **niet** geritst.

**Regels:**
- Ritsen is **verplicht**.
- Ritsen is **geen manoeuvre**.
- Je mag pas **invoegen** in de vrije rijstrook **vlak voor de rijstrookvermindering**.
- **Eén strook valt weg (links OF rechts):** beurtelings voorrang aan 1 invoegende bestuurder.
- **Twee stroken vallen weg (links EN rechts):** beurtelings voorrang, te beginnen met **rechts**, dan **links**, daarna zelf verder.""",
    ),
    (
        "lesson_02_08",
        "Busstrook",
        """Een **busstrook** is **geen onderdeel van de rijbaan** (KB 12/3/2023). Ze is bestemd voor geregeld gemeenschappelijk vervoer en wordt aangeduid met **1 of 2 brede witte onderbroken strepen** (of dambordmarkeringen) en het **bord F17**.

**Met de auto:** op een busstrook mag je **niet rijden**, **niet parkeren** en **niet stilstaan** (sinds 1/4/2023).

**Uitzondering:** de **laatste meters voor een kruispunt** wanneer je naar links of rechts afslaat.

**Andere bestuurders** (fiets, taxi, enz.) mogen alleen op de busstrook als dat op **onderborden** of op de strook staat (schoolvervoer, taxi, fiets, bromfiets, motor, enz.).""",
    ),
    (
        "lesson_02_09",
        "Verdrijvingsvlak",
        """Naast rijstroken of op delen van een rijstrook worden soms **brede schuine strepen** geschilderd. Dat is een **verdrijvingsvlak**.

Op een verdrijvingsvlak mag je:
- **niet rijden**
- **niet stilstaan**
- **niet parkeren**""",
    ),
    (
        "lesson_02_10",
        "Wegenwerken",
        """Het **gevaarsbord A31** kondigt **wegenwerken** aan. Bij wegenwerken worden vaak **voorlopige oranje doorlopende of onderbroken strepen** op het wegdek geschilderd. Deze hebben **dezelfde betekenis als de witte** markeringen.

**Witte én oranje strepen?** Alleen de **oranje** wegmarkeringen tellen.

Als de oranje markeringen aangeven dat je over een pechstrook of verdrijvingsvlak mag rijden, is dat dus toegelaten.

**GPS-verbod:** Bij sommige wegenwerken staat een bord om je **gps uit te zetten** en de omleiding te volgen, om tegenstrijdige routes en verwarring te vermijden.""",
    ),
]


def main():
    input_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"
    output_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"

    with open(input_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)

    for lesson_id, title_nl, description_nl in CHAPTER_02_LESSONS:
        row = [
            "chapter_02",
            CHAPTER_TITLE,
            "",  # chapter_title_fr
            "",  # chapter_title_en
            "",  # chapter_imageUrl
            lesson_id,
            title_nl,
            description_nl,
            "",  # title_fr
            "",  # description_fr
            "",  # title_en
            "",  # description_en
            "",  # lottieAsset
            "",  # imageUrl
        ]
        rows.append(row)

    with open(output_path, "w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerows(rows)

    print(f"Added chapter_02 with {len(CHAPTER_02_LESSONS)} lessons. Written to: {output_path}")


if __name__ == "__main__":
    main()
