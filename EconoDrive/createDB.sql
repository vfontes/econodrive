CREATE TABLE IF NOT EXISTS "obd_data"(
"id" Integer NOT NULL PRIMARY KEY AUTOINCREMENT,
"timestamp" DateTime NOT NULL DEFAULT CURRENT_TIMESTAMP,
"obd_fuelsys" Text,
"obd_map" Text,
"obd_rpm" Text,
"obd_vss" Text,
"obd_iat" Text,
"obd_o2sensor" Text,
"gps_latitude" Real,
"gps_longitude" Real,
"gps_vss" Real,
"gps_altitude" Real,
"gps_distance" Real);

