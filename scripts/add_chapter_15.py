# -*- coding: utf-8 -*-
"""Add chapter_15 (Links inhalen verboden, tripleren) to TheorieRoady CSV."""
import csv

CHAPTER_TITLE = "Links inhalen verboden, tripleren"

# lesson_id, title_nl, description_nl - content from gratisrijbewijsonline.be
CHAPTER_15_LESSONS = [
    (
        "lesson_15_01",
        "Wegmarkeringen en inhalen",
        """- **Onderbroken streep** (wit of geel): je mag erover rijden om een voertuig **links in te halen**.
- **Doorlopende streep** (wit of geel): je mag **niet** over de streep rijden om **links** in te halen.
- **Doorlopende én onderbroken streep naast elkaar:** je mag links inhalen als de **onderbroken streep aan jouw zijde** ligt. Na het inhalen moet je over de doorlopende streep terug naar rechts (je mag dus even over de doorlopende rijden om in te voegen).""",
    ),
    (
        "lesson_15_02",
        "Verhoogde inrichting – snelheid en fietsers",
        """Op **verhoogde inrichtingen** (max. **30 km/u**) in o.a. deze gevallen: aangekondigd door **A14 + F87**; alleen **A14** op kruispunten; of in een **zone F4a/F4b**. Bestuurders moeten met **extra voorzichtigheid** en **gematigde snelheid** naderen.

**Wetswijziging:** Op een verhoogde inrichting mag je een **tweewielige fietser of step** **links** inhalen. Een **fietser die aanstalten maakt om naar links af te slaan**, mag je **rechts** inhalen.""",
    ),
    (
        "lesson_15_03",
        "Inhaalverbod C35 / C37",
        """**C35** (rood): Verbod voor **bestuurders** om een **gespan** of een **voertuig met meer dan twee wielen** **links** in te halen. Geldt tot het **eerstvolgende kruispunt** of tot **C37** (einde inhaalverbod).

**Dus:** Een **autobestuurder** mag wél een **motorfiets** (twee wielen) links inhalen. De **motorrijder** mag **geen auto** (meer dan twee wielen) links inhalen.""",
    ),
    (
        "lesson_15_04",
        "Inhaalverbod C39 / C41 voor vrachtwagens",
        """**C39:** Verbod voor **vrachtwagens** of **slepen met M.T.M. > 3500 kg** om een **gespan** of **voertuig met meer dan twee wielen** links in te halen. Tot **eerstvolgende kruispunt** of **C41** (einde).

**Dus:** Een **personenauto** mag wél een **vrachtauto** links inhalen. Een **autobus** mag ook links inhalen (geen vrachtauto).""",
    ),
    (
        "lesson_15_05",
        "Links inhalen verboden – overweg, kruispunt, helling, bocht",
        """**Overweg** (A45/A47): Links inhalen van gespan, voertuig >2 wielen of **tweewielig motorvoertuig** verboden, **behalve** bij **slagbomen** of **maanwit licht**. Fietser mag wél.

**Kruispunt** (voorrang rechts B17 of geen borden / voorrang verlenen B1 of B5): Verbod om gespan, voertuig >2 wielen of tweewielig motorvoertuig **links** in te halen. Fietser mag wél.

**Steile helling A5** (top onoverzichtelijke helling): Zelfde verbod. Fietser mag in principe wél (vaak niet mogelijk door vereiste afstand). **Wel** inhalen als rijbaan in rijstroken en je niet over de doorlopende streep rijdt.

**Gevaarlijke bocht A1:** In of vóór de bocht: zelfde verbod. Zeer slechte zichtbaarheid → ook **fietser** niet inhalen. **Wel** als het veilig kan zonder over de doorlopende streep te rijden.""",
    ),
    (
        "lesson_15_06",
        "Oversteekplaats – geen inhalen, geen parkeren",
        """Een bestuurder die een **oversteekplaats voor voetgangers** (zebrapad) of **voor fietsers en tweewielige bromfietsen** nadert, of er **vertraagt** of **stopt**, mag **niet links ingehaald** worden.

**Verboden:** Niet **stilstaan** of **parkeren op** de oversteekplaats (noch op de rijbaan, noch op de berm), en niet op de **rijbaan** tot **5 meter vóór** de oversteekplaats. **Vóórbij** de oversteekplaats mag het wél.""",
    ),
    (
        "lesson_15_07",
        "Tripleren",
        """**Tripleren** = een voertuig inhalen dat **zelf al een ander voertuig** aan het inhalen is.

**Rijbaan met tweerichtingsverkeer:** Je mag een **auto** inhalen die een **bromfiets** of **motorfiets** aan het inhalen is. Je mag **geen** auto inhalen die een **andere auto** aan het inhalen is.

**Eenrichtingsverkeer met min. 3 rijstroken** in jouw richting (bijv. eenrichtingsweg met 3 stroken of autosnelweg): Je mag **wél** een auto inhalen die een andere auto aan het inhalen is.""",
    ),
]


def main():
    input_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"
    output_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"

    with open(input_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)

    for lesson_id, title_nl, description_nl in CHAPTER_15_LESSONS:
        row = [
            "chapter_15",
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

    print(f"Added chapter_15 with {len(CHAPTER_15_LESSONS)} lessons. Written to: {output_path}")


if __name__ == "__main__":
    main()
