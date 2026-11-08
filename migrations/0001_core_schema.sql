-- FIRST STAR HOTEL & RESORT
-- Additive migration: preserves existing staff, branches, bookings, sessions and audit data.
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS hotel_countries (
  code TEXT PRIMARY KEY,
  name_th TEXT NOT NULL,
  name_en TEXT NOT NULL,
  default_currency TEXT NOT NULL,
  active INTEGER NOT NULL DEFAULT 1 CHECK(active IN (0,1))
);

CREATE TABLE IF NOT EXISTS currencies (
  code TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  symbol TEXT NOT NULL,
  decimals INTEGER NOT NULL DEFAULT 2 CHECK(decimals BETWEEN 0 AND 4),
  active INTEGER NOT NULL DEFAULT 1 CHECK(active IN (0,1))
);

CREATE TABLE IF NOT EXISTS branch_settings (
  branch_id TEXT PRIMARY KEY,
  country_code TEXT NOT NULL DEFAULT 'TH',
  currency_code TEXT NOT NULL DEFAULT 'THB',
  timezone TEXT NOT NULL DEFAULT 'Asia/Bangkok',
  locale TEXT NOT NULL DEFAULT 'th-TH',
  checkin_time TEXT NOT NULL DEFAULT '14:00',
  checkout_time TEXT NOT NULL DEFAULT '12:00',
  service_charge REAL NOT NULL DEFAULT 0,
  tax_rate REAL NOT NULL DEFAULT 0.07,
  active INTEGER NOT NULL DEFAULT 1 CHECK(active IN (0,1)),
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(branch_id) REFERENCES branches(id),
  FOREIGN KEY(country_code) REFERENCES hotel_countries(code),
  FOREIGN KEY(currency_code) REFERENCES currencies(code)
);

CREATE TABLE IF NOT EXISTS room_types (
  id TEXT PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  name_th TEXT NOT NULL,
  name_en TEXT NOT NULL,
  description_th TEXT NOT NULL DEFAULT '',
  description_en TEXT NOT NULL DEFAULT '',
  max_adults INTEGER NOT NULL DEFAULT 2,
  max_children INTEGER NOT NULL DEFAULT 0,
  bed_config TEXT NOT NULL DEFAULT '',
  amenities_json TEXT NOT NULL DEFAULT '[]',
  images_json TEXT NOT NULL DEFAULT '[]',
  active INTEGER NOT NULL DEFAULT 1 CHECK(active IN (0,1)),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rooms (
  id TEXT PRIMARY KEY,
  branch_id TEXT NOT NULL,
  room_type_id TEXT NOT NULL,
  room_number TEXT NOT NULL,
  floor TEXT,
  status TEXT NOT NULL DEFAULT 'available'
    CHECK(status IN ('available','occupied','maintenance','out_of_service')),
  notes TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(branch_id, room_number),
  FOREIGN KEY(branch_id) REFERENCES branches(id),
  FOREIGN KEY(room_type_id) REFERENCES room_types(id)
);

CREATE TABLE IF NOT EXISTS rate_plans (
  id TEXT PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  name_th TEXT NOT NULL,
  name_en TEXT NOT NULL,
  refundable INTEGER NOT NULL DEFAULT 1 CHECK(refundable IN (0,1)),
  active INTEGER NOT NULL DEFAULT 1 CHECK(active IN (0,1))
);

CREATE TABLE IF NOT EXISTS room_rates (
  id TEXT PRIMARY KEY,
  branch_id TEXT NOT NULL,
  room_type_id TEXT NOT NULL,
  rate_plan_id TEXT NOT NULL,
  currency_code TEXT NOT NULL DEFAULT 'THB',
  nightly_rate REAL NOT NULL CHECK(nightly_rate >= 0),
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  min_nights INTEGER NOT NULL DEFAULT 1,
  active INTEGER NOT NULL DEFAULT 1 CHECK(active IN (0,1)),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(branch_id) REFERENCES branches(id),
  FOREIGN KEY(room_type_id) REFERENCES room_types(id),
  FOREIGN KEY(rate_plan_id) REFERENCES rate_plans(id),
  FOREIGN KEY(currency_code) REFERENCES currencies(code),
  CHECK(end_date >= start_date)
);

CREATE TABLE IF NOT EXISTS booking_items (
  id TEXT PRIMARY KEY,
  booking_id TEXT NOT NULL,
  room_type_id TEXT NOT NULL,
  rate_plan_id TEXT,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK(quantity > 0),
  adults INTEGER NOT NULL DEFAULT 1 CHECK(adults > 0),
  children INTEGER NOT NULL DEFAULT 0 CHECK(children >= 0),
  nightly_rate REAL NOT NULL CHECK(nightly_rate >= 0),
  nights INTEGER NOT NULL CHECK(nights > 0),
  line_total REAL NOT NULL CHECK(line_total >= 0),
  currency_code TEXT NOT NULL DEFAULT 'THB',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(booking_id) REFERENCES bookings(id),
  FOREIGN KEY(room_type_id) REFERENCES room_types(id),
  FOREIGN KEY(rate_plan_id) REFERENCES rate_plans(id),
  FOREIGN KEY(currency_code) REFERENCES currencies(code)
);

CREATE TABLE IF NOT EXISTS inventory_holds (
  id TEXT PRIMARY KEY,
  branch_id TEXT NOT NULL,
  room_type_id TEXT NOT NULL,
  booking_id TEXT,
  checkin_date TEXT NOT NULL,
  checkout_date TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK(quantity > 0),
  status TEXT NOT NULL DEFAULT 'held'
    CHECK(status IN ('held','confirmed','released','expired')),
  expires_at TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(branch_id) REFERENCES branches(id),
  FOREIGN KEY(room_type_id) REFERENCES room_types(id),
  FOREIGN KEY(booking_id) REFERENCES bookings(id),
  CHECK(checkout_date > checkin_date)
);

CREATE TABLE IF NOT EXISTS payment_events (
  id TEXT PRIMARY KEY,
  booking_id TEXT NOT NULL,
  provider TEXT NOT NULL,
  provider_event_id TEXT,
  event_type TEXT NOT NULL,
  amount REAL,
  currency_code TEXT NOT NULL DEFAULT 'THB',
  status TEXT NOT NULL DEFAULT 'received'
    CHECK(status IN ('received','verified','rejected','duplicate','refunded')),
  payload_hash TEXT,
  verified_at TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(booking_id) REFERENCES bookings(id),
  FOREIGN KEY(currency_code) REFERENCES currencies(code),
  UNIQUE(provider, provider_event_id)
);

CREATE TABLE IF NOT EXISTS payment_slips (
  id TEXT PRIMARY KEY,
  booking_id TEXT NOT NULL,
  object_key TEXT NOT NULL UNIQUE,
  content_type TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  review_status TEXT NOT NULL DEFAULT 'pending'
    CHECK(review_status IN ('pending','approved','rejected')),
  reviewed_by TEXT,
  reviewed_at TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(booking_id) REFERENCES bookings(id),
  FOREIGN KEY(reviewed_by) REFERENCES staff_users(id)
);

CREATE TABLE IF NOT EXISTS booking_status_history (
  id TEXT PRIMARY KEY,
  booking_id TEXT NOT NULL,
  old_status TEXT,
  new_status TEXT NOT NULL,
  changed_by TEXT,
  note TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(booking_id) REFERENCES bookings(id),
  FOREIGN KEY(changed_by) REFERENCES staff_users(id)
);

CREATE TABLE IF NOT EXISTS booking_idempotency (
  id TEXT PRIMARY KEY,
  idempotency_key TEXT NOT NULL UNIQUE,
  request_hash TEXT NOT NULL,
  booking_id TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(booking_id) REFERENCES bookings(id)
);

CREATE INDEX IF NOT EXISTS idx_rooms_branch_type_status
  ON rooms(branch_id, room_type_id, status);
CREATE INDEX IF NOT EXISTS idx_rates_lookup
  ON room_rates(branch_id, room_type_id, start_date, end_date, active);
CREATE INDEX IF NOT EXISTS idx_booking_items_booking
  ON booking_items(booking_id);
CREATE INDEX IF NOT EXISTS idx_inventory_dates
  ON inventory_holds(branch_id, room_type_id, checkin_date, checkout_date, status);
CREATE INDEX IF NOT EXISTS idx_payment_events_booking
  ON payment_events(booking_id, created_at);
CREATE INDEX IF NOT EXISTS idx_slips_booking_status
  ON payment_slips(booking_id, review_status);
CREATE INDEX IF NOT EXISTS idx_booking_history
  ON booking_status_history(booking_id, created_at);

INSERT OR IGNORE INTO currencies(code,name,symbol,decimals) VALUES
 ('THB','Thai Baht','฿',2),
 ('USD','US Dollar','$',2),
 ('SGD','Singapore Dollar','S$',2),
 ('MYR','Malaysian Ringgit','RM',2),
 ('IDR','Indonesian Rupiah','Rp',0),
 ('PHP','Philippine Peso','₱',2),
 ('VND','Vietnamese Dong','₫',0),
 ('LAK','Lao Kip','₭',0),
 ('KHR','Cambodian Riel','៛',0),
 ('MMK','Myanmar Kyat','K',2);

INSERT OR IGNORE INTO hotel_countries(code,name_th,name_en,default_currency) VALUES
 ('TH','ประเทศไทย','Thailand','THB'),
 ('SG','สิงคโปร์','Singapore','SGD'),
 ('MY','มาเลเซีย','Malaysia','MYR'),
 ('ID','อินโดนีเซีย','Indonesia','IDR'),
 ('PH','ฟิลิปปินส์','Philippines','PHP'),
 ('VN','เวียดนาม','Vietnam','VND'),
 ('LA','ลาว','Laos','LAK'),
 ('KH','กัมพูชา','Cambodia','KHR'),
 ('MM','เมียนมา','Myanmar','MMK');
