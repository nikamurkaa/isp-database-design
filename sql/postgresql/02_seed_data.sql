-- Sanitized demo data for the internet provider database.
-- The dataset is synthetic and safe for public repositories.

SET search_path TO provider, public;

INSERT INTO positions (name, description) VALUES
    ('Administrator', 'Manages users, permissions, reference data and system settings.'),
    ('Customer Manager', 'Registers clients, processes connection requests and creates agreements.'),
    ('Chief Technical Manager', 'Maintains available network capacity and equipment resources.'),
    ('Technical Support Specialist', 'Processes technical tickets and field work.')
ON CONFLICT (name) DO NOTHING;

INSERT INTO employees (position_id, last_name, first_name, middle_name, email, login, password_hash)
SELECT p.position_id, e.last_name, e.first_name, e.middle_name, e.email, e.login, e.password_hash
FROM (VALUES
    ('Administrator', 'Admin', 'System', NULL, 'admin@example.com', 'admin', 'demo_hash_admin'),
    ('Customer Manager', 'Manager', 'Alice', NULL, 'alice.manager@example.com', 'alice_manager', 'demo_hash_manager'),
    ('Chief Technical Manager', 'Techlead', 'Victor', NULL, 'victor.techlead@example.com', 'victor_tech', 'demo_hash_techlead'),
    ('Technical Support Specialist', 'Support', 'Ivan', NULL, 'ivan.support@example.com', 'ivan_support', 'demo_hash_support')
) AS e(position_name, last_name, first_name, middle_name, email, login, password_hash)
JOIN positions p ON p.name = e.position_name
ON CONFLICT (email) DO NOTHING;

INSERT INTO equipment_types (name, description) VALUES
    ('Telecommunication equipment', 'Cables, network links and base telecommunication equipment.'),
    ('Network equipment', 'Routers, cameras, TV boxes and other connected devices.')
ON CONFLICT (name) DO NOTHING;

INSERT INTO brands (name) VALUES
    ('LinkA'),
    ('Video System')
ON CONFLICT (name) DO NOTHING;

INSERT INTO models (brand_id, name)
SELECT b.brand_id, m.model_name
FROM (VALUES
    ('LinkA', 'FP-50'),
    ('LinkA', 'LP-500'),
    ('LinkA', 'TV Station 150'),
    ('Video System', 'Outer CM 100'),
    ('Video System', 'Inner CM 100')
) AS m(brand_name, model_name)
JOIN brands b ON b.name = m.brand_name
ON CONFLICT (brand_id, name) DO NOTHING;

INSERT INTO specifications (name, unit) VALUES
    ('Length', 'm'),
    ('Material', NULL),
    ('Category', NULL),
    ('Frame rate', 'fps'),
    ('Signal-to-noise ratio', 'dB'),
    ('Resolution', NULL),
    ('Cooling', NULL)
ON CONFLICT (name) DO NOTHING;

INSERT INTO equipment (equipment_type_id, model_id, name, bandwidth_mbps, article, price, image_url)
SELECT et.equipment_type_id, m.model_id, x.name, x.bandwidth_mbps, x.article, x.price, x.image_url
FROM (VALUES
    ('Telecommunication equipment', 'LinkA', 'FP-50', 'Twisted pair cable', 50, 'EQP-0000000001', 250.00, NULL),
    ('Telecommunication equipment', 'LinkA', 'LP-500', 'Fiber optic cable', 500, 'EQP-0000000002', 500.00, NULL),
    ('Network equipment', 'Video System', 'Outer CM 100', 'Outdoor surveillance camera', 100, 'EQP-0000000003', 650.00, NULL),
    ('Network equipment', 'Video System', 'Inner CM 100', 'Indoor surveillance camera', 100, 'EQP-0000000004', 500.00, NULL),
    ('Network equipment', 'LinkA', 'TV Station 150', 'TV box', 150, 'EQP-0000000005', 450.00, NULL)
) AS x(type_name, brand_name, model_name, name, bandwidth_mbps, article, price, image_url)
JOIN equipment_types et ON et.name = x.type_name
JOIN brands b ON b.name = x.brand_name
JOIN models m ON m.brand_id = b.brand_id AND m.name = x.model_name
ON CONFLICT (article) DO NOTHING;

INSERT INTO equipment_specifications (equipment_id, specification_id, value)
SELECT e.equipment_id, s.specification_id, x.value
FROM (VALUES
    ('EQP-0000000001', 'Length', '305'),
    ('EQP-0000000001', 'Material', 'PVC'),
    ('EQP-0000000001', 'Category', '5e'),
    ('EQP-0000000002', 'Length', '850'),
    ('EQP-0000000003', 'Frame rate', '90'),
    ('EQP-0000000003', 'Signal-to-noise ratio', '45'),
    ('EQP-0000000005', 'Resolution', '4K UHD'),
    ('EQP-0000000005', 'Cooling', 'Passive')
) AS x(article, specification_name, value)
JOIN equipment e ON e.article = x.article
JOIN specifications s ON s.name = x.specification_name
ON CONFLICT (equipment_id, specification_id) DO NOTHING;

INSERT INTO services (name, description, article, setup_price, monthly_price) VALUES
    ('Static IP address', 'Dedicated static IP address for remote access and external integrations.', 'SRV-0000000001', 300.00, 150.00),
    ('Server storage space', 'Remote server storage package with expandable capacity.', 'SRV-0000000002', 450.00, 325.00),
    ('Internet connection', 'Base internet connection service for individual or corporate clients.', 'SRV-0000000003', 1000.00, 300.00),
    ('Video surveillance', 'Outdoor or indoor camera connection and maintenance service.', 'SRV-0000000004', 1200.00, 450.00),
    ('TV service', 'Digital television connection with provider equipment.', 'SRV-0000000005', 500.00, 200.00)
ON CONFLICT (article) DO NOTHING;

INSERT INTO clients (client_type, last_name, first_name, middle_name, email, phone, login, password_hash) VALUES
    ('individual', 'Demo', 'Alex', NULL, 'alex.demo@example.com', '+70000000001', 'alex_demo', 'demo_hash_client_1'),
    ('individual', 'Demo', 'Maria', NULL, 'maria.demo@example.com', '+70000000002', 'maria_demo', 'demo_hash_client_2'),
    ('legal_entity', NULL, NULL, NULL, 'office@example.org', '+70000000003', 'office_demo', 'demo_hash_company_1')
ON CONFLICT (login) DO NOTHING;

INSERT INTO individual_clients (client_id, passport_series, passport_number, birth_date, registration_address, masked_card_number)
SELECT c.client_id, x.passport_series, x.passport_number, x.birth_date::date, x.registration_address, x.masked_card_number
FROM (VALUES
    ('alex_demo', '0001', '000001', '1999-01-15', 'Demo city, Demo street, 1', '**** **** **** 0001'),
    ('maria_demo', '0002', '000002', '1998-06-20', 'Demo city, Demo avenue, 2', '**** **** **** 0002')
) AS x(login, passport_series, passport_number, birth_date, registration_address, masked_card_number)
JOIN clients c ON c.login = x.login
ON CONFLICT (client_id) DO NOTHING;

INSERT INTO legal_entities (client_id, full_name, short_name, okpo, bik, legal_address, actual_address, technical_contact_phone)
SELECT c.client_id, x.full_name, x.short_name, x.okpo, x.bik, x.legal_address, x.actual_address, x.technical_contact_phone
FROM (VALUES
    ('office_demo', 'Demo Office LLC', 'Demo Office', '12345678', '123456789', 'Demo city, Business street, 10', 'Demo city, Business street, 10', '+70000000004')
) AS x(login, full_name, short_name, okpo, bik, legal_address, actual_address, technical_contact_phone)
JOIN clients c ON c.login = x.login
ON CONFLICT (full_name) DO NOTHING;

INSERT INTO agreements (number, formation_date, work_cost, monthly_payment, equipment_purchase_total_cost, payment_deadline_day, client_id, employee_id, status)
SELECT x.number, x.formation_date::date, x.work_cost, x.monthly_payment, x.equipment_purchase_total_cost, x.payment_deadline_day, c.client_id, e.employee_id, x.status
FROM (VALUES
    ('AGR-0000000001-2026', '2026-01-10', 3000.00, 300.00, 900.00, 20, 'alex_demo', 'alice_manager', 'active'),
    ('AGR-0000000002-2026', '2026-01-15', 2000.00, 325.00, 0.00, 25, 'maria_demo', 'alice_manager', 'active'),
    ('AGR-0000000003-2026', '2026-02-01', 5000.00, 1200.00, 2000.00, 11, 'office_demo', 'alice_manager', 'draft')
) AS x(number, formation_date, work_cost, monthly_payment, equipment_purchase_total_cost, payment_deadline_day, client_login, employee_login, status)
JOIN clients c ON c.login = x.client_login
JOIN employees e ON e.login = x.employee_login
ON CONFLICT (number) DO NOTHING;

INSERT INTO agreement_equipment (agreement_id, equipment_id, quantity, unit, unit_price)
SELECT a.agreement_id, e.equipment_id, x.quantity, x.unit, x.unit_price
FROM (VALUES
    ('AGR-0000000001-2026', 'EQP-0000000001', 10, 'm', 250.00),
    ('AGR-0000000001-2026', 'EQP-0000000005', 1, 'pcs', 450.00),
    ('AGR-0000000003-2026', 'EQP-0000000002', 30, 'm', 500.00),
    ('AGR-0000000003-2026', 'EQP-0000000003', 2, 'pcs', 650.00)
) AS x(agreement_number, equipment_article, quantity, unit, unit_price)
JOIN agreements a ON a.number = x.agreement_number
JOIN equipment e ON e.article = x.equipment_article
ON CONFLICT (agreement_id, equipment_id) DO NOTHING;

INSERT INTO agreement_services (agreement_id, service_id, quantity, setup_price, monthly_price)
SELECT a.agreement_id, s.service_id, x.quantity, x.setup_price, x.monthly_price
FROM (VALUES
    ('AGR-0000000001-2026', 'SRV-0000000003', 1, 1000.00, 300.00),
    ('AGR-0000000002-2026', 'SRV-0000000002', 1, 450.00, 325.00),
    ('AGR-0000000003-2026', 'SRV-0000000003', 1, 1000.00, 300.00),
    ('AGR-0000000003-2026', 'SRV-0000000004', 1, 1200.00, 450.00)
) AS x(agreement_number, service_article, quantity, setup_price, monthly_price)
JOIN agreements a ON a.number = x.agreement_number
JOIN services s ON s.article = x.service_article
ON CONFLICT (agreement_id, service_id) DO NOTHING;

INSERT INTO payment_operations (agreement_id, operation_number, operation_type, amount_due, amount_paid, operation_date, operation_time, comment)
SELECT a.agreement_id, x.operation_number, x.operation_type, x.amount_due, x.amount_paid, x.operation_date::date, x.operation_time::time, x.comment
FROM (VALUES
    ('AGR-0000000001-2026', 'PAY-2026-000001', 'installation_work', 3000.00, 3000.00, '2026-01-10', '12:41:30', 'Installation work paid.'),
    ('AGR-0000000001-2026', 'PAY-2026-000002', 'monthly_payment', 300.00, 300.00, '2026-02-10', '10:00:00', 'Monthly payment.'),
    ('AGR-0000000002-2026', 'PAY-2026-000003', 'monthly_payment', 325.00, 200.00, '2026-02-15', '13:25:00', 'Partial payment.')
) AS x(agreement_number, operation_number, operation_type, amount_due, amount_paid, operation_date, operation_time, comment)
JOIN agreements a ON a.number = x.agreement_number
ON CONFLICT (operation_number) DO NOTHING;

INSERT INTO connection_requests (client_id, requested_service_id, connection_address, requested_bandwidth_mbps, status, processed_by_employee_id, decision_comment)
SELECT c.client_id, s.service_id, x.connection_address, x.requested_bandwidth_mbps, x.status, e.employee_id, x.decision_comment
FROM (VALUES
    ('alex_demo', 'SRV-0000000003', 'Demo city, Demo street, 1', 100, 'approved', 'victor_tech', 'Capacity is available.'),
    ('office_demo', 'SRV-0000000003', 'Demo city, Business street, 10', 500, 'capacity_check', 'victor_tech', 'Waiting for capacity confirmation.')
) AS x(client_login, service_article, connection_address, requested_bandwidth_mbps, status, employee_login, decision_comment)
JOIN clients c ON c.login = x.client_login
JOIN services s ON s.article = x.service_article
JOIN employees e ON e.login = x.employee_login;

INSERT INTO technical_tickets (connection_request_id, agreement_id, assigned_employee_id, equipment_id, status, priority, description)
SELECT cr.connection_request_id, a.agreement_id, e.employee_id, eq.equipment_id, x.status, x.priority, x.description
FROM (VALUES
    ('alex_demo', 'AGR-0000000001-2026', 'ivan_support', 'EQP-0000000005', 'assigned', 'medium', 'Install TV box and verify signal quality.'),
    ('office_demo', 'AGR-0000000003-2026', 'ivan_support', 'EQP-0000000003', 'open', 'high', 'Plan camera installation for corporate client.')
) AS x(client_login, agreement_number, employee_login, equipment_article, status, priority, description)
JOIN clients c ON c.login = x.client_login
JOIN connection_requests cr ON cr.client_id = c.client_id
LEFT JOIN agreements a ON a.number = x.agreement_number
JOIN employees e ON e.login = x.employee_login
JOIN equipment eq ON eq.article = x.equipment_article;

INSERT INTO network_capacity_updates (employee_id, available_bandwidth_mbps, network_equipment_count, peripheral_equipment_count, comment)
SELECT e.employee_id, x.available_bandwidth_mbps, x.network_equipment_count, x.peripheral_equipment_count, x.comment
FROM (VALUES
    ('victor_tech', 5000, 120, 300, 'Initial capacity snapshot for the demo environment.'),
    ('victor_tech', 4500, 118, 295, 'Capacity after active connection requests.')
) AS x(employee_login, available_bandwidth_mbps, network_equipment_count, peripheral_equipment_count, comment)
JOIN employees e ON e.login = x.employee_login;
