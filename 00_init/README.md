W tym katalogu znajduje się kod Terraform tworzący w Azure usługi wykorzystywane w rozwiązaniu.

Aby utworzyć nowe środowisko na potrzeby szkoleniowe należy wykonać poniższe komendy:

```bash
terraform init
terraform apply -var=student_name=<login_studenta_lub_dowolny_unikalny_suffix>
```

**Uwaga**: Wykonanie powyższych komend możliwe jest tylko gdy na maszynie z której skrypt jest wykonywany zainstalowany jest Terraform ([docs](https://www.terraform.io/downloads)).