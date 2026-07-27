-- seed.sql
-- Run once to bootstrap a new product's settings database.
-- sqlite3 settings.db < seed.sql

PRAGMA foreign_keys = ON;

-- ── Categories ────────────────────────────────────────────────────────────────
INSERT INTO setting_categories (key, label, icon, sort_order) VALUES
  ('general',  'General Settings', 'settings',    0),
  ('display',  'Display',          'display',     1),
  ('audio',    'Audio',            'volume_up',   2),
  ('network',  'Network',          'wifi',        3);

-- ── General ───────────────────────────────────────────────────────────────────
INSERT INTO settings
  (category_id, key, label, type, data_type, default_value,
   options, sort_order, description)
VALUES
  (1, 'language',    'Language',    'dropdown', 'string', 'English',
   '["English","Hindi","Kannada","Tamil"]', 0, 'App display language'),

  (1, 'timezone',    'Time Zone',   'input',    'string', 'Asia/Kolkata',
   '', 1, 'IANA timezone identifier'),

  (1, 'auto_update', 'Auto Update', 'toggle',   'bool',   '1',
   '', 2, 'Automatically install firmware updates');

-- ── Display ───────────────────────────────────────────────────────────────────
INSERT INTO settings
  (category_id, key, label, type, data_type, default_value,
   min_value, max_value, step_value, unit, sort_order)
VALUES
  (2, 'brightness',       'Brightness',        'range', 'int', '70',
   0, 100, 5,   '%',  0),

  (2, 'contrast',         'Contrast',          'range', 'int', '50',
   0, 100, 5,   '%',  1),

  (2, 'color_temperature','Color Temperature', 'range', 'int', '4000',
   2700, 6500, 100, 'K', 2);

INSERT INTO settings
  (category_id, key, label, type, data_type, default_value, sort_order)
VALUES
  (2, 'night_mode', 'Night Mode', 'toggle', 'bool', '0', 3);

-- ── Audio ─────────────────────────────────────────────────────────────────────
INSERT INTO settings
  (category_id, key, label, type, data_type, default_value,
   min_value, max_value, step_value, unit, sort_order)
VALUES
  (3, 'volume', 'Master Volume', 'range', 'int', '50',
   0, 100, 1, '%', 0);

INSERT INTO settings
  (category_id, key, label, type, data_type, default_value,
   options, sort_order)
VALUES
  (3, 'audio_output', 'Audio Output', 'dropdown', 'string', 'HDMI',
   '["HDMI","Optical","Bluetooth","Analog"]', 1),

  (3, 'audio_mode', 'Audio Mode', 'dropdown', 'string', 'Stereo',
   '["Stereo","Surround","Mono"]', 2);

-- ── Network ───────────────────────────────────────────────────────────────────
INSERT INTO settings
  (category_id, key, label, type, data_type, default_value,
   sort_order, description)
VALUES
  (4, 'wifi_enabled', 'Wi-Fi',     'toggle', 'bool',   '1', 0, ''),
  (4, 'hostname',     'Hostname',  'input',  'string', 'lg-device',
   1, 'Device name on the local network');

INSERT INTO settings
  (category_id, key, label, type, data_type, default_value,
   min_value, max_value, unit, sort_order, description)
VALUES
  (4, 'dns_timeout', 'DNS Timeout', 'range', 'int', '30',
   1, 120, 'ms', 2, 'Timeout for DNS resolution requests');

-- Read-only example (firmware version shown in General)
INSERT INTO settings
  (category_id, key, label, type, data_type, default_value,
   is_readonly, sort_order)
VALUES
  (1, 'firmware_version', 'Firmware Version', 'readonly', 'string',
   '1.0.0', 1, 99);
