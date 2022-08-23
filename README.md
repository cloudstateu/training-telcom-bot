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

### Krok 3: Skonfiguruj wartości unikalne dla środowiska

1. W kroku _"Initialize variable - var audio sas url"_ zmień wartość na URL do kontenera `audio` w Storage Account z nazwą rozpoczynającą się od `sapggtelcomappst`.
1. W kroku _"Initialize variable - var cognitive key"_ zmień wartość na wartość klucza do usługi Speech Service (`cog-speechservice`).
1. W kroku _"Initialize variable - var admin emails"_ podaj adres e-mail na jaki mają być wysyłane alerty o niepoprawnym działaniu usługi.
1. W kroku _"Initialize variable - var recipient config"_ podaj konfigurację (w szczególności adres e-mail) na jaki mają być wysyłane powiadomienia o zgłoszeniu.

### Krok 4: Przetesuj rozwiązanie

1. Przejdź do Azure Storage account z nazwą rozpoczynającą się od: `sapggtelcomappst`. Przejdź do `Containers` i wyświetl zawartość kontenera `audio`.
1. Kliknij `Upload` i udostępnij plik [`02_initial_code/48500000001_48327170009_20220101_000001.wav`](./02_initial_code/48500000001_48327170009_20220101_000001.wav)
1. Wyświetl szczegóły usługi i odczekaj około 2 minut. Po 2 minutach sprawdź czy pojawiło się nowe wywołanie usługi (sekcja `Runs history`). Wywołanie powinno zakończyć się sukcesem.

## Ćwiczenie 3: Dodanie wysyłania wiadomości e-mail z powiadomieniem o zgłoszeniu oraz alertem o niepoprawnym działaniu

### Krok 1: Dodaj wysyłanie wiadomości e-mail z powiadomieniem o zgłoszeniu

1. W sekcji _"Logic app designer"_ znajdź krok `For each` i otwórz go
1. Znajdź krok _"Send email to recipients"_ i otwórz go
1. Kliknij przycisk _"Add an action"_
1. W wyszukiwarce (_"Search connectors and actions"_) wpisz: "Send an email (V2)". Wyszukaj i wybierz pozycję: "Send an email (V2) Office 365 Outlook".
1. Kliknij "Sign in" i zaloguj się swoim kontem w Office 365
1. Po sukcesie logowania uzupełnij krok wysyłania wiadomości zgodnie z poniższymi wartościami:

    - To: 

        ```
        @{items('Send_email_to_recipients')}
        ```

    - Subject: Zgłoszenie BOA @{body('Get_location_by_filename')}
    - Body: 

        ```
        Zgłaszający: @{body('Get_incident_details_from_transcription')['name']}
        Adres: @{body('Get_incident_details_from_transcription')['location']}
        Numer telefonu zgłaszającego: @{body('Get_incident_details_from_transcription')['phone']}
        Numer telefonu, którego zgłoszenie dotyczy: @{body('Get_incident_details_from_transcription')['incidentPhone']}
        Opis uszkodzenia: @{body('Get_incident_details_from_transcription')['description']}

        Pełna transkrypcja zgłoszenia:
        @{variables('var_trans_content')}
        ```

1. Zapisz zmiany klikając "Save"

### Krok 2: Przetestuj wysyłanie wiadomości e-mail z powiadomieniem o zgłoszeniu

1. Przejdź do sekcji _"Overview"_ usługi Logic App
1. W tabeli _"Runs history"_ wybierz wywołanie usługi zakończone powodzeniem
1. Wykonaj ponowne wywołanie klikając _"Resubmit"_
1. Odczekaj około minuty i sprawdź czy wiadomość e-mail została wysłana. Spodziewana wiadomość zawiera treść:

    > Zgłaszający: Adam Adamczyk
    > Adres: Marszałkowska, 11 mieszkania 2, Warszawa
    > Numer telefonu zgłaszającego: 500000001
    > Numer telefonu, którego zgłoszenie dotyczy: 327170009
    > Opis uszkodzenia: Zgłoszenie testowe do scenariusza pierwszego.
    > 
    > Pełna transkrypcja zgłoszenia:
    > Proszę podać imię i nazwisko osoby dokonującej zgłoszenia. Adam Adamczyk. Proszę podać adres, którego zgłoszenie dotyczy. Marszałkowska, 11 mieszkania 2, Warszawa. Proszę podać nr telefonu do kontaktu. 500 000001. Podaj numer telefonu, którego dotyczy zgłoszenie. 32? 717? 0? 0? 0? 9. Podaj krótki opis uszkodzenia. Zgłoszenie testowe do scenariusza pierwszego.

### Krok 3: Dodaj wysyłanie alertu o niepoprawnym działaniu

1. Znajdź krok _"Send email alert to admins if var status is failed"_ i otwórz go
1. W gałęzi _"True"_ otwórz krok _"Send an email alert to admins"_
1. Kliknij przycisk _"Add an action"_
1. W wyszukiwarce (_"Search connectors and actions"_) wpisz: "Send an email (V2)". Wyszukaj i wybierz pozycję: "Send an email (V2) Office 365 Outlook".
1. Uzupełnij krok wysyłania wiadomości zgodnie z poniższymi wartościami:

    - To: 

        ```
        @{items('Send_an_email_alert_to_admins')}
        ```

    - Subject: Błąd w LogicApp
    - Body: 

        ```
        Identyfikator wywołania (run identifier): @{workflow()['run']['name']}
        Status: @{variables('var_status')}
        Komunikat błędu: @{variables('var_error_message')}
        Nazwa pliku: @{variables('var_audio_filename')}

        Zawartość pliku z transkrypcją:
        @{variables('var_trans_content')}
        ```

1. Zapisz zmiany klikając "Save"

### Krok 4: Przetestuj wysyłanie alertu o niepoprawnym działaniu

1. W kontenerze `audio` w Storage Account udostępnij plik [03_send_email/48600000004_48320000000_20220404_000004.wav](./03_send_email/48600000004_48320000000_20220404_000004.wav)
1. Odczekaj 2 minuty i sprawdź czy wiadomość e-mail z alertem została wysłana. Spodziewana wiadomość zawiera treść:

    > Identyfikator wywołania (run identifier): 08585403488745876742767649046CU161
    > Status: fail
    > Komunikat błędu: Nie dopasowano lokalizacji do numeru IVR z nazwy pliku. Nie dopasowano odbiorcy e-mail do numer IVR z nazwy pliku. Nie dopasowano odbiorcy SMS do numeru IVR z nazwy pliku. 
    > Nazwa pliku: 48600000004_48320000000_20220404_000004.wav
    > 
    > Zawartość pliku z transkrypcją:
    > Proszę podać imię i nazwisko osoby dokonującej zgłoszenia. Damian Damian owski. Proszę podać adres, którego zgłoszenie dotyczy. 0 2 0 22 Warszawa do Mińska 2. Proszę podać nr telefonu do kontaktu. 600 000004. Podaj numer telefonu, którego dotyczy zgłoszenie. 302 0000000. Podaj krótki opis uszkodzenia. Zgłoszenie testowe do scenariusza 4 i 5.
