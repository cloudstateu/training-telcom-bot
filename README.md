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

1. Zapisz zmiany w Logic App klikając _"Save"_ ponad oknem projektanta

### Krok 2: Zmień kod Logic App

1. Wyświetl szczegóły Logic App, przejdź do zakładki `Logic app designer`, kliknij `Code view` ponad oknem projektanta
1. Zlokalizuj property `actions` i podmień wartość property (obiekt Javascript) na zawartość pliku [`02_initial_code/actions.json`](./02_initial_code/actions.json)
1. Zapisz zmiany w Logic App klikając _"Save"_ ponad oknem projektanta

### Krok 3: Skonfiguruj wartości unikalne dla środowiska

1. W kroku _"Initialize variable - var audio sas url"_ zmień wartość na URL do kontenera `audio` w Storage Account z nazwą rozpoczynającą się od `sapggtelcomappst`.
1. W kroku _"Initialize variable - var cognitive key"_ zmień wartość na wartość klucza do usługi Speech Service (`cog-speechservice`).
1. W kroku _"Initialize variable - var admin emails"_ podaj adres e-mail na jaki mają być wysyłane alerty o niepoprawnym działaniu usługi.
1. W kroku _"Initialize variable - var recipient config"_ podaj konfigurację (w szczególności adres e-mail) na jaki mają być wysyłane powiadomienia o zgłoszeniu.
1. Zapisz zmiany w Logic App klikając _"Save"_ ponad oknem projektanta

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

1. Zapisz zmiany w Logic App klikając _"Save"_ ponad oknem projektanta

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

1. Zapisz zmiany w Logic App klikając _"Save"_ ponad oknem projektanta

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

## Ćwiczenie 5: Dodaj numer zgłoszenia do tytułu powiadomienia o zgłoszeniu

### Krok 1: Pobierz ostatni numer zgłoszenia z bazy danych

1. Przejdź do _"Logic app designer"_, znajdź krok `Parse var recipient config`, kliknij ikonę `+` na strzałce poniżej kroku i wybierz pozycję _"Add an action"_
1. W wyszukiwarce akcji wpisz _"Get entity (V2)"_ i wybierz krok _"Get entity (V2) (preview)"_
1. Skonfiguruj połączenie do bazy danych zgodnie z poniższymi wartościami:

    - Connection name: `azuretable`
    - Authentication type: Access Key
    - Storage Account name: `sapggtelcomapp<student_name>` (w miejsce `<student_name>` wstaw swój login np. `st01`)
    - Shared Storage Key: `<wklej storage key znaleziony w ćwiczeniu 2>`

1. Skonfiguruj zapytanie zwracjące ostatni numer zgłoszenia zgodnie z poniższymi wartościami:

    - Storage account name: `sapggtelcomapp<student_name>` (w miejsce `<student_name>` wstaw swój login np. `st01`)
    - Table: `config`
    - Partition Key: `incident_number`
    - Row Key: `1`

1. Zapisz zmiany w Logic App klikając _"Save"_ ponad oknem projektanta

### Krok 2: Zaktualizuj numer zgłoszenia

1. Poniżej kroku `Get entity (V2)`, kliknij ikonę `+` na strzałce poniżej kroku i wybierz pozycję _"Add an action"_
1. W wyszukiwarce akcji wpisz _"Replace Entity (V2)"_ i wybierz krok _"Replace Entity (V2) (preview)"_
1. Skonfiguruj zapytanie aktualizujące numer zgłoszenia zgodnie z poniższymi wartościami:

    - Storage account name: `sapggtelcomapp<student_name>` (w miejsce `<student_name>` wstaw swój login np. `st01`)
    - Table: `config`
    - Partition Key: `incident_number`
    - Row Key: `1`
    - ETag: `*`
    - Entity: 

        ```
        {
          "value": @{add(int(body('Get_entity_(V2)')?['value']), 1)}
        }
        ```

1. Zapisz zmiany w Logic App klikając _"Save"_ ponad oknem projektanta

### Krok 3: Dodaj numer zgłoszenia do powiadomienia e-mail o zgłoszeniu

1. Znajdź krok `For each` > `Send email to recipients` > `Send an email (V2) Office 365 Outlook` i otwórz go
1. Zaktualizuj tytuł wiadomości zgodnie z poniższą wartością:

    ```
    Zgłoszenie BOA @{int(body('Get_entity_(V2)')?['value'])} @{body('Get_location_by_filename')}
    ```

1. Zapisz zmiany w Logic App klikając _"Save"_ ponad oknem projektanta

### Krok 4: Przetestuj wysyłanie wiadomości e-mail z powiadomieniem o zgłoszeniu

1. Przejdź do sekcji _"Overview"_ usługi Logic App
1. W tabeli _"Runs history"_ wybierz wywołanie usługi zakończone powodzeniem
1. Wykonaj ponowne wywołanie klikając _"Resubmit"_
1. Odczekaj około minuty i sprawdź czy wiadomość e-mail została wysłana. Sprawdź czy tytuł wiadomości zawiera numer zgłoszenia.

## Ćwiczenie 5: Wysłanie SMS z powiadomieniem o zgłoszeniu

### Krok 1: Wdróż kod Azure Function komunikujący się z bramką SMS

1. Przejdź do katalogu `05_send_sms/functions` i wykonaj komendę `npm i`
1. Pobierz certyfikat uwierzytelniający komunikację z bramką SMS. Wykonaj poniższą komendę w  katalogu `/functions/sms`:

    ```
    curl <url_do_pobrania_certyfikatu> --output cert.pem
    ```

1. Wykonaj `./deploy.sh` (w katalogu `/functions`)
1. Sprawdź czy w Azure Function App z nazwą znajduje się funkcja z nazwą `sms`. Otwórz funkcje i pobierz URL do niej (klikając _"Get Function Url"_)
1. Przetestuj funkcje (uzupełnij zapytanie swoimi danymi)

    ```
    curl -X POST <url_do_funkcji_sms> -H 'Content-Type: application-json' -d '{"recipient": "<twoj_numer_telefonu>", "content": "Witam", "msisdn": "500032008"}'
    ```

### Krok 2: Dodaj krok wysyłający SMS z powiadomieniem o zgłoszeniu

1. W sekcji _"Logic app designer"_ znajdź krok `For each` i otwórz go
1. Znajdź krok _"Send SMS to recipients"_ i otwórz go
1. Kliknij przycisk _"Add an action"_
1. W wyszukiwarce (_"Search connectors and actions"_) wpisz: "Azure Functions". Wyszukaj i wybierz pozycję: "Choose an Azure Function". Na kolejnym ekranie wybierz nazwę swojej Azure Function App.
1. Na kolejnym ekranie wybierz nazwę funkcji - `sms`
1. Skonfiguruj zapytanie wysyłane z Logic App do Azure Function zgodnie z poniższymi wartościami:

    - Request Body:

        ```
        {
            "content": "Zgłoszenie BOA @{int(body('Get_entity_(V2)')?['value'])} @{body('Get_location_by_filename')} Odbierz e-maila",
            "recipient": "@{items('Send_SMS_to_recipients')}",
            "msisdn": "500032008"
        }
        ```
    

1. Zapisz zmiany w Logic App klikając _"Save"_ ponad oknem projektanta

### Krok 3: Przetestuj wysyłanie wiadomości SMS z powiadomieniem o zgłoszeniu

1. Przejdź do sekcji _"Overview"_ usługi Logic App
1. W tabeli _"Runs history"_ wybierz wywołanie usługi zakończone powodzeniem
1. Wykonaj ponowne wywołanie klikając _"Resubmit"_
1. Odczekaj około minuty i sprawdź czy wiadomość SMS została wysłana na numer telefonu odbiorcy.


## Ćwiczenie 6: Dodaj raporty do aplikacji

### Krok 1: Skonfiguruj zbieranie logów z aplikacji

1. Po kroku "For each" (a przed krokiem "Send email alert to admins if var starus is failed") dodaj nową akcję. Wyszukaj usługę "Azure Log Analytics Data Collector" i wybierz akcję "Send data".
1. W drugiej zakładce przeglądarki otwórz stronę usługi Log Analytics workspace. Otwórz stronę _Settings_ > _Agents management_ > _Linux servers_ (zakładka) > _Log Analytics agent instructions_ (sekcja).
1. Skonfiguruj połączenie z Log Analytics zgodnie z poniższymi wartościami:

    - Connection name: `logs`
    - Workspace ID: `<skopiowany z poprzedniego kroku>`
    - Workspace Key:  `<skopiowany z poprzedniego kroku>`

1. Skonfiguruj format wpisu z logiem:

    - JSON Request body:

        ```
        { status: "@{variables('var_status')}", data: { content: "@{variables('var_trans_content')}", filename: "@{variables('var_audio_filename')}", localization: "@{body('Get_location_by_filename')}", error: "@{variables('var_error_message')}", identifier: "@{workflow()['run']['name']}" }}
        ```

    - Custom Log Name: `process_summary`

1. Zapisz zmiany w Logic App klikając _"Save"_ ponad oknem projektanta

### Krok 2: Przetestuj działanie Logic App po zmianach

1. Przejdź do sekcji _"Overview"_ usługi Logic App
1. W tabeli _"Runs history"_ wybierz wywołanie usługi zakończone powodzeniem
1. Wykonaj ponowne wywołanie klikając _"Resubmit"_
1. Odczekaj około minuty i sprawdź czy wywołanie zakonczyło się sukcesem

### Krok 3: Dodaj widok raportu

1. Przejdź do usługi Log Analytics workspace
1. Otwórz stronę "Workbooks" (pod sekcją "General" w menu)
1. Kliknij "+ New"
1. Przejdź do widoku kodu dla tworzonego Workbook
1. Podmień zawartość tablicy `items` zawartoscia z pliku
1. Zapisz zmiany i odczekaj kilka minut na wygenerowanie pierwszego raportu
