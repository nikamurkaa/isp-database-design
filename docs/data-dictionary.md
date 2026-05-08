# Словарь данных

Словарь описывает очищенную публичную схему репозитория. Исходные учебные материалы были приведены к единому стилю: английские `snake_case` имена таблиц и полей используются в SQL, а описание хранится в Markdown.

## Пользователи и клиенты

### `positions`

| Поле | Тип | Обязательное | Описание |
| --- | --- | --- | --- |
| `position_id` | BIGINT | да | Суррогатный первичный ключ. |
| `name` | VARCHAR(80) | да | Уникальное название должности. |
| `description` | TEXT | нет | Описание зоны ответственности. |

### `employees`

| Поле | Тип | Обязательное | Описание |
| --- | --- | --- | --- |
| `employee_id` | BIGINT | да | Суррогатный первичный ключ. |
| `position_id` | BIGINT | да | FK на `positions`. |
| `last_name` | VARCHAR(100) | да | Фамилия сотрудника. |
| `first_name` | VARCHAR(100) | да | Имя сотрудника. |
| `middle_name` | VARCHAR(100) | нет | Отчество при наличии. |
| `email` | VARCHAR(150) | да | Уникальный email. |
| `login` | VARCHAR(80) | да | Уникальный логин. |
| `password_hash` | VARCHAR(255) | да | Хеш пароля; в демо-данных используется безопасный placeholder. |
| `is_active` | BOOLEAN | да | Флаг активности сотрудника. |
| `created_at` | TIMESTAMPTZ | да | Дата и время создания записи. |

### `clients`

| Поле | Тип | Обязательное | Описание |
| --- | --- | --- | --- |
| `client_id` | BIGINT | да | Суррогатный первичный ключ. |
| `client_type` | VARCHAR(20) | да | `individual` или `legal_entity`. |
| `last_name` | VARCHAR(100) | для физлиц | Фамилия клиента. |
| `first_name` | VARCHAR(100) | для физлиц | Имя клиента. |
| `middle_name` | VARCHAR(100) | нет | Отчество при наличии. |
| `email` | VARCHAR(150) | нет | Уникальный email при наличии. |
| `phone` | VARCHAR(30) | да | Уникальный телефон. |
| `login` | VARCHAR(80) | да | Уникальный логин. |
| `password_hash` | VARCHAR(255) | да | Хеш пароля; в демо-данных используется placeholder. |
| `created_at` | TIMESTAMPTZ | да | Дата и время создания записи. |

### `individual_clients`

| Поле | Тип | Обязательное | Описание |
| --- | --- | --- | --- |
| `individual_client_id` | BIGINT | да | Суррогатный первичный ключ. |
| `client_id` | BIGINT | да | Уникальный FK на `clients`. |
| `passport_series` | VARCHAR(4) | да | Демо-безопасное значение; уникально вместе с номером. |
| `passport_number` | VARCHAR(6) | да | Демо-безопасное значение; уникально вместе с серией. |
| `birth_date` | DATE | да | Дата рождения. |
| `registration_address` | VARCHAR(255) | да | Адрес регистрации. |
| `masked_card_number` | VARCHAR(25) | нет | Только маскированный номер карты. |

### `legal_entities`

| Поле | Тип | Обязательное | Описание |
| --- | --- | --- | --- |
| `legal_entity_id` | BIGINT | да | Суррогатный первичный ключ. |
| `client_id` | BIGINT | да | Уникальный FK на `clients`. |
| `full_name` | VARCHAR(255) | да | Уникальное полное название компании. |
| `short_name` | VARCHAR(100) | нет | Краткое название. |
| `okpo` | VARCHAR(10) | да | Уникальный демо‑идентификатор. |
| `bik` | VARCHAR(9) | да | Демо‑значение банковского идентификатора. |
| `legal_address` | VARCHAR(255) | да | Юридический адрес. |
| `actual_address` | VARCHAR(255) | нет | Фактический адрес. |
| `technical_contact_phone` | VARCHAR(30) | да | Уникальный телефон технического контакта. |

## Каталог

### `equipment_types`, `brands`, `models`

| Таблица | Назначение |
| --- | --- |
| `equipment_types` | Справочник типов оборудования: телекоммуникационное, сетевое и т.д. |
| `brands` | Справочник брендов оборудования. |
| `models` | Модели оборудования, связанные с брендами. |

### `equipment`

| Поле | Тип | Обязательное | Описание |
| --- | --- | --- | --- |
| `equipment_id` | BIGINT | да | Суррогатный первичный ключ. |
| `equipment_type_id` | BIGINT | да | FK на `equipment_types`. |
| `model_id` | BIGINT | да | FK на `models`. |
| `name` | VARCHAR(150) | да | Название оборудования. |
| `bandwidth_mbps` | INTEGER | нет | Пропускная способность при наличии. |
| `article` | VARCHAR(14) | да | Уникальный артикул. |
| `price` | NUMERIC(12,2) | да | Неотрицательная цена. |
| `image_url` | VARCHAR(255) | нет | Ссылка на изображение при наличии. |
| `is_active` | BOOLEAN | да | Флаг активности позиции каталога. |

### `specifications` и `equipment_specifications`

| Таблица | Назначение |
| --- | --- |
| `specifications` | Справочник характеристик: длина, материал, разрешение, охлаждение и т.д. |
| `equipment_specifications` | Таблица связи, которая хранит значения характеристик для конкретного оборудования. |

### `services`

| Поле | Тип | Обязательное | Описание |
| --- | --- | --- | --- |
| `service_id` | BIGINT | да | Суррогатный первичный ключ. |
| `name` | VARCHAR(150) | да | Уникальное название услуги. |
| `description` | TEXT | да | Описание услуги. |
| `article` | VARCHAR(14) | да | Уникальный артикул. |
| `setup_price` | NUMERIC(12,2) | да | Неотрицательная стоимость подключения. |
| `monthly_price` | NUMERIC(12,2) | да | Неотрицательная ежемесячная стоимость. |
| `is_active` | BOOLEAN | да | Флаг активности услуги. |

## Договоры и платежи

### `agreements`

| Поле | Тип | Обязательное | Описание |
| --- | --- | --- | --- |
| `agreement_id` | BIGINT | да | Суррогатный первичный ключ. |
| `number` | VARCHAR(20) | да | Уникальный номер договора. |
| `formation_date` | DATE | да | Дата оформления. |
| `work_cost` | NUMERIC(12,2) | да | Стоимость работ. |
| `monthly_payment` | NUMERIC(12,2) | да | Ежемесячный платеж. |
| `equipment_purchase_total_cost` | NUMERIC(12,2) | да | Итоговая стоимость оборудования. |
| `payment_deadline_day` | SMALLINT | да | День оплаты: 1–28. |
| `client_id` | BIGINT | да | FK на `clients`. |
| `employee_id` | BIGINT | да | FK на `employees`. |
| `status` | VARCHAR(20) | да | `draft`, `active`, `suspended`, `closed`. |
| `created_at` | TIMESTAMPTZ | да | Дата и время создания записи. |

### `agreement_equipment` и `agreement_services`

Эти таблицы хранят детали договора и фиксируют исторические цены на момент оформления.

| Таблица | Ключевые поля |
| --- | --- |
| `agreement_equipment` | `agreement_id`, `equipment_id`, `quantity`, `unit`, `unit_price`. |
| `agreement_services` | `agreement_id`, `service_id`, `quantity`, `setup_price`, `monthly_price`. |

### `payment_operations`

| Поле | Тип | Обязательное | Описание |
| --- | --- | --- | --- |
| `payment_operation_id` | BIGINT | да | Суррогатный первичный ключ. |
| `agreement_id` | BIGINT | да | FK на `agreements`. |
| `operation_number` | VARCHAR(30) | да | Уникальный номер операции. |
| `operation_type` | VARCHAR(30) | да | `equipment_purchase`, `monthly_payment`, `installation_work`, `refund`. |
| `amount_due` | NUMERIC(12,2) | да | Начисленная сумма. |
| `amount_paid` | NUMERIC(12,2) | да | Оплаченная сумма, не больше начисленной. |
| `operation_date` | DATE | да | Дата операции. |
| `operation_time` | TIME | да | Время операции. |
| `comment` | TEXT | нет | Комментарий. |

## Заявки, технические задачи и мощность сети

### `connection_requests`

| Поле | Тип | Обязательное | Описание |
| --- | --- | --- | --- |
| `connection_request_id` | BIGINT | да | Суррогатный первичный ключ. |
| `client_id` | BIGINT | да | FK на `clients`. |
| `requested_service_id` | BIGINT | нет | FK на `services`. |
| `connection_address` | VARCHAR(255) | да | Адрес подключения. |
| `requested_bandwidth_mbps` | INTEGER | нет | Запрошенная скорость. |
| `status` | VARCHAR(30) | да | `new`, `capacity_check`, `approved`, `rejected`, `in_progress`, `completed`. |
| `processed_by_employee_id` | BIGINT | нет | FK на `employees`. |
| `decision_comment` | TEXT | нет | Комментарий по решению или проверке мощности. |

### `technical_tickets`

| Поле | Тип | Обязательное | Описание |
| --- | --- | --- | --- |
| `technical_ticket_id` | BIGINT | да | Суррогатный первичный ключ. |
| `connection_request_id` | BIGINT | нет | Связанная заявка на подключение. |
| `agreement_id` | BIGINT | нет | Связанный договор. |
| `assigned_employee_id` | BIGINT | нет | Назначенный сотрудник. |
| `equipment_id` | BIGINT | нет | Связанное оборудование. |
| `status` | VARCHAR(30) | да | `open`, `assigned`, `in_progress`, `resolved`, `closed`. |
| `priority` | VARCHAR(20) | да | `low`, `medium`, `high`, `critical`. |
| `description` | TEXT | да | Описание задачи. |
| `created_at` | TIMESTAMPTZ | да | Дата и время создания. |
| `resolved_at` | TIMESTAMPTZ | нет | Дата и время решения. |

### `network_capacity_updates`

| Поле | Тип | Обязательное | Описание |
| --- | --- | --- | --- |
| `network_capacity_update_id` | BIGINT | да | Суррогатный первичный ключ. |
| `employee_id` | BIGINT | да | FK на `employees`. |
| `updated_at` | TIMESTAMPTZ | да | Время снимка состояния. |
| `available_bandwidth_mbps` | INTEGER | да | Доступная пропускная способность. |
| `network_equipment_count` | INTEGER | да | Количество доступного сетевого оборудования. |
| `peripheral_equipment_count` | INTEGER | да | Количество доступного периферийного оборудования. |
| `comment` | TEXT | нет | Комментарий. |
