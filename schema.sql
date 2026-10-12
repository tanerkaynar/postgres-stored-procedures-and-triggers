-- ============================================================================
-- OTOMOTİV YAN SANAYİ: Hammadde ve Üretim Hattı Talep Şeması
-- ============================================================================

-- 1. Temizlik
DROP TABLE IF EXISTS supplier_purchase_orders CASCADE;
DROP TABLE IF EXISTS material_requisition_log CASCADE;
DROP TABLE IF EXISTS raw_materials CASCADE;

-- 2. Hammadde Envanter Tablosu
CREATE TABLE raw_materials (
    material_id VARCHAR(32) PRIMARY KEY,
    material_name VARCHAR(128) NOT NULL,
    stock_kg NUMERIC(10, 2) NOT NULL CHECK (stock_kg >= 0),
    reorder_threshold_kg NUMERIC(10, 2) NOT NULL,
    supplier_code VARCHAR(32) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Üretim Hattı Malzeme Talep (Requisition) Log Tablosu
CREATE TABLE material_requisition_log (
    req_id BIGSERIAL PRIMARY KEY,
    material_id VARCHAR(32) REFERENCES raw_materials(material_id) ON DELETE CASCADE,
    used_kg NUMERIC(10, 2) NOT NULL CHECK (used_kg > 0),
    production_line VARCHAR(32) NOT NULL,
    requested_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Otomatik Satın Alma Siparişleri Tablosu (Trigger ile tetiklenecek)
CREATE TABLE supplier_purchase_orders (
    po_id BIGSERIAL PRIMARY KEY,
    material_id VARCHAR(32) REFERENCES raw_materials(material_id) ON DELETE CASCADE,
    suggested_order_kg NUMERIC(10, 2) NOT NULL,
    order_status VARCHAR(20) DEFAULT 'PENDING', -- 'PENDING', 'APPROVED', 'CANCELLED'
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);