-- Stored procedures for common write workflows.

SET search_path TO provider, public;

CREATE OR REPLACE PROCEDURE create_connection_request(
    p_client_id BIGINT,
    p_requested_service_id BIGINT,
    p_connection_address VARCHAR,
    p_requested_bandwidth_mbps INTEGER,
    p_processed_by_employee_id BIGINT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO connection_requests (
        client_id,
        requested_service_id,
        connection_address,
        requested_bandwidth_mbps,
        status,
        processed_by_employee_id,
        decision_comment
    ) VALUES (
        p_client_id,
        p_requested_service_id,
        p_connection_address,
        p_requested_bandwidth_mbps,
        CASE WHEN is_capacity_available(p_requested_bandwidth_mbps) THEN 'approved' ELSE 'capacity_check' END,
        p_processed_by_employee_id,
        CASE WHEN is_capacity_available(p_requested_bandwidth_mbps) THEN 'Capacity is available.' ELSE 'Capacity check is required.' END
    );
END;
$$;

CREATE OR REPLACE PROCEDURE register_payment(
    p_agreement_id BIGINT,
    p_operation_type VARCHAR,
    p_amount_due NUMERIC,
    p_amount_paid NUMERIC,
    p_comment TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_amount_due < 0 OR p_amount_paid < 0 THEN
        RAISE EXCEPTION 'Payment amounts must be non-negative.';
    END IF;

    IF p_amount_paid > p_amount_due THEN
        RAISE EXCEPTION 'Paid amount cannot be greater than due amount.';
    END IF;

    INSERT INTO payment_operations (
        agreement_id,
        operation_number,
        operation_type,
        amount_due,
        amount_paid,
        comment
    ) VALUES (
        p_agreement_id,
        'PAY-' || to_char(clock_timestamp(), 'YYYYMMDDHH24MISSMS'),
        p_operation_type,
        p_amount_due,
        p_amount_paid,
        p_comment
    );
END;
$$;

CREATE OR REPLACE PROCEDURE assign_technical_ticket(
    p_technical_ticket_id BIGINT,
    p_employee_id BIGINT,
    p_priority VARCHAR DEFAULT 'medium'
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE technical_tickets
    SET assigned_employee_id = p_employee_id,
        priority = p_priority,
        status = 'assigned'
    WHERE technical_ticket_id = p_technical_ticket_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Technical ticket % was not found.', p_technical_ticket_id;
    END IF;
END;
$$;
