-- Seed script for packagesapp-worker Cloudflare D1
-- Initial Networks and Realistic Pakistan Mobile Packages

-- 1. Insert Networks
INSERT OR REPLACE INTO networks (id, name, slug, slogan, logo_url, brand_color, is_active, package_count) VALUES
('jazz', 'Jazz', 'jazz', 'Pakistan Ka Dil', 'assets/images/jazz.png', '#E31837', 1, 7),
('zong', 'Zong', 'zong', 'First in 4G', 'assets/images/zong.png', '#8DC63F', 1, 7),
('telenor', 'Telenor', 'telenor', 'Skandinavian Spirit', 'assets/images/telenor.png', '#00A0E3', 1, 7),
('ufone', 'Ufone', 'ufone', 'Tum Hi Toh Ho', 'assets/images/ufone.png', '#EF7A15', 1, 7),
('ptcl', 'PTCL', 'ptcl', 'It''s All About You', 'assets/images/pta.png', '#003087', 1, 5);

-- 2. Insert Packages
-- JAZZ PACKAGES
INSERT OR REPLACE INTO packages (
    id, network_id, name, category, sub_category, price, recharge_required, validity_days, validity_hours, validity_type,
    activation_code, deactivation_code, resources_json, addons_json, extra_services_json, details, tags_json,
    is_active, is_featured, is_popular, is_special_offer
) VALUES
(
    'jazz_daily_super', 'jazz', 'Jazz Daily Super Bundle', 'hybrid', 'daily', 35.0, 40.0, 1, 24, 'daily',
    '*291#', '*291*4#',
    '{"onNetMinutes":300,"offNetMinutes":10,"allNetMinutes":310,"sms":300,"dataMb":150,"dataGb":0.15,"dataTimeWindow":"24 Hours","dataPeakMb":150,"dataOffPeakMb":0,"socialMb":0,"socialApps":[]}',
    '[]',
    '["Free Call Setup"]',
    'Enjoy 300 Jazz minutes, 10 other network minutes, 300 SMS, and 150 MBs internet for 24 hours.',
    '["daily","budget","jazz","call","internet"]',
    1, 0, 1, 0
),
(
    'jazz_daily_mega', 'jazz', 'Jazz Daily Mega Data', 'internet', 'daily', 50.0, 60.0, 1, 24, 'daily',
    '*117*2#', '*117*2*4#',
    '{"onNetMinutes":0,"offNetMinutes":0,"allNetMinutes":0,"sms":0,"dataMb":1024,"dataGb":1.0,"dataTimeWindow":"24 Hours","dataPeakMb":1024,"dataOffPeakMb":0,"socialMb":0,"socialApps":[]}',
    '[]',
    '[]',
    'Get 1000 MB high-speed 4G internet valid for 24 hours from activation time.',
    '["daily","internet","data","4g","jazz"]',
    1, 0, 0, 0
),
(
    'jazz_weekly_super_duper', 'jazz', 'Jazz Weekly Super Duper', 'hybrid', 'weekly', 415.0, 480.0, 7, 168, 'weekly',
    '*770#', '*770*4#',
    '{"onNetMinutes":3000,"offNetMinutes":100,"allNetMinutes":3100,"sms":3000,"dataMb":8192,"dataGb":8.0,"dataTimeWindow":"24 Hours","dataPeakMb":8192,"dataOffPeakMb":0,"socialMb":2048,"socialApps":["whatsapp","youtube"]}',
    '[{"name":"YouTube & WhatsApp","value":"2","unit":"GB"}]',
    '["Free WhatsApp","Free Tamasha Access"]',
    '3000 Jazz minutes, 100 off-net minutes, 3000 SMS, 8 GB internet (including 2 GB YouTube & WhatsApp) for 7 days.',
    '["weekly","hybrid","popular","jazz","best_value"]',
    1, 1, 1, 0
),
(
    'jazz_weekly_all_in_one', 'jazz', 'Jazz Weekly All-in-One', 'hybrid', 'weekly', 180.0, 210.0, 7, 168, 'weekly',
    '*453#', '*453*4#',
    '{"onNetMinutes":1000,"offNetMinutes":70,"allNetMinutes":1070,"sms":1000,"dataMb":1500,"dataGb":1.5,"dataTimeWindow":"24 Hours","dataPeakMb":1500,"dataOffPeakMb":0,"socialMb":0,"socialApps":[]}',
    '[]',
    '["WhatsApp Free"]',
    '1000 on-net minutes, 70 off-net, 1000 SMS and 1.5 GB internet for 7 days.',
    '["weekly","hybrid","jazz","budget"]',
    1, 0, 0, 0
),
(
    'jazz_weekly_mega_data', 'jazz', 'Jazz Weekly Mega Data 15GB', 'internet', 'weekly', 390.0, 450.0, 7, 168, 'weekly',
    '*117*7#', '*117*7*4#',
    '{"onNetMinutes":0,"offNetMinutes":0,"allNetMinutes":0,"sms":0,"dataMb":15360,"dataGb":15.0,"dataTimeWindow":"24 Hours (7GB 2AM-2PM)","dataPeakMb":8192,"dataOffPeakMb":7168,"socialMb":0,"socialApps":[]}',
    '[]',
    '[]',
    '15 GB internet data (8 GB 24 hours + 7 GB 2 AM to 2 PM) for full 7 days.',
    '["weekly","internet","heavy_data","jazz","4g"]',
    1, 1, 1, 1
),
(
    'jazz_monthly_supreme', 'jazz', 'Jazz Monthly Supreme Super', 'hybrid', 'monthly', 1200.0, 1350.0, 30, 720, 'monthly',
    '*430#', '*430*4#',
    '{"onNetMinutes":5000,"offNetMinutes":500,"allNetMinutes":5500,"sms":5000,"dataMb":30720,"dataGb":30.0,"dataTimeWindow":"24 Hours","dataPeakMb":30720,"dataOffPeakMb":0,"socialMb":10240,"socialApps":["whatsapp","youtube","facebook"]}',
    '[{"name":"Social Data","value":"10","unit":"GB"}]',
    '["Free WhatsApp","Free Tamasha VIP","Free BIP Messenger"]',
    'Comprehensive monthly package: 5000 Jazz minutes, 500 other network minutes, 5000 SMS, and 30 GB 4G data (10 GB for social apps).',
    '["monthly","hybrid","supreme","jazz","featured"]',
    1, 1, 1, 0
),
(
    'jazz_monthly_mahana_bachat', 'jazz', 'Jazz Mahana Bachat Offer', 'hybrid', 'monthly', 450.0, 520.0, 30, 720, 'monthly',
    '*614#', '*614*4#',
    '{"onNetMinutes":4000,"offNetMinutes":300,"allNetMinutes":4300,"sms":4000,"dataMb":6144,"dataGb":6.0,"dataTimeWindow":"24 Hours","dataPeakMb":6144,"dataOffPeakMb":0,"socialMb":4096,"socialApps":["whatsapp","imo"]}',
    '[]',
    '["Free WhatsApp","Free IMO"]',
    'Affordable monthly hybrid bundle: 4000 on-net, 300 off-net, 4000 SMS, and 6 GB internet (4 GB for WhatsApp & IMO).',
    '["monthly","bachat","budget","hybrid","jazz"]',
    1, 0, 1, 0
);

-- ZONG PACKAGES
INSERT OR REPLACE INTO packages (
    id, network_id, name, category, sub_category, price, recharge_required, validity_days, validity_hours, validity_type,
    activation_code, deactivation_code, resources_json, addons_json, extra_services_json, details, tags_json,
    is_active, is_featured, is_popular, is_special_offer
) VALUES
(
    'zong_daily_shandar', 'zong', 'Zong Shandar Daily Bundle', 'hybrid', 'daily', 28.0, 35.0, 1, 24, 'daily',
    '*999#', '*999*4#',
    '{"onNetMinutes":1000,"offNetMinutes":15,"allNetMinutes":1015,"sms":1000,"dataMb":50,"dataGb":0.05,"dataTimeWindow":"24 Hours","dataPeakMb":50,"dataOffPeakMb":0,"socialMb":0,"socialApps":[]}',
    '[]',
    '[]',
    'Unlimited Zong minutes (fair usage 1000), 15 off-net minutes, 1000 SMS, and 50 MB data for 1 day.',
    '["daily","zong","shandar","call","hybrid"]',
    1, 0, 1, 0
),
(
    'zong_daily_4g_data', 'zong', 'Zong 4G Daily Mega', 'internet', 'daily', 40.0, 50.0, 1, 24, 'daily',
    '*6001#', '*6001*4#',
    '{"onNetMinutes":0,"offNetMinutes":0,"allNetMinutes":0,"sms":0,"dataMb":1536,"dataGb":1.5,"dataTimeWindow":"24 Hours","dataPeakMb":1536,"dataOffPeakMb":0,"socialMb":0,"socialApps":[]}',
    '[]',
    '[]',
    '1.5 GB lightning fast 4G internet valid for 24 hours.',
    '["daily","internet","zong","4g"]',
    1, 0, 0, 0
),
(
    'zong_weekly_super', 'zong', 'Zong Super Weekly Plus', 'hybrid', 'weekly', 350.0, 400.0, 7, 168, 'weekly',
    '*6464#', '*6464*4#',
    '{"onNetMinutes":2000,"offNetMinutes":120,"allNetMinutes":2120,"sms":2000,"dataMb":8192,"dataGb":8.0,"dataTimeWindow":"24 Hours","dataPeakMb":8192,"dataOffPeakMb":0,"socialMb":3072,"socialApps":["whatsapp","tiktok"]}',
    '[{"name":"TikTok Data","value":"3","unit":"GB"}]',
    '["WhatsApp Free","TikTok Free 3GB"]',
    '2000 on-net minutes, 120 off-net minutes, 2000 SMS, and 8 GB internet data for 7 days.',
    '["weekly","hybrid","zong","popular","super"]',
    1, 1, 1, 0
),
(
    'zong_weekly_pro', 'zong', 'Zong Weekly Pro Max 40GB', 'hybrid', 'weekly', 550.0, 630.0, 7, 168, 'weekly',
    '*794#', '*794*4#',
    '{"onNetMinutes":5000,"offNetMinutes":250,"allNetMinutes":5250,"sms":5000,"dataMb":40960,"dataGb":40.0,"dataTimeWindow":"24 Hours","dataPeakMb":40960,"dataOffPeakMb":0,"socialMb":10240,"socialApps":["youtube","tiktok","facebook"]}',
    '[{"name":"Video Streaming","value":"10","unit":"GB"}]',
    '["Free MyZong App Rewards"]',
    'Massive 40 GB internet, 5000 Zong minutes, 250 other network minutes, and 5000 SMS for heavy users for 7 days.',
    '["weekly","pro","heavy_data","zong","popular"]',
    1, 1, 1, 1
),
(
    'zong_super_weekly_max', 'zong', 'Zong Super Weekly Max 30GB', 'internet', 'weekly', 440.0, 500.0, 7, 168, 'weekly',
    '*220#', '*220*4#',
    '{"onNetMinutes":0,"offNetMinutes":0,"allNetMinutes":0,"sms":0,"dataMb":30720,"dataGb":30.0,"dataTimeWindow":"24 Hours (10GB 4AM-4PM)","dataPeakMb":20480,"dataOffPeakMb":10240,"socialMb":0,"socialApps":[]}',
    '[]',
    '[]',
    '30 GB data (20 GB flat 24/7 + 10 GB 4 AM to 4 PM) for non-stop streaming and downloads.',
    '["weekly","internet","max","zong","4g"]',
    1, 0, 1, 0
),
(
    'zong_monthly_premium', 'zong', 'Zong Monthly Premium 30GB', 'hybrid', 'monthly', 1200.0, 1350.0, 30, 720, 'monthly',
    '*6767#', '*6767*4#',
    '{"onNetMinutes":5000,"offNetMinutes":500,"allNetMinutes":5500,"sms":5000,"dataMb":30720,"dataGb":30.0,"dataTimeWindow":"24 Hours","dataPeakMb":30720,"dataOffPeakMb":0,"socialMb":5120,"socialApps":["whatsapp","tiktok","youtube"]}',
    '[{"name":"TikTok Bonus","value":"5","unit":"GB"}]',
    '["WhatsApp Free","TikTok Free 5GB"]',
    '5000 on-net, 500 off-net minutes, 5000 SMS, and 30 GB 4G data for 30 calendar days.',
    '["monthly","hybrid","zong","premium","popular"]',
    1, 1, 1, 0
),
(
    'zong_monthly_super_star', 'zong', 'Zong Monthly Super Star', 'hybrid', 'monthly', 750.0, 850.0, 30, 720, 'monthly',
    '*7070#', '*7070*4#',
    '{"onNetMinutes":3000,"offNetMinutes":300,"allNetMinutes":3300,"sms":3000,"dataMb":12288,"dataGb":12.0,"dataTimeWindow":"24 Hours","dataPeakMb":12288,"dataOffPeakMb":0,"socialMb":4096,"socialApps":["whatsapp","facebook"]}',
    '[]',
    '["WhatsApp Free"]',
    '3000 Zong minutes, 300 off-net minutes, 3000 SMS, and 12 GB 4G internet for 30 days.',
    '["monthly","superstar","zong","value"]',
    1, 0, 0, 0
);

-- TELENOR PACKAGES
INSERT OR REPLACE INTO packages (
    id, network_id, name, category, sub_category, price, recharge_required, validity_days, validity_hours, validity_type,
    activation_code, deactivation_code, resources_json, addons_json, extra_services_json, details, tags_json,
    is_active, is_featured, is_popular, is_special_offer
) VALUES
(
    'telenor_talkshawk_daily', 'telenor', 'Telenor Talkshawk Daily', 'call', 'daily', 25.0, 30.0, 1, 24, 'daily',
    '*5#', '*5*4#',
    '{"onNetMinutes":1000,"offNetMinutes":20,"allNetMinutes":1020,"sms":50,"dataMb":50,"dataGb":0.05,"dataTimeWindow":"24 Hours","dataPeakMb":50,"dataOffPeakMb":0,"socialMb":0,"socialApps":[]}',
    '[]',
    '[]',
    '1000 Telenor-to-Telenor minutes, 20 off-net minutes, 50 SMS and 50 MB for 1 day.',
    '["call","daily","telenor","talkshawk","budget"]',
    1, 0, 1, 0
),
(
    'telenor_4g_daily_lite', 'telenor', 'Telenor 4G Daily Lite', 'internet', 'daily', 30.0, 35.0, 1, 24, 'daily',
    '*311#', '*311*4#',
    '{"onNetMinutes":0,"offNetMinutes":0,"allNetMinutes":0,"sms":0,"dataMb":1024,"dataGb":1.0,"dataTimeWindow":"24 Hours","dataPeakMb":1024,"dataOffPeakMb":0,"socialMb":0,"socialApps":[]}',
    '[]',
    '[]',
    '1000 MB 4G internet valid for 24 hours.',
    '["daily","internet","telenor","4g"]',
    1, 0, 0, 0
),
(
    'telenor_weekly_easycard', 'telenor', 'Telenor Weekly EasyCard', 'hybrid', 'weekly', 320.0, 360.0, 7, 168, 'weekly',
    '*963#', '*963*4#',
    '{"onNetMinutes":1500,"offNetMinutes":80,"allNetMinutes":1580,"sms":1500,"dataMb":4096,"dataGb":4.0,"dataTimeWindow":"24 Hours","dataPeakMb":4096,"dataOffPeakMb":0,"socialMb":1024,"socialApps":["whatsapp"]}',
    '[]',
    '["WhatsApp Free"]',
    '1500 on-net minutes, 80 off-net, 1500 SMS, and 4 GB internet (including 1 GB WhatsApp) for 7 days.',
    '["weekly","easycard","telenor","hybrid","popular"]',
    1, 1, 1, 0
),
(
    'telenor_weekly_ultra', 'telenor', 'Telenor Weekly Ultra 12GB', 'internet', 'weekly', 370.0, 420.0, 7, 168, 'weekly',
    '*336#', '*336*4#',
    '{"onNetMinutes":0,"offNetMinutes":0,"allNetMinutes":0,"sms":0,"dataMb":12288,"dataGb":12.0,"dataTimeWindow":"24 Hours (6GB 1AM-11AM)","dataPeakMb":6144,"dataOffPeakMb":6144,"socialMb":0,"socialApps":[]}',
    '[]',
    '[]',
    '12 GB internet (6 GB 24/7 + 6 GB 1 AM to 11 AM) for 7 days.',
    '["weekly","internet","ultra","telenor","4g"]',
    1, 0, 1, 0
),
(
    'telenor_monthly_easycard_1000', 'telenor', 'Telenor Monthly EasyCard 1000', 'hybrid', 'monthly', 1000.0, 1150.0, 30, 720, 'monthly',
    '*530#', '*530*4#',
    '{"onNetMinutes":5000,"offNetMinutes":450,"allNetMinutes":5450,"sms":5000,"dataMb":25600,"dataGb":25.0,"dataTimeWindow":"24 Hours","dataPeakMb":25600,"dataOffPeakMb":0,"socialMb":5120,"socialApps":["whatsapp","facebook"]}',
    '[{"name":"Social Pack","value":"5","unit":"GB"}]',
    '["WhatsApp Free","Facebook Free"]',
    '5000 on-net, 450 off-net minutes, 5000 SMS, and 25 GB data (5 GB social) for 30 full days.',
    '["monthly","easycard","telenor","mega","popular"]',
    1, 1, 1, 0
),
(
    'telenor_monthly_social_extreme', 'telenor', 'Telenor Monthly Social Extreme', 'social', 'monthly', 230.0, 270.0, 30, 720, 'monthly',
    '*345*61#', '*345*61*4#',
    '{"onNetMinutes":0,"offNetMinutes":0,"allNetMinutes":0,"sms":1000,"dataMb":10240,"dataGb":10.0,"dataTimeWindow":"24 Hours","dataPeakMb":10240,"dataOffPeakMb":0,"socialMb":10240,"socialApps":["whatsapp","facebook","youtube"]}',
    '[]',
    '["WhatsApp","Facebook","YouTube"]',
    '10 GB dedicated social pack for WhatsApp, Facebook, and YouTube, plus 1000 SMS for 30 days.',
    '["monthly","social","telenor","whatsapp","budget"]',
    1, 0, 1, 1
),
(
    'telenor_4g_monthly_starter', 'telenor', 'Telenor 4G Monthly Starter', 'internet', 'monthly', 650.0, 750.0, 30, 720, 'monthly',
    '*303#', '*303*4#',
    '{"onNetMinutes":0,"offNetMinutes":0,"allNetMinutes":0,"sms":0,"dataMb":15360,"dataGb":15.0,"dataTimeWindow":"24 Hours","dataPeakMb":15360,"dataOffPeakMb":0,"socialMb":0,"socialApps":[]}',
    '[]',
    '[]',
    '15 GB 4G flat data for 30 days without any time-window restrictions.',
    '["monthly","internet","starter","telenor","4g"]',
    1, 0, 0, 0
);

-- UFONE PACKAGES
INSERT OR REPLACE INTO packages (
    id, network_id, name, category, sub_category, price, recharge_required, validity_days, validity_hours, validity_type,
    activation_code, deactivation_code, resources_json, addons_json, extra_services_json, details, tags_json,
    is_active, is_featured, is_popular, is_special_offer
) VALUES
(
    'ufone_daily_best_call', 'ufone', 'Ufone Best Call Daily', 'call', 'daily', 26.0, 32.0, 1, 24, 'daily',
    '*888#', '*888*4#',
    '{"onNetMinutes":1000,"offNetMinutes":10,"allNetMinutes":1010,"sms":100,"dataMb":100,"dataGb":0.1,"dataTimeWindow":"24 Hours","dataPeakMb":100,"dataOffPeakMb":0,"socialMb":0,"socialApps":[]}',
    '[]',
    '[]',
    'Unlimited Ufone to Ufone & PTCL minutes, 10 off-net minutes, 100 SMS, and 100 MB data for 24 hours.',
    '["call","daily","ufone","budget"]',
    1, 0, 1, 0
),
(
    'ufone_daily_light_internet', 'ufone', 'Ufone Daily Light Internet', 'internet', 'daily', 25.0, 30.0, 1, 24, 'daily',
    '*2256#', '*2256*4#',
    '{"onNetMinutes":0,"offNetMinutes":0,"allNetMinutes":0,"sms":0,"dataMb":500,"dataGb":0.5,"dataTimeWindow":"24 Hours","dataPeakMb":500,"dataOffPeakMb":0,"socialMb":500,"socialApps":["whatsapp","facebook"]}',
    '[]',
    '["WhatsApp Included"]',
    '500 MB high-speed data plus 500 MB Social (WhatsApp/FB) for 1 day.',
    '["daily","internet","ufone","light"]',
    1, 0, 0, 0
),
(
    'ufone_weekly_super_minutes', 'ufone', 'Ufone Weekly Super Minutes', 'call', 'weekly', 220.0, 260.0, 7, 168, 'weekly',
    '*4000#', '*4000*4#',
    '{"onNetMinutes":1500,"offNetMinutes":100,"allNetMinutes":1600,"sms":0,"dataMb":0,"dataGb":0.0,"dataTimeWindow":"24 Hours","dataPeakMb":0,"dataOffPeakMb":0,"socialMb":0,"socialApps":[]}',
    '[]',
    '[]',
    '1500 Ufone & PTCL minutes and 100 other network minutes for 7 days.',
    '["weekly","call","ufone","minutes"]',
    1, 0, 0, 0
),
(
    'ufone_weekly_digital_grand', 'ufone', 'Ufone Weekly Digital Grand', 'hybrid', 'weekly', 480.0, 550.0, 7, 168, 'weekly',
    '*7777#', '*7777*4#',
    '{"onNetMinutes":7000,"offNetMinutes":450,"allNetMinutes":7450,"sms":7000,"dataMb":25600,"dataGb":25.0,"dataTimeWindow":"24 Hours","dataPeakMb":25600,"dataOffPeakMb":0,"socialMb":5120,"socialApps":["whatsapp","youtube"]}',
    '[{"name":"YouTube Bonus","value":"5","unit":"GB"}]',
    '["WhatsApp Free"]',
    '7000 on-net, 450 off-net minutes, 7000 SMS, and 25 GB internet (including 5 GB YouTube) for 7 days.',
    '["weekly","hybrid","grand","ufone","popular"]',
    1, 1, 1, 0
),
(
    'ufone_super_card_gold', 'ufone', 'Ufone Super Card Gold Monthly', 'hybrid', 'monthly', 1300.0, 1450.0, 30, 720, 'monthly',
    '*900#', '*900*4#',
    '{"onNetMinutes":7000,"offNetMinutes":600,"allNetMinutes":7600,"sms":6000,"dataMb":35840,"dataGb":35.0,"dataTimeWindow":"24 Hours","dataPeakMb":35840,"dataOffPeakMb":0,"socialMb":10240,"socialApps":["whatsapp","facebook","youtube"]}',
    '[{"name":"Social Data","value":"10","unit":"GB"}]',
    '["WhatsApp Free","Facebook Free"]',
    'Ultimate monthly bundle: 7000 on-net minutes, 600 off-net minutes, 6000 SMS, and 35 GB data for 30 days.',
    '["monthly","supercard","gold","ufone","popular"]',
    1, 1, 1, 0
),
(
    'ufone_monthly_super_card_max', 'ufone', 'Ufone Monthly Super Card Max', 'hybrid', 'monthly', 850.0, 950.0, 30, 720, 'monthly',
    '*629#', '*629*4#',
    '{"onNetMinutes":5000,"offNetMinutes":350,"allNetMinutes":5350,"sms":4500,"dataMb":18432,"dataGb":18.0,"dataTimeWindow":"24 Hours","dataPeakMb":18432,"dataOffPeakMb":0,"socialMb":4096,"socialApps":["whatsapp"]}',
    '[]',
    '["WhatsApp Free"]',
    '5000 on-net minutes, 350 off-net minutes, 4500 SMS, and 18 GB data for 30 days.',
    '["monthly","supercard","ufone","value"]',
    1, 0, 1, 0
),
(
    'ufone_monthly_sab_se_badi', 'ufone', 'Ufone Sab Se Badi Offer 50GB', 'internet', 'monthly', 1100.0, 1250.0, 30, 720, 'monthly',
    '*5555#', '*5555*4#',
    '{"onNetMinutes":0,"offNetMinutes":0,"allNetMinutes":0,"sms":0,"dataMb":51200,"dataGb":50.0,"dataTimeWindow":"24 Hours (25GB 2AM-2PM)","dataPeakMb":25600,"dataOffPeakMb":25600,"socialMb":0,"socialApps":[]}',
    '[]',
    '[]',
    '50 GB massive data (25 GB 24/7 + 25 GB 2 AM to 2 PM) valid for 30 calendar days.',
    '["monthly","internet","heavy_data","ufone","badi_offer"]',
    1, 1, 1, 1
);

-- PTCL PACKAGES
INSERT OR REPLACE INTO packages (
    id, network_id, name, category, sub_category, price, recharge_required, validity_days, validity_hours, validity_type,
    activation_code, deactivation_code, resources_json, addons_json, extra_services_json, details, tags_json,
    is_active, is_featured, is_popular, is_special_offer
) VALUES
(
    'ptcl_charji_weekly_15gb', 'ptcl', 'PTCL Charji Weekly 15GB', 'internet', 'weekly', 300.0, 350.0, 7, 168, 'weekly',
    'charji.com.pk', 'charji.com.pk',
    '{"onNetMinutes":0,"offNetMinutes":0,"allNetMinutes":0,"sms":0,"dataMb":15360,"dataGb":15.0,"dataTimeWindow":"24 Hours","dataPeakMb":15360,"dataOffPeakMb":0,"socialMb":0,"socialApps":[]}',
    '[]',
    '[]',
    '15 GB Charji 4G LTE wireless broadband internet for 7 days. Recharge via PTCL Touch app or charji portal.',
    '["weekly","internet","ptcl","charji","4g"]',
    1, 0, 1, 0
),
(
    'ptcl_charji_monthly_50gb', 'ptcl', 'PTCL Charji Monthly 50GB', 'internet', 'monthly', 850.0, 950.0, 30, 720, 'monthly',
    'charji.com.pk', 'charji.com.pk',
    '{"onNetMinutes":0,"offNetMinutes":0,"allNetMinutes":0,"sms":0,"dataMb":51200,"dataGb":50.0,"dataTimeWindow":"24 Hours","dataPeakMb":51200,"dataOffPeakMb":0,"socialMb":0,"socialApps":[]}',
    '[]',
    '[]',
    '50 GB Charji 4G LTE high-speed wireless broadband internet for 30 days.',
    '["monthly","internet","ptcl","charji","popular"]',
    1, 1, 1, 0
),
(
    'ptcl_charji_unlimited_monthly', 'ptcl', 'PTCL Charji Unlimited Monthly 150GB', 'internet', 'monthly', 1699.0, 1850.0, 30, 720, 'monthly',
    'charji.com.pk', 'charji.com.pk',
    '{"onNetMinutes":0,"offNetMinutes":0,"allNetMinutes":0,"sms":0,"dataMb":153600,"dataGb":150.0,"dataTimeWindow":"24 Hours","dataPeakMb":153600,"dataOffPeakMb":0,"socialMb":0,"socialApps":[]}',
    '[]',
    '["Fair Usage Policy 150GB"]',
    '150 GB ultra-fast Charji 4G LTE cloud internet with uninterrupted connectivity for 30 days.',
    '["monthly","internet","ptcl","charji","unlimited"]',
    1, 0, 1, 1
),
(
    'ptcl_broadband_8mbps', 'ptcl', 'PTCL Broadband 8 Mbps Monthly', 'internet', 'monthly', 1999.0, 2200.0, 30, 720, 'monthly',
    '0800-8-786', '0800-8-786',
    '{"onNetMinutes":0,"offNetMinutes":0,"allNetMinutes":0,"sms":0,"dataMb":102400,"dataGb":100.0,"dataTimeWindow":"24 Hours","dataPeakMb":102400,"dataOffPeakMb":0,"socialMb":0,"socialApps":[]}',
    '[{"name":"Smart TV","value":"1","unit":"month"}]',
    '["Free Smart TV subscription","Free landline to landline minutes"]',
    '100 GB broadband data at 8 Mbps speed with Smart TV app access for 30 days. Dial 0800-8-786 to subscribe.',
    '["monthly","internet","ptcl","broadband","home","dsl"]',
    1, 1, 1, 0
),
(
    'ptcl_flash_fiber_20mbps', 'ptcl', 'PTCL Flash Fiber 20 Mbps GPON', 'internet', 'monthly', 2699.0, 2999.0, 30, 720, 'monthly',
    '1218', '1218',
    '{"onNetMinutes":0,"offNetMinutes":0,"allNetMinutes":0,"sms":0,"dataMb":0,"dataGb":999.0,"dataTimeWindow":"24 Hours","dataPeakMb":0,"dataOffPeakMb":0,"socialMb":0,"socialApps":[]}',
    '[{"name":"Smart TV HD","value":"1","unit":"month"},{"name":"Dual Band Wi-Fi 6","value":"1","unit":"device"}]',
    '["Symmetrical 20 Mbps upload & download","Smart TV App","Free Static IP on demand"]',
    'Pure Gigabit Optical Fiber 20 Mbps symmetrical speed with unlimited downloads and low latency for gaming and streaming.',
    '["monthly","fiber","gpon","ptcl","broadband","ultrafast"]',
    1, 1, 1, 1
);
