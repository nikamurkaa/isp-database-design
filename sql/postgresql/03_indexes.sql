-- Search and relationship indexes.

SET search_path TO provider, public;

CREATE INDEX IF NOT EXISTS idx_employees_position_id ON employees(position_id);
CREATE INDEX IF NOT EXISTS idx_clients_client_type ON clients(client_type);
CREATE INDEX IF NOT EXISTS idx_clients_phone ON clients(phone);
CREATE INDEX IF NOT EXISTS idx_individual_clients_passport ON individual_clients(passport_series, passport_number);
CREATE INDEX IF NOT EXISTS idx_legal_entities_okpo ON legal_entities(okpo);

CREATE INDEX IF NOT EXISTS idx_models_brand_id ON models(brand_id);
CREATE INDEX IF NOT EXISTS idx_equipment_type_id ON equipment(equipment_type_id);
CREATE INDEX IF NOT EXISTS idx_equipment_model_id ON equipment(model_id);
CREATE INDEX IF NOT EXISTS idx_equipment_article ON equipment(article);
CREATE INDEX IF NOT EXISTS idx_equipment_spec_equipment_id ON equipment_specifications(equipment_id);
CREATE INDEX IF NOT EXISTS idx_equipment_spec_specification_id ON equipment_specifications(specification_id);

CREATE INDEX IF NOT EXISTS idx_services_article ON services(article);
CREATE INDEX IF NOT EXISTS idx_agreements_client_id ON agreements(client_id);
CREATE INDEX IF NOT EXISTS idx_agreements_employee_id ON agreements(employee_id);
CREATE INDEX IF NOT EXISTS idx_agreements_status ON agreements(status);
CREATE INDEX IF NOT EXISTS idx_agreement_equipment_agreement_id ON agreement_equipment(agreement_id);
CREATE INDEX IF NOT EXISTS idx_agreement_services_agreement_id ON agreement_services(agreement_id);

CREATE INDEX IF NOT EXISTS idx_payment_operations_agreement_id ON payment_operations(agreement_id);
CREATE INDEX IF NOT EXISTS idx_payment_operations_operation_date ON payment_operations(operation_date);
CREATE INDEX IF NOT EXISTS idx_connection_requests_client_id ON connection_requests(client_id);
CREATE INDEX IF NOT EXISTS idx_connection_requests_status ON connection_requests(status);
CREATE INDEX IF NOT EXISTS idx_technical_tickets_status_priority ON technical_tickets(status, priority);
CREATE INDEX IF NOT EXISTS idx_network_capacity_updates_updated_at ON network_capacity_updates(updated_at DESC);
