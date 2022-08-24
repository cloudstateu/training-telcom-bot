# Azure Functions

## Wymagania wstępne

1. Certyfikat wygenerowany na stronie https://superinfo.t-mobile.pl/. Certyfikaty mogą wygenerować użytkownicy posiadający konto w usłudze t-Mobile. Wygenerowany certyfikat (plik `*.pem`) powinien zostać skopiowany do katalogu `./sms`. Plik powinien mieć nazwę: `cert.pem`.

## Infrastruktura

### Niezbędne

Tworzymy podejściem ClickOps :(

1. Utwórz Application Insights

    - name: telcombot-dev-appins
    - workspace: lawpggtelcomapp

2. Utwórz Function App

    - name: telcombot-dev-func
    - publish: code
    - runtime: Node.js
    - version: 16 LTS
    - region: West Europe
    - operating system: Linux
    - plan type: Consumption (Serverless)

    - Hosting > Storage account: telcombotdevfuncsa

    - Monitoring > Application Insights: telcombot-dev-appins

## Wdrożenie

Skorzystaj ze skryptu `./deploy.sh`. Upewnij się, że w katalogu `./sms` znajduje się plik `cert.pem`.
