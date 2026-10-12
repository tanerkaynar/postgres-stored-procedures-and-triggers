-- ============================================================================
-- OTOMOTİV YAN SANAYİ: Otomatik Satın Alma ve Stok Trigger Mekanizmaları
-- ============================================================================

-- 1. Trigger Fonksiyonu: Kritik Seviye Altına Düşen Hammadde İçin Otomatik Satın Alma Siparişi Açma
CREATE OR REPLACE FUNCTION fn_auto_supplier_order()
RETURNS TRIGGER AS $$
BEGIN
    -- Stok reorder eşiğinin altına indiyse ve daha önce bu eşiğin üzerindeyse
    IF (NEW.stock_kg <= NEW.reorder_threshold_kg) AND (OLD.stock_kg > NEW.reorder_threshold_kg) THEN
        INSERT INTO supplier_purchase_orders (
            material_id,
            suggested_order_kg,
            order_status,
            created_at
        ) VALUES (
            NEW.material_id,
            (NEW.reorder_threshold_kg * 3), -- Örnek: Eşikteki miktarın 3 katı kadar sipariş önerisi
            'PENDING',
            CURRENT_TIMESTAMP
        );
    END IF;

    -- Güncelleme zaman damgasını yenile
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Trigger Tanımı: raw_materials tablosunda UPDATE sonrasında tetikleme
DROP TRIGGER IF EXISTS trg_auto_supplier_order ON raw_materials;
CREATE TRIGGER trg_auto_supplier_order
    AFTER UPDATE ON raw_materials
    FOR EACH ROW
    EXECUTE FUNCTION fn_auto_supplier_order();