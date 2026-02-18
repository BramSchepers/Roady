# -*- coding: utf-8 -*-
"""Update TheorieRoady CSV: replace description_nl (column H) with formatted content."""
import csv
import sys

DESCRIPTIONS = [
    # lesson_00_01
    """Leeftijd: Vanaf **17 jaar**.

Eis: Minimaal **41/50** op het theorie-examen.

Resultaat: Je krijgt **een attest** voor je voorlopig rijbewijs.

Geldigheid: Dit attest blijft **3 jaar** bruikbaar.""",
    # lesson_00_02
    """**Twee keer** gezakt? Dan moet je verplicht **12 uur** theorieles volgen bij de rijschool.

**OPGELET:** Je mag pas rijden zodra je je échte voorlopige rijbewijs bij het gemeentehuis hebt opgehaald.""",
    # lesson_00_03
    """Zodra je **17** bent en je attest op zak hebt, kun je bij het gemeentehuis je **voorlopig rijbewijs B** aanvragen. Met dit rijbewijs mag je officieel de weg op om te oefenen. Je hebt hierbij twee keuzes:

- Leren rijden met maximaal **twee eigen begeleiders**.
- Leren rijden onder begeleiding van **een professionele rijschool**.""",
    # lesson_00_04
    """- **Voorwaarde:** Minimaal **18 jaar oud + 20 uur rijschool**.
- **Document:** Bekwaamheidsattest van de rijschool.
- **Resultaat:** Een voorlopig rijbewijs **(M18)** om **zonder begeleider** te oefenen.
- **Beperking:** Dit rijbewijs is slechts **één keer** verkrijgbaar en **vervalt** na **18** maanden.""",
    # lesson_00_05
    """Als houder van een voorlopig rijbewijs mag je niet rijden tussen **22:00** uur 's avonds en **06:00** uur 's ochtends op de volgende dagen:

- Vrijdagnacht (vrijdag op zaterdag)
- Zaterdagnacht (zaterdag op zondag)
- Zondagnacht (zondag op maandag)
- De nacht vóór een wettelijke feestdag
- De nacht van de feestdag zelf (feestdag op de volgende dag)""",
    # lesson_00_06
    """**Voorwaarden:**

- **18 jaar** oud
- Een stageperiode van minimaal **5 maanden** met een voorlopig rijbewijs (18 of 36 maanden) hebt doorlopen.""",
    # lesson_00_07
    """Een vergeten rijbewijs is geen drama, maar wel een administratieve last. Hier is de essentie:

- **Overtreding:** 1ste graad (niet bijhebben van documenten).
- **Boete:** Onmiddellijke inning van **€58**.
- **Gevolg:** Je mag je weg vervolgen.
- **Verplichting:** Binnen de **5 dagen** het originele rijbewijs tonen op een politiekantoor naar keuze.""",
    # lesson_00_08
    """Zodra een arts je medisch ongeschikt verklaart om te rijden:

- **Actie:** Je moet je rijbewijs inleveren bij de gemeente.
- **Termijn:** Binnen de **4 werkdagen** (zaterdagen, zondagen en feestdagen tellen niet mee).
- **Reden:** Je bent fysiek of geestelijk niet langer in staat om veilig een voertuig te besturen.""",
    # lesson_00_09
    """- **Eerste aanval:** Automatisch rijverbod van **6 maanden**.
- **Chronische epilepsie:** Rijbewijs terugkrijgen kan na **1 jaar** aanvalsvrij zijn (met gunstig verslag van een specialist).
- **Herval:** Bij een nieuwe aanval geldt opnieuw een rijverbod van **1 jaar**.
- **Verplichting:** Je bent wettelijk verplicht dit te melden en je rijbewijs in te leveren bij de gemeente.""",
    # lesson_00_10
    """**Wat te doen?**

- **Gestolen?** Altijd aangifte doen bij de politie.
- **Verloren?** Melden bij de politie of het gemeentehuis.
- **Nieuw bewijs?** Direct een nieuwe aanvragen bij je gemeente.

**Belangrijk:** Een bewijs van aangifte is geen geldig rijbewijs. Je mag pas weer achter het stuur kruipen als je het nieuwe pasje fysiek in handen hebt.""",
    # lesson_01_01
    """Een openbare weg is voor iedereen toegankelijk en bedoeld voor algemeen gebruik. Hierbij gelden de volgende kernpunten:

- **Toegankelijkheid:** Straten, snelwegen, bruggen, tunnels, pleinen en paden vallen hieronder.
- **Verplichting:** Iedereen moet zich aan de verkeersregels houden om de veiligheid en een goede doorstroming te waarborgen.
- **Indeling:** De weg bestaat uit verschillende onderdelen, zoals de rijbaan, het fietspad, de berm en het voetpad.""",
    # lesson_01_02
    """Een openbaar terrein is een plaats die niet tot de openbare weg behoort, maar wel vrij toegankelijk is voor het publiek.

- **Kenmerk:** Het is vaak een parkeerterrein, evenemententerrein, benzinestation of de parking van een supermarkt.
- **Verkeersregels:** Omdat het terrein openstaat voor verkeer, zijn ook hier de verkeersregels van kracht, net als op de openbare weg.""",
    # lesson_01_03
    """Een niet-openbaar terrein is een afgesloten gebied waar je enkel mag rijden als je hiervoor toestemming hebt, zoals een oefenterrein van een rijschool of een privaat parkeerterrein. Hier gelden de verkeersregels doorgaans niet, maar **zware overtredingen** zoals gevaarlijk rijgedrag kunnen alsnog bestraft worden.""",
    # lesson_01_04
    """Het bord **privaat** staat bij wegen die geen deel uitmaken van de openbare weg. Op deze wegen gelden de verkeersregels **niet**, tenzij deze weg door iedereen gebruikt mag worden.""",
    # lesson_01_05
    """Voor een tram gelden de gewone verkeersregels (zoals voorrang van rechts) **niet**. Een trambestuurder hoeft alleen te stoppen voor:

- Aanwijzingen van de **politie** (bevoegd persoon).
- **Verkeerslichten** (of speciale tramlichten).""",
    # lesson_01_06
    """- Bedoeld voor **gemotoriseerd verkeer** (auto's, vrachtwagens, motoren).
- Geen fietspad? Dan mogen **fietsers en bromfietsers** ook op de rijbaan rijden, weliswaar zo **rechts mogelijk** op de rijbaan.""",
    # lesson_01_07
    """Bestuurders moeten altijd **zo rechts mogelijk** op de rijbaan rijden.""",
    # lesson_01_08
    """De rand van de rijbaan wordt vaak aangeduid met een **dunne witte lijn**. Verder heeft deze geen betekenis.""",
    # lesson_01_09
    """Als het laatste stuk van een aardeweg verhard is, blijft dit een **aardeweg**. Het wordt dus niet gezien als een rijbaan.""",
    # lesson_01_10
    """**Overzicht:**

- **Vlaanderen:** 70 km/u (buiten de kom).
- **Wallonië:** 90 km/u (buiten de kom).
- **Brussel:** 70 km/u buiten de kom (en standaard **30 km/u** binnen de kom).

**Verkeersborden** gaan altijd vóór op de algemene snelheidsregels. Borden bepalen de limiet: of het nu een zone 30 bij een school is of een hogere snelheid op een snelweg.""",
    # lesson_01_11 Dieren
    """Wanneer je dieren (zoals paarden of vee) nadert op de weg, gelden deze veiligheidsregels:

- **Meteen vertragen:** Pas je snelheid direct aan zodra je last- of rijdieren ziet.
- **Stoppen bij paniek:** Als een dier schrikt of steigert, moet je je voertuig volledig tot stilstand brengen.
- **Blijf rustig:** Maak geen bruuske bewegingen of lawaai. Geef de begeleider de tijd om het dier kalm te krijgen voordat je weer vertrekt.""",
    # lesson_01_11 Te snel
    """Je verliest je rijbewijs (**8 dagen tot 5 jaar**) in de volgende gevallen:

- **Zone 30 / Bebouwde kom:** Meer dan **30 km/u** te snel.
- **Andere wegen** (incl. snelweg): Meer dan **40 km/u** te snel.

**Beginnende bestuurders** (< 2 jaar rijbewijs) of **voorlopig rijbewijs:** Je moet verplicht je examens opnieuw afleggen om je rijbewijs terug te krijgen.""",
]


def main():
    input_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"
    output_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"
    if len(sys.argv) >= 2:
        input_path = sys.argv[1]
    if len(sys.argv) >= 3:
        output_path = sys.argv[2]

    with open(input_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)

    # Column H = index 7 (description_nl)
    # Row 0 = header, rows 1..N = data
    if len(rows) < 2:
        print("CSV has no data rows")
        return
    if len(rows[0]) <= 7:
        print("CSV has no column H")
        return
    if len(DESCRIPTIONS) != len(rows) - 1:
        print(f"Expected {len(rows) - 1} descriptions, got {len(DESCRIPTIONS)}")
        return

    for i, desc in enumerate(DESCRIPTIONS):
        rows[i + 1][7] = desc

    with open(output_path, "w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerows(rows)

    print(f"Updated {len(DESCRIPTIONS)} rows. Written to: {output_path}")


if __name__ == "__main__":
    main()
