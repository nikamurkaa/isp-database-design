-- Sanitized demo data for MySQL variant.

USE internet_provider;

INSERT IGNORE INTO positions (name, description) VALUES
    ('Administrator', 'Manages users, permissions, reference data and system settings.'),
    ('Customer Manager', 'Registers clients, processes connection requests and creates agreements.'),
    ('Chief Technical Manager', 'Maintains available network capacity and equipment resources.'),
    ('Technical Support Specialist', 'Processes technical tickets and field work.');

INSERT IGNORE INTO employees (position_id, last_name, first_name, email, login, password_hash)
VALUES
    ((SELECT position_id FROM positions WHERE name = 'Administrator'), 'Admin', 'System', 'admin@example.com', 'admin', 'demo_hash_admin'),
    ((SELECT position_id FROM positions WHERE name = 'Customer Manager'), 'Manager', 'Alice', 'alice.manager@example.com', 'alice_manager', 'demo_hash_manager'),
    ((SELECT position_id FROM positions WHERE name = 'Chief Technical Manager'), 'Techlead', 'Victor', 'victor.techlead@example.com', 'victor_tech', 'demo_hash_techlead'),
    ((SELECT position_id FROM positions WHERE name = 'Technical Support Specialist'), 'Support', 'Ivan', 'ivan.support@example.com', 'ivan_support', 'demo_hash_support');

INSERT IGNORE INTO equipment_types (name, description) VALUES
    ('Telecommunication equipment', 'Cables, network links and base telecommunication equipment.'),
    ('Network equipment', 'Routers, cameras, TV boxes and other connected devices.');

INSERT IGNORE INTO brands (name) VALUES ('LinkA'), ('Video System');

INSERT IGNORE INTO models (brand_id, name) VALUES
    ((SELECT brand_id FROM brands WHERE name = 'LinkA'), 'FP-50'),
    ((SELECT brand_id FROM brands WHERE name = 'LinkA'), 'LP-500'),
    ((SELECT brand_id FROM brands WHERE name = 'LinkA'), 'TV Station 150'),
    ((SELECT brand_id FROM brands WHERE name = 'Video System'), 'Outer CM 100'),
    ((SELECT brand_id FROM brands WHERE name = 'Video System'), 'Inner CM 100');

INSERT IGNORE INTO specifications (name, unit) VALUES
    ('Length', 'm'), ('Material', NULL), ('Category', NULL),
    ('Frame rate', 'fps'), ('Signal-to-noise ratio', 'dB'),
    ('Resolution', NULL), ('Cooling', NULL);

INSERT IGNORE INTO equipment (equipment_type_id, model_id, name, bandwidth_mbps, article, price) VALUES
    ((SELECT equipment_type_id FROM equipment_types WHERE name = 'Telecommunication equipment'), (SELECT model_id FROM models WHERE name = 'FP-50'), 'Twisted pair cable', 50, 'EQP-0000000001', 250.00),
    ((SELECT equipment_type_id FROM equipment_types WHERE name = 'Telecommunication equipment'), (SELECT model_id FROM models WHERE name = 'LP-500'), 'Fiber optic cable', 500, 'EQP-0000000002', 500.00),
    ((SELECT equipment_type_id FROM equipment_types WHERE name = 'Network equipment'), (SELECT model_id FROM models WHERE name = 'Outer CM 100'), 'Outdoor surveillance camera', 100, 'EQP-0000000003', 650.00),
    ((SELECT equipment_type_id FROM equipment_types WHERE name = 'Network equipment'), (SELECT model_id FROM models WHERE name = 'Inner CM 100'), 'Indoor surveillance camera', 100, 'EQP-0000000004', 500.00),
    ((SELECT equipment_type_id FROM equipment_types WHERE name = 'Network equipment'), (SELECT model_id FROM models WHERE name = 'TV Station 150'), 'TV box', 150, 'EQP-0000000005', 450.00);

INSERT IGNORE INTO services (name, description, article, setup_price, monthly_price) VALUES
    ('Static IP address', 'Dedicated static IP address for remote access and external integrations.', 'SRV-0000000001', 300.00, 150.00),
    ('Server storage space', 'Remote server storage package with expandable capacity.', 'SRV-0000000002', 450.00, 325.00),
    ('Internet connection', 'Base internet connection service for individual or corporate clients.', 'SRV-0000000003', 1000.00, 300.00),
    ('Video surveillance', 'Outdoor or indoor camera connection and maintenance service.', 'SRV-0000000004', 1200.00, 450.00),
    ('TV service', 'Digital television connection with provider equipment.', 'SRV-0000000005', 500.00, 200.00);

INSERT IGNORE INTO clients (client_type, last_name, first_name, email, phone, login, password_hash) VALUES
    ('individual', 'Demo', 'Alex', 'alex.demo@example.com', '+70000000001', 'alex_demo', 'demo_hash_client_1'),
    ('individual', 'Demo', 'Maria', 'maria.demo@example.com', '+70000000002', 'maria_demo', 'demo_hash_client_2'),
    ('legal_entity', NULL, NULL, 'office@example.org', '+70000000003', 'office_demo', 'demo_hash_company_1');

INSERT IGNORE INTO individual_clients (client_id, passport_series, passport_number, birth_date, registration_address, masked_card_number) VALUES
    ((SELECT client_id FROM clients WHERE login = 'alex_demo'), '0001', '000001', '1999-01-15', 'Demo city, Demo street, 1', '**** **** **** 0001'),
    ((SELECT client_id FROM clients WHERE login = 'maria_demo'), '0002', '000002', '1998-06-20', 'Demo city, Demo avenue, 2', '**** **** **** 0002');

INSERT IGNORE INTO legal_entities (client_id, full_name, short_name, okpo, bik, legal_address, actual_address, technical_contact_phone) VALUES
    ((SELECT client_id FROM clients WHERE login = 'office_demo'), 'Demo Office LLC', 'Demo Office', '12345678', '123456789', 'Demo city, Business street, 10', 'Demo city, Business street, 10', '+70000000004');
