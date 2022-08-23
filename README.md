# Szkolenie "Zapoznanie z systemem zgłaszania awarii telekomunikacyjnych"

TBA

## Wymagania wstępne

1. W Azure utworzone są usługi wykorzystywane w rozwiązaniu ([source](./00_init/))

## Ćwiczenie 1: Konfiguracja Cloud Shell

## Ćwiczenie 2: Udostępnienie pierwszej wersji kodu

### Krok 1: Wstępna konfiguracja Logic App

1. Uruchom Azure Portal w dwóch kartach przeglądarki
1. W jednej karcie przeglądarki otwórz szczegóły usługi Azure Storage Account z nazwą `sapggtelcomapp<student_name>` (w miejsce `<student_name>` wstaw swój login np. `st01`). Wyświetl szczegóły `Access Keys`. Wyświetl i skopiuj znaki wybranego klucza.
1. W drugiej karcie przeglądraki wyświetl szczegóły usługi Logic App z nazwą `logic-telcomapp`
1. Rozpocznij konfigurację Logic App z pustym szablonem (`Templates` > `Blank Logic App`)
1. Skonfiguruj Trigger `Azure Blob Storage` > `When a blob is added or modified (properties only) (V2)`. Podaj następujące wartości:

    - Name: `azureblob`
    - Authentication type: `Access Key`
    - Azure Storage Account name: `sapggtelcomapp<student_name>` (w miejsce `<student_name>` wstaw swój login np. `st01`)
    - Azure Storage Account Access Key: wklej skopiowany Access Key z kroku 2.

1. Kliknij `Create`
1. Podaj kolejne wartości konfiguracyjne:

    - Storage account name: z rozwijanego menu wybierz `connection string` z nazwą Twojego Azure Storage Account
    - Container: z rozwijanego menu wybierz folder `audio`
    - How often do you want to check for items?: `1 minute`

1. Zapisz zmiany klikając `Save` ponad oknem projektanta

### Krok 2: Zmień kod Logic App

1. Wyświetl szczegóły Logic App, przejdź do zakładki `Logic app designer`, kliknij `Code view` ponad oknem projektanta
1. Zlokalizuj property `actions` i podmień wartość property (obiekt Javascript) na zawartość pliku [`02_initial_code/actions.json`](./02_initial_code/actions.json)
1. Kliknij `Save`

## Krok 3: Skonfiguruj wartości unikalne dla środowiska

1. W kroku _"Initialize variable - var audio sas url"_ zmień wartość na URL do kontenera `audio` w Storage Account z nazwą rozpoczynającą się od `sapggtelcomappst`.
1. W kroku _"Initialize variable - var cognitive key"_ zmień wartość na wartość klucza do usługi Speech Service (`cog-speechservice`).
1. W kroku _"Initialize variable - var admin emails"_ podaj adres e-mail na jaki mają być wysyłane alerty o niepoprawnym działaniu usługi.
1. W kroku _"Initialize variable - var recipient config"_ podaj konfigurację (w szczególności adres e-mail) na jaki mają być wysyłane powiadomienia o zgłoszeniu.

## Krok 4: Przetesuj rozwiązanie

1. Przejdź do Azure Storage account z nazwą rozpoczynającą się od: `sapggtelcomappst`. Przejdź do `Containers` i wyświetl zawartość kontenera `audio`.
1. Kliknij `Upload` i udostępnij plik [`02_initial_code/48500000001_48327170009_20220101_000001.wav`](./02_initial_code/48500000001_48327170009_20220101_000001.wav)
1. Wyświetl szczegóły usługi i odczekaj około 2 minut. Po 2 minutach sprawdź czy pojawiło się nowe wywołanie usługi (sekcja `Runs history`). Wywołanie powinno zakończyć się sukcesem.