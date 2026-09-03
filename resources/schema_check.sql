-- schema_check.sql
-- Standalone check that the DDL in SettingsRepository::ensureSchema() parses and
-- that seed.sql inserts cleanly against it. Run from the repo root:
--
--     sqlite3 :memory: ".read resources/schema_check.sql"
--
-- Exit code 0 and no output = pass. Keep the CREATE statements below identical
-- to the ones in src/settings/SettingsRepository.cpp.

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS setting_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    key TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    icon TEXT DEFAULT '',
    sort_order INTEGER DEFAULT 0,
    parent_id INTEGER DEFAULT NULL,
    FOREIGN KEY (parent_id) REFERENCES setting_categories(id)
);

CREATE TABLE IF NOT EXISTS settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    key TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'input',
    data_type TEXT NOT NULL DEFAULT 'string',
    default_value TEXT,
    screen_type TEXT NOT NULL DEFAULT 'editor',
    custom_screen TEXT,
    min_value REAL,
    max_value REAL,
    step_value REAL DEFAULT 1,
    unit TEXT DEFAULT '',
    options TEXT DEFAULT '',
    max_length INTEGER DEFAULT 256,
    description TEXT DEFAULT '',
    is_readonly INTEGER DEFAULT 0,
    is_visible INTEGER DEFAULT 1,
    sort_order INTEGER DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES setting_categories(id)
);

CREATE TABLE IF NOT EXISTS setting_values (
    setting_key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    FOREIGN KEY (setting_key) REFERENCES settings(key)
);

.read resources/seed.sql

-- Nesting assertions: each must return exactly one row, or the SELECT prints
-- nothing and the mismatch is visible in the output.
SELECT 'FAIL: category parent_id points at a missing category'
  FROM setting_categories c
  WHERE c.parent_id IS NOT NULL
    AND c.parent_id NOT IN (SELECT id FROM setting_categories);

SELECT 'FAIL: subcategory row points at a missing category'
  FROM settings s
  WHERE s.screen_type = 'subcategory'
    AND s.custom_screen NOT IN (SELECT key FROM setting_categories);

SELECT 'FAIL: root list should hold exactly the 4 top-level categories'
  WHERE (SELECT COUNT(*) FROM setting_categories WHERE parent_id IS NULL) <> 4;
