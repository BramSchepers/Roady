# -*- coding: utf-8 -*-
"""Add chapter_12 (Reactietijd, remafstand, stopafstand) to TheorieRoady CSV."""
import csv

CHAPTER_TITLE = "Reactietijd, remafstand, stopafstand"

# lesson_id, title_nl, description_nl - content from gratisrijbewijsonline.be
CHAPTER_12_LESSONS = [
    (
        "lesson_12_01",
        "Veilige volgafstand",
        """Hoe **sneller** je rijdt, hoe **meer afstand** je moet bewaren tot je voorganger.

**Formule:** De veilige volgafstand (in meter) ≈ **snelheid gedeeld door twee**.

- **120 km/u** → ca. **60 m** volgafstand
- **100 km/u** → ca. **50 m** volgafstand""",
    ),
    (
        "lesson_12_02",
        "Reactietijd en reactieafstand",
        """De **reactieafstand** is de afstand die de auto aflegt tussen het moment dat je een prikkel ziet (bijv. een ongeval) en het moment dat je je voet op het rempedaal zet. Je hersenen moeten de prikkel verwerken.

Hoe **sneller** je rijdt, hoe **langer** de reactieafstand.

**Voorbeelden:**
- **50 km/u** → ca. **15 m**
- **90 km/u** → ca. **27 m**
- **120 km/u** → ca. **36 m** (nog vóór je remt)

**Alcohol:** Iemand die dronken is, reageert trager → de reactieafstand wordt **langer**.""",
    ),
    (
        "lesson_12_03",
        "Remafstand",
        """De **remafstand** (remweg) is de afstand die de auto aflegt **vanaf het indrukken van het rempedaal** tot de auto **volledig stilstaat**. Hoe sneller je rijdt, hoe langer de remafstand.

Op een **nat wegdek** is de remafstand **langer** dan op **droog** wegdek (bij dezelfde snelheid). Voorbeelden: 50 km/u droog ca. 12,5 m, nat ca. 18,75 m; 120 km/u droog ca. 72 m, nat ca. 108 m.""",
    ),
    (
        "lesson_12_04",
        "Stopafstand – wat moet je kennen voor het examen?",
        """De **stopafstand** = **reactieafstand + remafstand** (totale afstand van het moment dat je iets ziet tot je stilstaat).

**Leer deze 4 getallen voor het examen (droog wegdek):**

| Snelheid | Stopafstand (droog) |
|----------|---------------------|
| **50 km/u** | ca. **30 m** |
| **70 km/u** | ca. **45 m** |
| **90 km/u** | ca. **70 m** |
| **110 km/u** | ca. **95 m** |

Met deze vier getallen kun je examenvragen oplossen: bij lagere snelheid is de stopafstand korter dan het volgende getal; bij hogere snelheid langer. Bijv. 40 km/u → minder dan 30 m; 100 km/u → meer dan 70 m (want 90 km/u is al 70 m).""",
    ),
    (
        "lesson_12_05",
        "ABS",
        """**ABS** (anti-blokkeersysteem) voorkomt dat de **banden blokkeren** en over het wegdek slippen bij **fel remmen**. De wielen blijven bestuurbaar.

Remmen **met** ABS wil **niet per se** zeggen dat de remafstand **korter** is dan zonder ABS. Op een **nat** wegdek is de stopafstand **langer** dan op **droog** wegdek, ook met ABS.""",
    ),
    (
        "lesson_12_06",
        "Banden",
        """Voor veilig rijden en remmen moeten de **banden** in goede staat zijn.

- **Profieldiepte:** minstens **1,6 mm** (absoluut minimum).
- **Bandendruk:** volgens de **voorschriften van de fabrikant**.
- **Lange rit** of **zware lading:** bandendruk best **iets verhogen** voor vertrek.""",
    ),
    (
        "lesson_12_07",
        "Pauze tijdens lange ritten",
        """Bij **lang rijden** word je moe: je **reactievermogen** daalt en je **reactietijd** stijgt.

Neem **ongeveer elke twee uur** een **korte pauze van min. 15 minuten** om vermoeidheid tegen te gaan en alert te blijven. Stap even uit, strek je benen, adem diep in en blijf gehydrateerd (water of lichte snacks).""",
    ),
]


def main():
    input_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"
    output_path = r"c:\Users\brams\Downloads\TheorieRoady - Blad1.csv"

    with open(input_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)

    for lesson_id, title_nl, description_nl in CHAPTER_12_LESSONS:
        row = [
            "chapter_12",
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

    print(f"Added chapter_12 with {len(CHAPTER_12_LESSONS)} lessons. Written to: {output_path}")


if __name__ == "__main__":
    main()
