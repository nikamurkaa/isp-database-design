-- Demo queries that can be run after the database is initialized.

SET search_path TO provider, public;

-- 1. Service and equipment catalog.
SELECT catalog_item_type, article, name, setup_price, monthly_price
FROM v_service_catalog
ORDER BY catalog_item_type, name;

-- 2. Agreements with client and manager data.
SELECT agreement_number, client_name, manager_name, status, monthly_payment
FROM v_client_agreements
ORDER BY formation_date;

-- 3. Payment status by agreement.
SELECT agreement_number, total_due, total_paid, outstanding_amount
FROM v_payment_status
ORDER BY agreement_number;

-- 4. Equipment lookup function.
SELECT get_equipment_description('EQP-0000000001') AS equipment_description;

-- 5. Agreement total function.
SELECT
    number,
    calculate_agreement_initial_total(agreement_id) AS initial_total,
    get_agreement_outstanding_amount(agreement_id) AS outstanding_amount
FROM agreements
ORDER BY number;

-- 6. Technical support queue.
SELECT technical_ticket_id, status, priority, equipment_name, assigned_employee
FROM v_support_queue
ORDER BY created_at DESC;
