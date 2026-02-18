# -*- coding: utf-8 -*-
"""Add chapter_14 (Links rechts inhalen, voorbijrijden) to TheorieRoady CSV."""
import csv

CHAPTER_TITLE = "Links rechts inhalen, voorbijrijden"

# lesson_id, title_nl, description_nl - content from gratisrijbewijsonline.be
CHAPTER_14_LESSONS = [
    (
        "lesson_14_01",
        "Inhalen of voorbijrijden?",
        """**Links inhalen:** Het voertuig voor jou rijdt **trager** dan de **maximaal toegelaten snelheid** en is **in beweging**. Dan kun je het **links** inhalen.

**Voorbijrijden:** Als het voertuig **niet rijdt** (stilstaat), spreekt de wegcode niet van inhalen maar van **voorbijrijden**.""",
    ),
    (
        "lesson_14_02",
        "Vragen vóór je inhaalt",
        """Vóór je een voertuig **links** inhaalt, moet je jezelf het volgende afvragen:

1. Rijdt de bestuurder voor mij **trager dan de max. toegelaten snelheid**?
2. Kan ik hem **op zeer korte tijd** inhalen **zonder zelf te snel** te rijden?
3. Is er een **tegenligger** die nadert?
4. Word ik **zelf ingehaald** door een achterligger?
5. Is er **voldoende plaats** om na het inhalen **terug in te voegen**?
6. **Verbieden borden of regels** hier het inhalen?""",
    ),
    (
        "lesson_14_03",
        "Hoe inhalen? Richtingaanwijzer en afstand",
        """Als het inhalen veilig kan:

1. **Linker richtingaanwijzer** aan → zijdelingse verplaatsing naar links.
2. Verplaatsing klaar → richtingaanwijzer **uit** → voertuig inhalen.
3. Ingehaald → **rechter richtingaanwijzer** aan → weer **rechts** rijden.

Bij het inhalen van **voertuigen** moet je **voldoende zijdelingse afstand** bewaren (de regels geven geen exacte meter).""",
    ),
    (
        "lesson_14_04",
        "Twee voertuigen inhalen",
        """**Gewone rijbaan (1×1):** Na het inhalen van het eerste voertuig **eerst terug naar de rechter rijstrook** (als dat kan), vóór je het tweede inhaalt. **Uitzondering:** Als de twee voertuigen **zeer dicht** achter elkaar rijden en het **gevaarlijk** zou zijn om tussendoor naar rechts te gaan, mag je **beide** in één beweging links inhalen.

**2×2 of eenrichtingsverkeer:** Je **hoeft niet** direct terug naar rechts vóór je een volgend voertuig inhaalt (bijv. op autoweg 2×2 mag je op de linker strook blijven om een tweede in te halen).""",
    ),
    (
        "lesson_14_05",
        "Inhalen van fietser, bromfietser, voetganger",
        """**Buiten de bebouwde kom:** Min. **1,5 m** zijdelingse afstand bij het inhalen van een **voetganger** op de rijbaan of een **fietser/bromfietser** op de rijbaan. Geldt ook als de fietser/bromfietser op een **fietspad** rijdt (zelfde 1,5 m).

**Binnen de bebouwde kom:** Min. **1 m** zijdelingse afstand.""",
    ),
    (
        "lesson_14_06",
        "Rechts inhalen – alleen in 2 gevallen",
        """**1. Voorligger gaat links afslaan:** Hij **pinkt links** én heeft zich **al naar links** bewogen. Je mag hem dan **rechts** voorbijrijden. **Niet** op de **parkeerstrook** (denkbeeldige rand) of op het **fietspad**; **wel** op de **gelijkgrondse berm** als dat mag.

**2. Tram:** Een **tram** haal je normaal **rechts** in. Liggen de **sporen rechts** op de rijbaan → mag je **links** inhalen. Is rechts inhalen **niet mogelijk** (doorgang te eng, geparkeerde auto) → **links** mag, als het veilig kan. **Tram in het midden**, passagier stapt uit → voertuigen moeten **vertragen en zo nodig stoppen** zodat de passagier veilig kan oversteken (niet als er een **verhoogde berm** naast het spoor is om te wachten).""",
    ),
    (
        "lesson_14_07",
        "Wat telt niet als inhalen?",
        """De wegcode spreekt **niet** van inhalen in deze situaties:

- **File of druk verkeer:** Het verkeer op de ene rijstrook rijdt wat sneller dan op de andere → **geen** inhalen in de zin van de wet.
- **Aanwijzingsborden** (F15, F13): Je **kiest een rijstrook** of richting volgens de pijlen → geen inhalen.
- **Binnen bebouwde kom:** Bestuurders volgen de rijstrook die het best bij hun bestemming past op een **eenrichtingsweg met rijstroken** of op een **tweerichtingsweg met 4 of meer rijstroken** (min. 2 per richting) → geen inhalen.""",
    ),
    (
        "lesson_14_08",
        "Motorfietsen bij file",
        """Bij **file** mogen **motorfietsen** tussen de voertuigen rijden. Op **autosnelweg** en **autoweg** alleen **tussen de twee meest linkse rijstroken**.

Ze mogen **max. 50 km/u** rijden en **max. 20 km/u sneller** dan de voertuigen die ze passeren.""",
    ),
]


def main():
    input_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"
    output_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"

    with open(input_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)

    for lesson_id, title_nl, description_nl in CHAPTER_14_LESSONS:
        row = [
            "chapter_14",
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

    print(f"Added chapter_14 with {len(CHAPTER_14_LESSONS)} lessons. Written to: {output_path}")


if __name__ == "__main__":
    main()
