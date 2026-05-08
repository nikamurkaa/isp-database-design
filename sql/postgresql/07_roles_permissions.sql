-- Role-based access control model.
-- Roles are NOLOGIN by default and can be granted to real application users.

SET search_path TO provider, public;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ip_admin') THEN
        CREATE ROLE ip_admin NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ip_customer_manager') THEN
        CREATE ROLE ip_customer_manager NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ip_chief_tech_manager') THEN
        CREATE ROLE ip_chief_tech_manager NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ip_support_specialist') THEN
        CREATE ROLE ip_support_specialist NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ip_client') THEN
        CREATE ROLE ip_client NOLOGIN;
    END IF;
END;
$$;

GRANT USAGE ON SCHEMA provider TO ip_admin, ip_customer_manager, ip_chief_tech_manager, ip_support_specialist, ip_client;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA provider TO ip_admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA provider TO ip_admin;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA provider TO ip_admin;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA provider TO ip_admin;

GRANT SELECT ON v_service_catalog, v_client_agreements, v_payment_status TO ip_customer_manager;
GRANT SELECT, INSERT, UPDATE ON clients, individual_clients, legal_entities, agreements, agreement_equipment, agreement_services, connection_requests, payment_operations TO ip_customer_manager;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA provider TO ip_customer_manager;
GRANT EXECUTE ON PROCEDURE create_connection_request(BIGINT, BIGINT, VARCHAR, INTEGER, BIGINT) TO ip_customer_manager;
GRANT EXECUTE ON PROCEDURE register_payment(BIGINT, VARCHAR, NUMERIC, NUMERIC, TEXT) TO ip_customer_manager;

GRANT SELECT, INSERT, UPDATE ON equipment_types, brands, models, specifications, equipment, equipment_specifications, services, network_capacity_updates TO ip_chief_tech_manager;
GRANT SELECT ON v_service_catalog, v_support_queue TO ip_chief_tech_manager;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA provider TO ip_chief_tech_manager;
GRANT EXECUTE ON FUNCTION is_capacity_available(INTEGER) TO ip_chief_tech_manager;
GRANT EXECUTE ON FUNCTION get_equipment_description(VARCHAR) TO ip_chief_tech_manager;

GRANT SELECT ON v_support_queue, v_service_catalog TO ip_support_specialist;
GRANT SELECT, UPDATE ON technical_tickets, connection_requests TO ip_support_specialist;
GRANT EXECUTE ON PROCEDURE assign_technical_ticket(BIGINT, BIGINT, VARCHAR) TO ip_support_specialist;

-- Clients may read only the public catalog directly at DB level.
-- Client-specific agreement/payment data must be filtered by the application layer
-- or by PostgreSQL Row-Level Security in a production implementation.
GRANT SELECT ON v_service_catalog TO ip_client;
