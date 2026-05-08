-- Reusable business functions.

SET search_path TO provider, public;

CREATE OR REPLACE FUNCTION get_equipment_description(p_article VARCHAR)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_description TEXT;
BEGIN
    SELECT concat_ws(
        ', ',
        e.name,
        'type: ' || et.name,
        'brand: ' || b.name,
        'model: ' || m.name,
        'bandwidth: ' || COALESCE(e.bandwidth_mbps::TEXT || ' Mbps', 'not specified'),
        'price: ' || e.price::TEXT
    )
    INTO v_description
    FROM equipment e
    JOIN equipment_types et ON et.equipment_type_id = e.equipment_type_id
    JOIN models m ON m.model_id = e.model_id
    JOIN brands b ON b.brand_id = m.brand_id
    WHERE e.article = p_article;

    RETURN COALESCE(v_description, 'Equipment item was not found.');
END;
$$;

CREATE OR REPLACE FUNCTION calculate_agreement_initial_total(p_agreement_id BIGINT)
RETURNS NUMERIC(12, 2)
LANGUAGE sql
STABLE
AS $$
    SELECT (
        a.work_cost
        + COALESCE(SUM(ae.quantity * ae.unit_price), 0)
        + COALESCE((
            SELECT SUM(ags.quantity * ags.setup_price)
            FROM agreement_services ags
            WHERE ags.agreement_id = a.agreement_id
        ), 0)
    )::NUMERIC(12, 2)
    FROM agreements a
    LEFT JOIN agreement_equipment ae ON ae.agreement_id = a.agreement_id
    WHERE a.agreement_id = p_agreement_id
    GROUP BY a.agreement_id, a.work_cost;
$$;

CREATE OR REPLACE FUNCTION get_agreement_outstanding_amount(p_agreement_id BIGINT)
RETURNS NUMERIC(12, 2)
LANGUAGE sql
STABLE
AS $$
    SELECT (COALESCE(SUM(amount_due), 0) - COALESCE(SUM(amount_paid), 0))::NUMERIC(12, 2)
    FROM payment_operations
    WHERE agreement_id = p_agreement_id;
$$;

CREATE OR REPLACE FUNCTION is_capacity_available(p_requested_bandwidth_mbps INTEGER)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
AS $$
    SELECT COALESCE((
        SELECT available_bandwidth_mbps >= p_requested_bandwidth_mbps
        FROM network_capacity_updates
        ORDER BY updated_at DESC
        LIMIT 1
    ), FALSE);
$$;
