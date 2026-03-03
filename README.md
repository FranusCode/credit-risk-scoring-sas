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
