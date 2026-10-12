-- ============================================================================
-- OTOMOTİV YAN SANAYİ: Üretim Hattı Malzeme Çıkış Prosedürü (Atomik & Kilitli)
-- ============================================================================

-- Üretim hattına hammadde çıkışı yapar. Stok miktarını FOR UPDATE ile kilitleyerek
-- eş zamanlı (concurrent) işlemlerde yarış koşullarını (race conditions) engeller.
-- Stok yetersizse EXCEPTION fırlatarak işlemi tamamen geri alır (ROLLBACK).
CREATE OR REPLACE PROCEDURE sp_issue_material_to_line(
    p_material_id VARCHAR(32),
    p_amount_kg NUMERIC(10, 2),
    p_line_code VARCHAR(32)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_stock NUMERIC(10, 2);
BEGIN
    -- Girdi kontrolü
    IF p_amount_kg <= 0 THEN
        RAISE EXCEPTION 'Geçersiz hammadde miktarı: % kg', p_amount_kg;
    END IF;

    -- 1. Satırı kilitle ve mevcut stoğu güvenli şekilde oku (Concurrency Koruması)
    SELECT stock_kg INTO v_current_stock
    FROM raw_materials
    WHERE material_id = p_material_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Hammadde bulunamadı: ID %', p_material_id;
    END IF;

    -- 2. Stok yeterlilik kontrolü
    IF v_current_stock < p_amount_kg THEN
        RAISE EXCEPTION 'YETERSİZ HAMMADDE STOK! ID: %, İstenen: % kg, Mevcut: % kg', 
            p_material_id, p_amount_kg, v_current_stock;
    END IF;

    -- 3. Stoğu düş (Bu işlem otomatik olarak trg_auto_supplier_order trigger'ını tetikleyebilir)
    UPDATE raw_materials
    SET stock_kg = stock_kg - p_amount_kg
    WHERE material_id = p_material_id;

    -- 4. Talep/Tüketim logunu kaydet
    INSERT INTO material_requisition_log (material_id, used_kg, production_line)
    VALUES (p_material_id, p_amount_kg, p_line_code);

    RAISE NOTICE 'Hammadde çıkışı başarılı: % kg, Hat: %', p_amount_kg, p_line_code;
END;
$$;