# -*- coding: utf-8 -*-
"""Add chapter_09 (M.T.M. en M.B.T. – personenauto) to TheorieRoady CSV."""
import csv

CHAPTER_TITLE = "Maximaal toegelaten massa (M.T.M.) en massa beladen toestand (M.B.T.)"

# lesson_id, title_nl, description_nl - content from gratisrijbewijsonline.be
CHAPTER_09_LESSONS = [
    (
        "lesson_09_01",
        "Welke voertuigen met rijbewijs B?",
        """Met een **voorlopig** of **definitief rijbewijs B** mag je rijden met:

- een **personenauto**
- een **auto voor dubbel gebruik**
- een **minibus**
- een **lichte vrachtauto**

**Voorwaarde** voor de lichte vrachtauto: de **M.T.M.** (Maximaal Toegelaten Massa) mag **niet hoger zijn dan 3,5 ton** of **3500 kg**.""",
    ),
    (
        "lesson_09_02",
        "Wat is de M.T.M.?",
        """De **M.T.M.** (Maximaal Toegelaten Massa) is het **maximaal totale gewicht** dat een auto mag hebben: auto + benzine + bestuurder + passagiers + volle lading. Dat gewicht wordt door de **fabrikant** bepaald; zwaarder beladen voldoet niet meer aan de veiligheidsnormen.

**Rijbewijs B:** Je mag rijden met auto's waarvan de M.T.M. **maximaal 3500 kg** (3,5 ton) bedraagt. Hoe kleiner de auto, hoe lager de M.T.M.; hoe groter, hoe hoger.""",
    ),
    (
        "lesson_09_03",
        "Verkeersborden en M.T.M.",
        """Veel borden gaan over de **M.T.M.** van een voertuig (sinds een wetswijziging hoort het bord met de vrachtwagen bij M.T.M.). Borden over **Parkeren, Inhalen, Camion (vrachtwagen), Snelheid** hebben betrekking op **M.T.M.**

**Voorbeeld examenvraag:** Op een autoweg (2×2, middenberm) mag je normaal 120 km/u. Een bord zegt: voertuigen met M.T.M. **meer dan 3,5 ton** max. 60 km/u (geldt **niet** voor personenauto). Een ander bord: andere bestuurders max. 90 km/u. **Antwoord voor een personenauto: max. 90 km/u.**""",
    ),
    (
        "lesson_09_04",
        "Wat is de M.B.T.?",
        """De **M.B.T.** (Massa in Beladen Toestand) is het **echte gewicht** van de auto + personen + lading **op een bepaald ogenblik** (alsof je alles samen op een weegschaal zet).

**Voorbeeld:** M.T.M. van de auto = 2200 kg. Op de weegschaal: lege auto + benzine + water 1500 kg, bestuurder 75 kg, passagier 40 kg, lading 50 kg → **M.B.T. = 1665 kg** (lager dan de M.T.M.). Borden over **richting** of **toegang** verbieden gaan over **M.B.T.**""",
    ),
    (
        "lesson_09_05",
        "Geheugensteuntje: PICS",
        """**PICS** – borden over **P**arkeren, **I**nhalen, **C**amion (vrachtwagen), **S**nelheid → gaan over **M.T.M.**

Borden die een **richting** of **toegang** verbieden → gaan over **M.B.T.**""",
    ),
    (
        "lesson_09_06",
        "Aanhangwagen",
        """**Voorlopig rijbewijs:** Je mag **geen aanhangwagen** trekken.

**Definitief rijbewijs B:** Je mag een aanhangwagen trekken met een M.T.M. tot **750 kg**.

**Aanhangwagen met M.T.M. meer dan 750 kg** (bijv. 850 kg)? Je mag die toch trekken met rijbewijs B als de **M.T.M. van de auto + aanhangwagen samen max. 3500 kg** (3,5 ton) is.""",
    ),
    (
        "lesson_09_07",
        "Verplicht in de auto (M.T.M. tot 3,5 ton)",
        """**Verplicht in de auto:**

- **Gevarendriehoek**
- **Verbanddoos**
- **Brandblustoestel**
- **Fluovestje**

Deze **4 zaken** worden vaak op het examen gevraagd.""",
    ),
    (
        "lesson_09_08",
        "Niet verplicht – bellen en gsm",
        """**Niet verplicht** maar handig: trekkabel, krik, gps, reservewiel, parkeerschijf, handsfree kit.

**Handsfree bellen** leidt **evenzeer af** als bellen zonder handsfree; het is een misverstand dat het veilig is. Bellen met **gsm** in de hand is een **overtreding van de derde graad**. Vertel dat je rijdt; vergt het gesprek je volle aandacht, bel terug na een veilige parkeerplaats.""",
    ),
    (
        "lesson_09_09",
        "Nodige documenten",
        """**Bij de bestuurder:** **Identiteitskaart** (origineel), **rijbewijs** (origineel).

**In de auto:** **Inschrijvingsbewijs** (origineel), **gelijkvormigheidsattest** (origineel), **verzekeringsbewijs** (origineel of kopie/beeld), **keuringsbewijs** (origineel) zodra de auto **4 jaar** oud is.""",
    ),
    (
        "lesson_09_10",
        "Autodelen",
        """**Autodelen:** Met **meerdere mensen** gebruikmaken van één auto; je gebruikt hem wanneer nodig, anderen wanneer jij hem niet nodig hebt.

**Cambio** (vloot op vaste parkeerplaatsen): leden kunnen wagens lenen en terugbrengen; voorwaarde **min. 3 jaar rijbewijs B**. Er zijn ook **particuliere projecten** waar een eigenaar zijn auto tegen vergoeding ter beschikking stelt.""",
    ),
]


def main():
    input_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"
    output_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"

    with open(input_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)

    for lesson_id, title_nl, description_nl in CHAPTER_09_LESSONS:
        row = [
            "chapter_09",
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

    print(f"Added chapter_09 with {len(CHAPTER_09_LESSONS)} lessons. Written to: {output_path}")


if __name__ == "__main__":
    main()
