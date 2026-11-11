-- =====================================================================
-- FOUND IT - 06: Starting data (cities + categories)
-- Safe to re-run: existing rows are skipped.
-- =====================================================================

insert into public.cities (name_en, name_ar, sort_order) values
  ('Cairo',      'القاهرة',    1),
  ('Alexandria', 'الإسكندرية', 2),
  ('Giza',       'الجيزة',     3)
on conflict (name_en) do nothing;


-- icon = Material icon name (map it to Icons.xxx in Flutter)
insert into public.categories (name_en, name_ar, icon, sort_order) values
  ('Electronics', 'إلكترونيات',     'devices',                1),
  ('Wallets',     'محافظ',          'account_balance_wallet', 2),
  ('Keys',        'مفاتيح',         'key',                    3),
  ('Bags',        'شنط',            'backpack',               4),
  ('Documents',   'مستندات',        'description',            5),
  ('Pets',        'حيوانات أليفة',  'pets',                   6),
  ('Other',       'أخرى',           'category',               7)
on conflict (name_en) do nothing;
