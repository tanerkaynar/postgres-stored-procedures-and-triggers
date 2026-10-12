-- ============================================================================
-- OTOMOTİV YAN SANAYİ: 300.000+ Büyük Hacimli Sahte Veri 
-- ============================================================================

-- 1. Hammadde Tablosuna Toplu Veri Ekleme (5.000 Farklı Hammadde SKU)
INSERT INTO raw_materials (material_id, material_name, stock_kg, reorder_threshold_kg, supplier_code)
SELECT 
    'MAT-' || LPAD(i::TEXT, 6, '0'),
    CASE (i % 5)
        WHEN 0 THEN 'Çelik Rulo Kalite-' || i
        WHEN 1 THEN 'Alüminyum Külçe Tip-' || i
        WHEN 2 THEN 'Endüstriyel Boya Varili-' || i
        WHEN 3 THEN 'Galvanizli Sac-' || i
        ELSE 'Pres Bağlantı Elemanı-' || i
    END,
    (RANDOM() * 5000 + 50)::NUMERIC(10,2),
    (RANDOM() * 200 + 20)::NUMERIC(10,2),
    'SUPP-' || LPAD((i % 50 + 1)::TEXT, 3, '0')
FROM generate_series(1, 5000) AS i
ON CONFLICT (material_id) DO NOTHING;

-- 2. Üretim Hattı Tüketim Loglarına 300.000 Adet Toplu Veri Ekleme
INSERT INTO material_requisition_log (material_id, used_kg, production_line, requested_at)
SELECT 
    'MAT-' || LPAD((1 + (i % 5000))::TEXT, 6, '0'),
    (RANDOM() * 150 + 5)::NUMERIC(10,2),
    'LINE-' || (i % 12 + 1),
    CURRENT_TIMESTAMP - (RANDOM() * INTERVAL '90 days')
FROM generate_series(1, 300000) AS i;