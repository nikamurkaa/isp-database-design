-- Read models for common application screens and reports.

SET search_path TO provider, public;

CREATE OR REPLACE VIEW v_service_catalog AS
SELECT
    'service' AS catalog_item_type,
    s.article,
    s.name,
    s.description,
    NULL::VARCHAR(100) AS equipment_type,
    NULL::VARCHAR(100) AS brand,
    NULL::VARCHAR(100) AS model,
    NULL::INTEGER AS bandwidth_mbps,
    s.setup_price,
    s.monthly_price,
    s.is_active
FROM services s
UNION ALL
SELECT
    'equipment' AS catalog_item_type,
    e.article,
    e.name,
    concat_ws(', ', 'Equipment item', 'unit price: ' || e.price::TEXT) AS description,
    et.name AS equipment_type,
    b.name AS brand,
    m.name AS model,
    e.bandwidth_mbps,
    e.price AS setup_price,
    0::NUMERIC(12, 2) AS monthly_price,
    e.is_active
FROM equipment e
JOIN equipment_types et ON et.equipment_type_id = e.equipment_type_id
JOIN models m ON m.model_id = e.model_id
JOIN brands b ON b.brand_id = m.brand_id;

CREATE OR REPLACE VIEW v_client_agreements AS
SELECT
    a.agreement_id,
    a.number AS agreement_number,
    a.status,
    a.formation_date,
    a.payment_deadline_day,
    c.client_id,
    c.client_type,
    COALESCE(le.full_name, concat_ws(' ', c.last_name, c.first_name, c.middle_name)) AS client_name,
    c.phone AS client_phone,
    concat_ws(' ', e.last_name, e.first_name) AS manager_name,
    a.work_cost,
    a.equipment_purchase_total_cost,
    a.monthly_payment
FROM agreements a
JOIN clients c ON c.client_id = a.client_id
LEFT JOIN legal_entities le ON le.client_id = c.client_id
JOIN employees e ON e.employee_id = a.employee_id;

CREATE OR REPLACE VIEW v_payment_status AS
SELECT
    a.agreement_id,
    a.number AS agreement_number,
    COALESCE(SUM(po.amount_due), 0)::NUMERIC(12, 2) AS total_due,
    COALESCE(SUM(po.amount_paid), 0)::NUMERIC(12, 2) AS total_paid,
    (COALESCE(SUM(po.amount_due), 0) - COALESCE(SUM(po.amount_paid), 0))::NUMERIC(12, 2) AS outstanding_amount
FROM agreements a
LEFT JOIN payment_operations po ON po.agreement_id = a.agreement_id
GROUP BY a.agreement_id, a.number;

CREATE OR REPLACE VIEW v_support_queue AS
SELECT
    tt.technical_ticket_id,
    tt.status,
    tt.priority,
    tt.description,
    tt.created_at,
    cr.connection_address,
    a.number AS agreement_number,
    eq.article AS equipment_article,
    eq.name AS equipment_name,
    concat_ws(' ', emp.last_name, emp.first_name) AS assigned_employee
FROM technical_tickets tt
LEFT JOIN connection_requests cr ON cr.connection_request_id = tt.connection_request_id
LEFT JOIN agreements a ON a.agreement_id = tt.agreement_id
LEFT JOIN equipment eq ON eq.equipment_id = tt.equipment_id
LEFT JOIN employees emp ON emp.employee_id = tt.assigned_employee_id;
