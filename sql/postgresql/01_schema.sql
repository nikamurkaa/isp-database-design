-- Internet Provider Database & System Design
-- PostgreSQL schema

CREATE SCHEMA IF NOT EXISTS provider;
SET search_path TO provider, public;

CREATE TABLE IF NOT EXISTS positions (
    position_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS employees (
    employee_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    position_id BIGINT NOT NULL REFERENCES positions(position_id) ON UPDATE CASCADE,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    email VARCHAR(150) NOT NULL UNIQUE,
    login VARCHAR(80) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS clients (
    client_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_type VARCHAR(20) NOT NULL CHECK (client_type IN ('individual', 'legal_entity')),
    last_name VARCHAR(100),
    first_name VARCHAR(100),
    middle_name VARCHAR(100),
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(30) NOT NULL UNIQUE,
    login VARCHAR(80) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (
        (client_type = 'individual' AND last_name IS NOT NULL AND first_name IS NOT NULL)
        OR client_type = 'legal_entity'
    )
);

CREATE TABLE IF NOT EXISTS individual_clients (
    individual_client_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id BIGINT NOT NULL UNIQUE REFERENCES clients(client_id) ON DELETE CASCADE,
    passport_series VARCHAR(4) NOT NULL CHECK (passport_series ~ '^[0-9]{4}$'),
    passport_number VARCHAR(6) NOT NULL CHECK (passport_number ~ '^[0-9]{6}$'),
    birth_date DATE NOT NULL,
    registration_address VARCHAR(255) NOT NULL,
    masked_card_number VARCHAR(25),
    UNIQUE (passport_series, passport_number)
);

CREATE TABLE IF NOT EXISTS legal_entities (
    legal_entity_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id BIGINT NOT NULL UNIQUE REFERENCES clients(client_id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL UNIQUE,
    short_name VARCHAR(100),
    okpo VARCHAR(10) NOT NULL UNIQUE CHECK (okpo ~ '^([0-9]{8}|[0-9]{10})$'),
    bik VARCHAR(9) NOT NULL CHECK (bik ~ '^[0-9]{9}$'),
    legal_address VARCHAR(255) NOT NULL,
    actual_address VARCHAR(255),
    technical_contact_phone VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS equipment_types (
    equipment_type_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS brands (
    brand_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS models (
    model_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    brand_id BIGINT NOT NULL REFERENCES brands(brand_id) ON UPDATE CASCADE,
    name VARCHAR(100) NOT NULL,
    UNIQUE (brand_id, name)
);

CREATE TABLE IF NOT EXISTS specifications (
    specification_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    unit VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS equipment (
    equipment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    equipment_type_id BIGINT NOT NULL REFERENCES equipment_types(equipment_type_id) ON UPDATE CASCADE,
    model_id BIGINT NOT NULL REFERENCES models(model_id) ON UPDATE CASCADE,
    name VARCHAR(150) NOT NULL,
    bandwidth_mbps INTEGER CHECK (bandwidth_mbps IS NULL OR bandwidth_mbps > 0),
    article VARCHAR(14) NOT NULL UNIQUE CHECK (article ~ '^[A-Z]{3}-[0-9]{10}$'),
    price NUMERIC(12, 2) NOT NULL CHECK (price >= 0),
    image_url VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS equipment_specifications (
    equipment_specification_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    equipment_id BIGINT NOT NULL REFERENCES equipment(equipment_id) ON DELETE CASCADE,
    specification_id BIGINT NOT NULL REFERENCES specifications(specification_id) ON DELETE RESTRICT,
    value VARCHAR(120) NOT NULL,
    UNIQUE (equipment_id, specification_id)
);

CREATE TABLE IF NOT EXISTS services (
    service_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    article VARCHAR(14) NOT NULL UNIQUE CHECK (article ~ '^[A-Z]{3}-[0-9]{10}$'),
    setup_price NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (setup_price >= 0),
    monthly_price NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (monthly_price >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS agreements (
    agreement_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    number VARCHAR(20) NOT NULL UNIQUE CHECK (number ~ '^AGR-[0-9]{10}-[0-9]{4}$'),
    formation_date DATE NOT NULL DEFAULT CURRENT_DATE,
    work_cost NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (work_cost >= 0),
    monthly_payment NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (monthly_payment >= 0),
    equipment_purchase_total_cost NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (equipment_purchase_total_cost >= 0),
    payment_deadline_day SMALLINT NOT NULL CHECK (payment_deadline_day BETWEEN 1 AND 28),
    client_id BIGINT NOT NULL REFERENCES clients(client_id) ON UPDATE CASCADE,
    employee_id BIGINT NOT NULL REFERENCES employees(employee_id) ON UPDATE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('draft', 'active', 'suspended', 'closed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS agreement_equipment (
    agreement_equipment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agreement_id BIGINT NOT NULL REFERENCES agreements(agreement_id) ON DELETE CASCADE,
    equipment_id BIGINT NOT NULL REFERENCES equipment(equipment_id) ON UPDATE CASCADE,
    quantity NUMERIC(12, 2) NOT NULL CHECK (quantity > 0),
    unit VARCHAR(20) NOT NULL DEFAULT 'pcs',
    unit_price NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0),
    UNIQUE (agreement_id, equipment_id)
);

CREATE TABLE IF NOT EXISTS agreement_services (
    agreement_service_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agreement_id BIGINT NOT NULL REFERENCES agreements(agreement_id) ON DELETE CASCADE,
    service_id BIGINT NOT NULL REFERENCES services(service_id) ON UPDATE CASCADE,
    quantity NUMERIC(12, 2) NOT NULL DEFAULT 1 CHECK (quantity > 0),
    setup_price NUMERIC(12, 2) NOT NULL CHECK (setup_price >= 0),
    monthly_price NUMERIC(12, 2) NOT NULL CHECK (monthly_price >= 0),
    UNIQUE (agreement_id, service_id)
);

CREATE TABLE IF NOT EXISTS payment_operations (
    payment_operation_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agreement_id BIGINT NOT NULL REFERENCES agreements(agreement_id) ON DELETE CASCADE,
    operation_number VARCHAR(30) NOT NULL UNIQUE,
    operation_type VARCHAR(30) NOT NULL CHECK (operation_type IN ('equipment_purchase', 'monthly_payment', 'installation_work', 'refund')),
    amount_due NUMERIC(12, 2) NOT NULL CHECK (amount_due >= 0),
    amount_paid NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (amount_paid >= 0),
    operation_date DATE NOT NULL DEFAULT CURRENT_DATE,
    operation_time TIME NOT NULL DEFAULT LOCALTIME,
    comment TEXT,
    CHECK (amount_paid <= amount_due)
);

CREATE TABLE IF NOT EXISTS connection_requests (
    connection_request_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id BIGINT NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    requested_service_id BIGINT REFERENCES services(service_id) ON UPDATE CASCADE,
    connection_address VARCHAR(255) NOT NULL,
    requested_bandwidth_mbps INTEGER CHECK (requested_bandwidth_mbps IS NULL OR requested_bandwidth_mbps > 0),
    status VARCHAR(30) NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'capacity_check', 'approved', 'rejected', 'in_progress', 'completed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    processed_by_employee_id BIGINT REFERENCES employees(employee_id) ON UPDATE CASCADE,
    decision_comment TEXT
);

CREATE TABLE IF NOT EXISTS technical_tickets (
    technical_ticket_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    connection_request_id BIGINT REFERENCES connection_requests(connection_request_id) ON DELETE SET NULL,
    agreement_id BIGINT REFERENCES agreements(agreement_id) ON DELETE SET NULL,
    assigned_employee_id BIGINT REFERENCES employees(employee_id) ON UPDATE CASCADE,
    equipment_id BIGINT REFERENCES equipment(equipment_id) ON UPDATE CASCADE,
    status VARCHAR(30) NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'assigned', 'in_progress', 'resolved', 'closed')),
    priority VARCHAR(20) NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    resolved_at TIMESTAMPTZ,
    CHECK (resolved_at IS NULL OR resolved_at >= created_at)
);

CREATE TABLE IF NOT EXISTS network_capacity_updates (
    network_capacity_update_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id BIGINT NOT NULL REFERENCES employees(employee_id) ON UPDATE CASCADE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    available_bandwidth_mbps INTEGER NOT NULL CHECK (available_bandwidth_mbps >= 0),
    network_equipment_count INTEGER NOT NULL CHECK (network_equipment_count >= 0),
    peripheral_equipment_count INTEGER NOT NULL CHECK (peripheral_equipment_count >= 0),
    comment TEXT
);

COMMENT ON SCHEMA provider IS 'Portfolio case study: database model for an internet provider management system.';
COMMENT ON TABLE agreements IS 'Customer contracts for internet provider services and equipment.';
COMMENT ON TABLE connection_requests IS 'Requests for checking and processing connection availability.';
COMMENT ON TABLE network_capacity_updates IS 'Technical manager updates of available network capacity and equipment resources.';
