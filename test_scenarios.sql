-- ============================================================================
-- OTOMOTİV YAN SANAYİ: Test Senaryoları (Stok Çıkışı, Trigger Tetiklenmesi ve Rollback)
-- ============================================================================

-- TEST 1: Başarılı Hammadde Çıkışı ve Otomatik Tedarik Siparişi Trigger Testi
-- Önce hedef malzemenin mevcut stoğunu ve kritik eşiğini kontrol edelim
SELECT material_id, material_name, stock_kg, reorder_threshold_kg 
FROM raw_materials 
WHERE material_id = 'MAT-000001';

-- Üretim hattına, mevcut stok miktarını aşmayacak ama stok değerini kritik eşiğin altına düşürecek 
-- veya normal düşüşü sağlayacak şekilde hammadde çıkışı yapalım (Örn: 200 kg)
CALL sp_issue_material_to_line('MAT-000001', 200.00, 'LINE-1');

-- Kontrol 1: Stok eşik altına düştüyse trg_auto_supplier_order tetiklenip 
-- supplier_purchase_orders tablosuna otomatik satın alma siparişi attı mı?
SELECT * FROM supplier_purchase_orders WHERE material_id = 'MAT-000001';

-- Kontrol 2: Tüketim logu (requisition log) başarıyla kaydedildi mi?
SELECT * FROM material_requisition_log WHERE material_id = 'MAT-000001' ORDER BY requested_at DESC LIMIT 1;


-- TEST 2: Yetersiz Stok Hata & Otomatik Rollback Testi
-- Mevcut stoktan çok daha yüksek bir miktar isteyerek EXCEPTION ve ROLLBACK durumunu test ediyoruz
DO $$
BEGIN
    CALL sp_issue_material_to_line('MAT-000002', 999999.00, 'LINE-2');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'BEKLENEN HATA YAKALANDI VE ROLLBACK YAPILDI: %', SQLERRM;
END $$;

-- Kontrol: Hata veren işlem için log tablosuna ekleme YAPILMADIĞINI doğrula
SELECT * FROM material_requisition_log WHERE production_line = 'LINE-2' ORDER BY requested_at DESC LIMIT 3;