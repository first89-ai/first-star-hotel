-- FIRST STAR HOTEL & RESORT: initial catalog (no prices are seeded).
INSERT OR IGNORE INTO branch_settings(branch_id,country_code,currency_code,timezone,locale)
SELECT id,'TH','THB','Asia/Bangkok','th-TH' FROM branches;

INSERT OR IGNORE INTO rate_plans(id,code,name_th,name_en,refundable,active) VALUES
 ('rate-flex','FLEX','ยืดหยุ่น','Flexible',1,1),
 ('rate-nonref','NONREF','ไม่สามารถคืนเงิน','Non-refundable',0,1);

INSERT OR IGNORE INTO room_types(id,code,name_th,name_en,max_adults,max_children,sort_order) VALUES
 ('rt-standard','STANDARD','สแตนดาร์ด','Standard Room',2,1,1),
 ('rt-twin','TWIN','เตียงคู่','Twin Room',2,1,2),
 ('rt-superior','SUPERIOR','ซูพีเรีย','Superior Room',2,1,3),
 ('rt-deluxe','DELUXE','ดีลักซ์','Deluxe Room',2,1,4),
 ('rt-grand-deluxe','GRAND-DELUXE','แกรนด์ดีลักซ์','Grand Deluxe',2,1,5),
 ('rt-family','FAMILY','แฟมิลี่','Family Room',4,2,6),
 ('rt-suite','SUITE','สวีท','Suite',2,1,7),
 ('rt-kingdom-suite','KINGDOM-SUITE','คิงดอมสวีท','Kingdom Suite',4,2,8);
