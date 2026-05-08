-- Internet Provider Database & System Design
-- MySQL 8+ compatible schema variant

CREATE DATABASE IF NOT EXISTS internet_provider CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE internet_provider;

CREATE TABLE IF NOT EXISTS positions (
    position_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS employees (
    employee_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    position_id BIGINT NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    email VARCHAR(150) NOT NULL UNIQUE,
    login VARCHAR(80) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employees_position FOREIGN KEY (position_id) REFERENCES positions(position_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS clients (
    client_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    client_type VARCHAR(20) NOT NULL,
    last_name VARCHAR(100),
    first_name VARCHAR(100),
    middle_name VARCHAR(100),
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(30) NOT NULL UNIQUE,
    login VARCHAR(80) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_clients_type CHECK (client_type IN ('individual', 'legal_entity'))
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS individual_clients (
    individual_client_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    client_id BIGINT NOT NULL UNIQUE,
    passport_series VARCHAR(4) NOT NULL,
    passport_number VARCHAR(6) NOT NULL,
    birth_date DATE NOT NULL,
    registration_address VARCHAR(255) NOT NULL,
    masked_card_number VARCHAR(25),
    UNIQUE (passport_series, passport_number),
    CONSTRAINT fk_individual_clients_client FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS legal_entities (
    legal_entity_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    client_id BIGINT NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL UNIQUE,
    short_name VARCHAR(100),
    okpo VARCHAR(10) NOT NULL UNIQUE,
    bik VARCHAR(9) NOT NULL,
    legal_address VARCHAR(255) NOT NULL,
    actual_address VARCHAR(255),
    technical_contact_phone VARCHAR(30) NOT NULL UNIQUE,
    CONSTRAINT fk_legal_entities_client FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS equipment_types (
    equipment_type_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS brands (
    brand_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS models (
    model_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    brand_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    UNIQUE (brand_id, name),
    CONSTRAINT fk_models_brand FOREIGN KEY (brand_id) REFERENCES brands(brand_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS specifications (
    specification_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    unit VARCHAR(30)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS equipment (
    equipment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    equipment_type_id BIGINT NOT NULL,
    model_id BIGINT NOT NULL,
    name VARCHAR(150) NOT NULL,
    bandwidth_mbps INT,
    article VARCHAR(14) NOT NULL UNIQUE,
    price DECIMAL(12, 2) NOT NULL,
    image_url VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_equipment_type FOREIGN KEY (equipment_type_id) REFERENCES equipment_types(equipment_type_id),
    CONSTRAINT fk_equipment_model FOREIGN KEY (model_id) REFERENCES models(model_id),
    CONSTRAINT chk_equipment_price CHECK (price >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS equipment_specifications (
    equipment_specification_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    equipment_id BIGINT NOT NULL,
    specification_id BIGINT NOT NULL,
    value VARCHAR(120) NOT NULL,
    UNIQUE (equipment_id, specification_id),
    CONSTRAINT fk_equipment_spec_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id) ON DELETE CASCADE,
    CONSTRAINT fk_equipment_spec_specification FOREIGN KEY (specification_id) REFERENCES specifications(specification_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS services (
    service_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    article VARCHAR(14) NOT NULL UNIQUE,
    setup_price DECIMAL(12, 2) NOT NULL DEFAULT 0,
    monthly_price DECIMAL(12, 2) NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_services_prices CHECK (setup_price >= 0 AND monthly_price >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS agreements (
    agreement_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    number VARCHAR(20) NOT NULL UNIQUE,
    formation_date DATE NOT NULL,
    work_cost DECIMAL(12, 2) NOT NULL DEFAULT 0,
    monthly_payment DECIMAL(12, 2) NOT NULL DEFAULT 0,
    equipment_purchase_total_cost DECIMAL(12, 2) NOT NULL DEFAULT 0,
    payment_deadline_day SMALLINT NOT NULL,
    client_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_agreements_client FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_agreements_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS agreement_equipment (
    agreement_equipment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    agreement_id BIGINT NOT NULL,
    equipment_id BIGINT NOT NULL,
    quantity DECIMAL(12, 2) NOT NULL,
    unit VARCHAR(20) NOT NULL DEFAULT 'pcs',
    unit_price DECIMAL(12, 2) NOT NULL,
    UNIQUE (agreement_id, equipment_id),
    CONSTRAINT fk_agreement_equipment_agreement FOREIGN KEY (agreement_id) REFERENCES agreements(agreement_id) ON DELETE CASCADE,
    CONSTRAINT fk_agreement_equipment_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS agreement_services (
    agreement_service_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    agreement_id BIGINT NOT NULL,
    service_id BIGINT NOT NULL,
    quantity DECIMAL(12, 2) NOT NULL DEFAULT 1,
    setup_price DECIMAL(12, 2) NOT NULL,
    monthly_price DECIMAL(12, 2) NOT NULL,
    UNIQUE (agreement_id, service_id),
    CONSTRAINT fk_agreement_services_agreement FOREIGN KEY (agreement_id) REFERENCES agreements(agreement_id) ON DELETE CASCADE,
    CONSTRAINT fk_agreement_services_service FOREIGN KEY (service_id) REFERENCES services(service_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payment_operations (
    payment_operation_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    agreement_id BIGINT NOT NULL,
    operation_number VARCHAR(30) NOT NULL UNIQUE,
    operation_type VARCHAR(30) NOT NULL,
    amount_due DECIMAL(12, 2) NOT NULL,
    amount_paid DECIMAL(12, 2) NOT NULL DEFAULT 0,
    operation_date DATE NOT NULL,
    operation_time TIME NOT NULL,
    comment TEXT,
    CONSTRAINT fk_payment_operations_agreement FOREIGN KEY (agreement_id) REFERENCES agreements(agreement_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS connection_requests (
    connection_request_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    client_id BIGINT NOT NULL,
    requested_service_id BIGINT,
    connection_address VARCHAR(255) NOT NULL,
    requested_bandwidth_mbps INT,
    status VARCHAR(30) NOT NULL DEFAULT 'new',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_by_employee_id BIGINT,
    decision_comment TEXT,
    CONSTRAINT fk_connection_requests_client FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
    CONSTRAINT fk_connection_requests_service FOREIGN KEY (requested_service_id) REFERENCES services(service_id),
    CONSTRAINT fk_connection_requests_employee FOREIGN KEY (processed_by_employee_id) REFERENCES employees(employee_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS technical_tickets (
    technical_ticket_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    connection_request_id BIGINT,
    agreement_id BIGINT,
    assigned_employee_id BIGINT,
    equipment_id BIGINT,
    status VARCHAR(30) NOT NULL DEFAULT 'open',
    priority VARCHAR(20) NOT NULL DEFAULT 'medium',
    description TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    CONSTRAINT fk_tickets_request FOREIGN KEY (connection_request_id) REFERENCES connection_requests(connection_request_id) ON DELETE SET NULL,
    CONSTRAINT fk_tickets_agreement FOREIGN KEY (agreement_id) REFERENCES agreements(agreement_id) ON DELETE SET NULL,
    CONSTRAINT fk_tickets_employee FOREIGN KEY (assigned_employee_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_tickets_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS network_capacity_updates (
    network_capacity_update_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    available_bandwidth_mbps INT NOT NULL,
    network_equipment_count INT NOT NULL,
    peripheral_equipment_count INT NOT NULL,
    comment TEXT,
    CONSTRAINT fk_capacity_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
) ENGINE=InnoDB;
