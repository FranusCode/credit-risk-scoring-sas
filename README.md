# Modelowanie ryzyka kredytowego w banku

**Technologie:** SAS Base, SAS SQL, SAS Enterprise Miner

## Cel projektu
Celem projektu jest klasyfikacja ryzyka kredytowego klientów banku. Model przewiduje zmienną `Default`, gdzie:
* `0` = Kredyt spłacony
* `1` = Problemy ze spłatą (ryzyko niewypłacalności)

## Organizacja Danych
Większość pracy w tym projekcie polegała na przygotowaniu danych (ETL). 
* Folder **`source_data/`** zawiera oryginalne, surowe tabele w natywnym formacie SAS (`.sas7bdat`). 
* Aby ułatwić przeglądanie wyników osobom nieposiadającym licencji SAS, gotowa tabela analityczna (połączenie wszystkich danych) została wyeksportowana i znajduje się w głównym folderze jako **`Final_Table.csv`**.

## ETL
Za pomocą **PROC SQL** w SAS Base połączono relacyjne tabele (demografia, historia transakcji, produkty). Wygenerowano 30 zmiennych objaśniających, w tym kluczowe wskaźniki ryzyka:
* **Wskaznik_DTI**: Rata kredytu podzielona przez miesięczny dochód.
* **Wskaznik_Oszczedzania**: Stosunek wydatków do wpływów na koncie.
* **Odchylenie_Salda**: Miara stabilności finansowej klienta (odchylenie standardowe salda).

Pełny skrypt łączący tabele i wyliczający zmienne znajduje się w pliku `przygotowanie_danych.sas`.

## Proces Modelowania
Analizę przeprowadzono w środowisku **SAS Enterprise Miner**. Zbudowano i przetestowano 5 wariantów drzew decyzyjnych w celu znalezienia optymalnej architektury.

![Diagram przepływu](images/diagram_przeplywu.png)

## Wyniki i Wybór Modelu
Modele oceniono na zbiorze walidacyjnym, aby zminimalizować ryzyko przeuczenia.

![Tabela wyników](images/porownanie_drzew.png)

* **Wybrany model:** Drzewo decyzyjne 2.
* **Uzasadnienie:** Model osiągnął najniższy odsetek błędnych klasyfikacji na zbiorze walidacyjnym, wynoszący **ok. 4,8% (0.0483)**. Zbyt rozbudowane modele (np. Drzewo 4 i 5) radziły sobie gorzej na nowych danych (błąd rzędu 6,2%), co świadczyło o ich przeuczeniu (overfittingu).

![Drzewo 2](images/drzewo.png)

---

## Słownik Zmiennych (Data Dictionary)

Poniżej znajduje się pełna lista 30 wygenerowanych zmiennych objaśniających oraz zmienna celu, na których oparto modelowanie. Zostały one pogrupowane logicznie:

**Zmienna celu (Target)**
* `Y-Default`: 0 = Spłacony, 1 = Problemy ze spłatą

**Cechy kredytu i demografia klienta**
* `X1-Kwota_Kredytu`: Wysokość udzielonego kredytu
* `X2-Dlugosc_Kredytu`: Czas trwania w miesiącach
* `X3-Rata_Kredytu`: Miesięczna rata
* `X4-Wiek`: Wiek w momencie brania kredytu
* `X5-Plec`: 1 = Kobieta, 0 = Mężczyzna
* `X10-Staz_Klienta`: Ile miesięcy ma konto przed wzięciem kredytu

**Zmienne makroekonomiczne (dla regionu)**
* `X6-Bezrobocie`: Stopa bezrobocia w regionie zamieszkania
* `X7-Przestepczosc`: Liczba przestępstw w regionie
* `X8-Srednia_Pensja`: Średnie zarobki w regionie
* `X9-Urbanizacja`: Liczba mieszkańców gminy (miasto/wieś)

**Posiadane produkty i zlecenia stałe**
* `X11-Czestosc_Wyciagu`: 1 = Miesięcznie, 0 = Inne
* `X12-Posiada_Karte`: Czy posiada kartę płatniczą
* `X13-Posiada_Karte_Gold`: Czy jest to karta prestiżowa Gold
* `X14-Liczba_Zlecen`: Liczba aktywnych stałych zleceń na koncie
* `X15-Suma_Zlecen`: Łączna kwota miesięcznych stałych opłat
* `X16-Oplaca_Ubezpieczenie`: Czy ma stałe zlecenie na ubezpieczenie
* `X17-Oplaca_Mieszkanie`: Czy płaci czynsz/media przez SIPO

**Historia transakcji i zachowania (agregaty od początku)**
* `X18-Srednie_Saldo`: Średni stan konta od początku
* `X19-Min_Saldo`: Najniższy stan konta w historii
* `X20-Max_Saldo`: Najwyższy stan konta w historii
* `X21-Odchylenie_Salda`: Stabilność finansowa (odchylenie standardowe salda)
* `X22-Suma_Wplywow`: Łączna suma wpłat na konto
* `X23-Suma_Wydatkow`: Łączna suma wydatków
* `X24-Liczba_Transakcji`: Jak często używa konta
* `X25-Liczba_Kar`: Ile razy bank naliczył karne odsetki za brak środków

**Zachowanie w ostatnich 3 miesiącach przed kredytem**
* `X26-Srednie_Saldo_3M`: Średnie saldo z ostatnich 90 dni
* `X27-Min_Saldo_3M`: Czy wpadł w debet tuż przed kredytem
* `X28-Wplywy_3M`: Dochód z ostatnich 3 miesięcy
* `X29-Wskaznik_DTI`: Rata kredytu podzielona przez miesięczny dochód
* `X30-Wskaznik_Oszczedzania`: Stosunek wydatków do wpływów
