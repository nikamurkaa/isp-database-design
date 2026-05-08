# MySQL-вариант

В этой папке лежит MySQL‑совместимая версия схемы и небольшой набор безопасных демо‑данных.

PostgreSQL остаётся основной исполняемой реализацией портфолио‑кейса, потому что в ней дополнительно реализованы views, functions, procedures, RBAC и быстрый запуск через Docker Compose.

Запуск вручную в MySQL 8+:

```bash
mysql -u root -p < 01_schema.sql
mysql -u root -p internet_provider < 02_seed_data.sql
```
