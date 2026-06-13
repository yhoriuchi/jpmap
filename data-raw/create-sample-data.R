library(sf)

dir.create("data", showWarnings = FALSE)
dir.create("inst/extdata", recursive = TRUE, showWarnings = FALSE)

downloaded_natural_earth_zip <- "/private/tmp/jpmap-natural-earth/ne_10m_admin_1_states_provinces.zip"
natural_earth_zip <- if (file.exists(downloaded_natural_earth_zip)) {
  downloaded_natural_earth_zip
} else {
  file.path(tempdir(), "ne_10m_admin_1_states_provinces.zip")
}
natural_earth_url <- paste0(
  "https://naturalearth.s3.amazonaws.com/10m_cultural/",
  "ne_10m_admin_1_states_provinces.zip"
)
downloaded_okinawa_topojson <- "/private/tmp/okinawa_20230101_city.h.topojson"
okinawa_topojson <- if (file.exists(downloaded_okinawa_topojson)) {
  downloaded_okinawa_topojson
} else {
  file.path(tempdir(), "okinawa_20230101_city.h.topojson")
}
okinawa_topojson_url <- paste0(
  "https://geoshape.ex.nii.ac.jp/city/topojson/20230101/47/",
  "47_city.h.topojson"
)

if (!file.exists(natural_earth_zip)) {
  utils::download.file(natural_earth_url, natural_earth_zip, mode = "wb")
}
if (!file.exists(okinawa_topojson)) {
  utils::download.file(okinawa_topojson_url, okinawa_topojson, mode = "wb")
}

natural_earth_dir <- file.path(tempdir(), "jpmap-natural-earth-admin1")
dir.create(natural_earth_dir, showWarnings = FALSE)
utils::unzip(natural_earth_zip, exdir = natural_earth_dir)

source("R/prefectures.R", local = TRUE)

admin1 <- sf::st_read(
  file.path(natural_earth_dir, "ne_10m_admin_1_states_provinces.shp"),
  quiet = TRUE
)

japan <- admin1[admin1$adm0_a3 == "JPN" | admin1$admin == "Japan", ]
japan$pref_code <- sub("^JP-", "", japan$iso_3166_2)
japan <- merge(
  japan,
  jp_prefectures,
  by = "pref_code",
  all.x = TRUE,
  sort = FALSE
)

japan <- japan[order(as.integer(japan$pref_code)), ]
prefectures <- sf::st_sf(
  data.frame(
    jis_code = japan$pref_code,
    pref_code = japan$pref_code,
    prefecture = japan$prefecture,
    prefecture_ja = japan$prefecture_ja,
    stringsAsFactors = FALSE
  ),
  geometry = sf::st_geometry(japan),
  crs = sf::st_crs(japan)
)
prefectures <- sf::st_make_valid(prefectures)

gpkg <- file.path("inst/extdata", "jpmap_boundaries_2021.gpkg")
if (file.exists(gpkg)) {
  unlink(gpkg)
}
sf::st_write(prefectures, gpkg, layer = "prefectures", quiet = TRUE)

okinawa_raw <- sf::st_read(okinawa_topojson, quiet = TRUE)
sf::st_crs(okinawa_raw) <- 4326

okinawa_names <- data.frame(
  municipality_code = c(
    "47201", "47205", "47207", "47208", "47209", "47210",
    "47211", "47212", "47213", "47214", "47215", "47301",
    "47302", "47303", "47306", "47308", "47311", "47313",
    "47314", "47315", "47324", "47325", "47326", "47327",
    "47328", "47329", "47348", "47350", "47353", "47354",
    "47355", "47356", "47357", "47358", "47359", "47360",
    "47361", "47362", "47375", "47381", "47382"
  ),
  municipality = c(
    "Naha", "Ginowan", "Ishigaki", "Urasoe", "Nago", "Itoman",
    "Okinawa", "Tomigusuku", "Uruma", "Miyakojima", "Nanjo", "Kunigami",
    "Ogimi", "Higashi", "Nakijin", "Motobu", "Onna", "Ginoza",
    "Kin", "Ie", "Yomitan", "Kadena", "Chatan", "Kitanakagusuku",
    "Nakagusuku", "Nishihara", "Yonabaru", "Haebaru", "Tokashiki",
    "Zamami", "Aguni", "Tonaki", "Minamidaito", "Kitadaito", "Iheya",
    "Izena", "Kumejima", "Yaese", "Tarama", "Taketomi", "Yonaguni"
  ),
  stringsAsFactors = FALSE
)

current_municipality <- !is.na(okinawa_raw$N03_007) &
  as.character(okinawa_raw$N03_007) %in% okinawa_names$municipality_code
okinawa_raw <- okinawa_raw[current_municipality, ]

okinawa_municipalities <- merge(
  okinawa_raw,
  okinawa_names,
  by.x = "N03_007",
  by.y = "municipality_code",
  all.x = TRUE,
  sort = FALSE
)
if (any(is.na(okinawa_municipalities$municipality))) {
  stop("Missing English municipality names in the Okinawa example boundary layer.")
}
district <- as.character(okinawa_municipalities$N03_003)
district[is.na(district)] <- ""
municipality_ja <- as.character(okinawa_municipalities$N03_004)
municipality_full_ja <- ifelse(nzchar(district), paste0(district, municipality_ja), municipality_ja)

okinawa_municipalities <- sf::st_sf(
  data.frame(
    jis_code = okinawa_municipalities$N03_007,
    pref_code = "47",
    prefecture = "Okinawa",
    prefecture_ja = "沖縄県",
    municipality_code = okinawa_municipalities$N03_007,
    municipality = okinawa_municipalities$municipality,
    municipality_ja = municipality_ja,
    municipality_full_ja = municipality_full_ja,
    source = "Geoshape city boundaries 2023-01-01, CC BY 4.0",
    source_url = okinawa_topojson_url,
    stringsAsFactors = FALSE
  ),
  geometry = sf::st_geometry(okinawa_municipalities),
  crs = 4326
)
okinawa_municipalities <- okinawa_municipalities[order(okinawa_municipalities$municipality_code), ]
okinawa_municipalities <- sf::st_make_valid(okinawa_municipalities)
sf::st_write(okinawa_municipalities, gpkg, layer = "municipalities", append = TRUE, quiet = TRUE)

jp_prefecture_gdp <- data.frame(
  pref_code = c(
    "13", "23", "08", "25", "22", "09", "18", "24", "16", "10",
    "35", "27", "36", "19", "34", "07", "26", "20", "04", "44",
    "17", "28", "15", "30", "37", "21", "33", "06", "32", "01",
    "41", "03", "38", "14", "40", "46", "05", "43", "02", "42",
    "31", "45", "39", "12", "11", "47", "29"
  ),
  prefecture = c(
    "Tokyo", "Aichi", "Ibaraki", "Shiga", "Shizuoka", "Tochigi",
    "Fukui", "Mie", "Toyama", "Gunma", "Yamaguchi", "Osaka",
    "Tokushima", "Yamanashi", "Hiroshima", "Fukushima", "Kyoto",
    "Nagano", "Miyagi", "Oita", "Ishikawa", "Hyogo", "Niigata",
    "Wakayama", "Kagawa", "Gifu", "Okayama", "Yamagata", "Shimane",
    "Hokkaido", "Saga", "Iwate", "Ehime", "Kanagawa", "Fukuoka",
    "Kagoshima", "Akita", "Kumamoto", "Aomori", "Nagasaki",
    "Tottori", "Miyazaki", "Kochi", "Chiba", "Saitama", "Okinawa",
    "Nara"
  ),
  year = 2021L,
  gdp_per_capita_jpy = c(
    7766347, 5167492, 4879071, 4655665, 4650280, 4573224,
    4636185, 4635603, 4557627, 4540022, 4494653, 4490904,
    4489923, 4402396, 4175368, 4143509, 4075437, 4060091,
    4032942, 4024107, 3981512, 3965450, 3945045, 3942511,
    3925639, 3909815, 3904180, 3885042, 3843703, 3793036,
    3775119, 3762230, 3687715, 3656692, 3634274, 3596016,
    3590063, 3554347, 3499582, 3409705, 3358216, 3343478,
    3325214, 3173539, 3094684, 2851622, 2741738
  ),
  gdp_per_capita_usd_ppp = c(
    78694, 52361, 49438, 47174, 47120, 46339,
    46977, 46971, 46181, 46003, 45543, 45505,
    45495, 44608, 42308, 41985, 41295, 41140,
    40865, 40775, 40343, 40181, 39974, 39948,
    39777, 39617, 39560, 39366, 38947, 38434,
    38252, 38122, 37366, 37052, 36825, 36437,
    36383, 36015, 35460, 34550, 34028, 33878,
    33693, 32157, 31358, 28895, 27781
  ),
  source = paste0(
    "OECD 2021 regional GDP per-capita values as tabulated at ",
    "https://en.wikipedia.org/wiki/List_of_Japanese_prefectures_by_GDP_per_capita"
  ),
  stringsAsFactors = FALSE
)

jp_us_military_bases <- data.frame(
  base = c(
    "Misawa Air Base",
    "Yokota Air Base",
    "United States Fleet Activities Yokosuka",
    "Naval Air Facility Atsugi",
    "Marine Corps Air Station Iwakuni",
    "Okinawa U.S. military facilities",
    "Kadena Air Base",
    "Camp Courtney / III Marine Expeditionary Force",
    "Camp Hansen",
    "Camp Schwab",
    "Camp Foster",
    "Marine Corps Air Station Futenma",
    "Camp Kinser",
    "Torii Station",
    "Camp Gonsalves",
    "White Beach Naval Facility",
    "Naha Port Facility"
  ),
  branch = c(
    "Air Force", "Air Force", "Navy", "Navy",
    "Marine Corps", "Joint", "Air Force", "Marine Corps",
    "Marine Corps", "Marine Corps", "Marine Corps", "Marine Corps",
    "Marine Corps", "Army", "Marine Corps", "Navy", "Army"
  ),
  prefecture = c(
    "Aomori", "Tokyo", "Kanagawa", "Kanagawa",
    "Yamaguchi", "Okinawa", "Okinawa", "Okinawa",
    "Okinawa", "Okinawa", "Okinawa", "Okinawa",
    "Okinawa", "Okinawa", "Okinawa", "Okinawa", "Okinawa"
  ),
  municipality = c(
    "Misawa", "Fussa", "Yokosuka", "Ayase/Yamato",
    "Iwakuni", "Okinawa Island", "Kadena/Chatan/Okinawa",
    "Uruma", "Kin", "Nago/Ginoza", "Ginowan/Chatan/Kitanakagusuku/Okinawa",
    "Ginowan", "Urasoe", "Yomitan", "Kunigami/Higashi",
    "Uruma", "Naha"
  ),
  lon = c(
    141.3684, 139.3489, 139.6722, 139.4505,
    132.2357, 127.8000, 127.7676, 127.8620,
    127.9200, 128.0440, 127.7797, 127.7560,
    127.7000, 127.7440, 128.2400, 127.9640, 127.6630
  ),
  lat = c(
    40.7032, 35.7485, 35.2876, 35.4546,
    34.1439, 26.3500, 26.3517, 26.3900,
    26.4600, 26.5310, 26.3014, 26.2740,
    26.2470, 26.3940, 26.7400, 26.3030, 26.2130
  ),
  personnel = as.integer(c(
    5200, 14000, NA, 350, 10000, 26000, 20000, 27000,
    6000, NA, NA, NA, NA, NA, NA, NA, NA
  )),
  personnel_scope = c(
    "U.S. military personnel",
    "base personnel",
    "no consistent public base-specific figure used",
    "military personnel remaining when the carrier is in port after fixed-wing relocation",
    "Marines, sailors, and family members",
    "U.S. military personnel stationed on Okinawa Island",
    "American servicemembers, family members, and Japanese employees",
    "III MEF command size; command-level figure, not a Camp Courtney headcount",
    "Marines",
    "no consistent public base-specific figure used",
    "no consistent public base-specific figure used",
    "no consistent public base-specific figure used",
    "no consistent public base-specific figure used",
    "no consistent public base-specific figure used",
    "no consistent public base-specific figure used",
    "no consistent public base-specific figure used",
    "no consistent public base-specific figure used"
  ),
  personnel_geography = c(
    "installation", "installation", "installation", "installation",
    "installation", "regional", "installation-community", "command",
    "installation", "installation", "installation", "installation",
    "installation", "installation", "installation", "installation",
    "installation"
  ),
  personnel_is_base_specific = c(
    TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, FALSE, FALSE,
    TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE
  ),
  source_url = c(
    "https://en.wikipedia.org/wiki/Misawa_Air_Base",
    "https://en.wikipedia.org/wiki/Yokota_Air_Base",
    "https://en.wikipedia.org/wiki/United_States_Fleet_Activities_Yokosuka",
    "https://en.wikipedia.org/wiki/Naval_Air_Facility_Atsugi",
    "https://en.wikipedia.org/wiki/Marine_Corps_Air_Station_Iwakuni",
    "https://en.wikipedia.org/wiki/Okinawa_Island",
    "https://en.wikipedia.org/wiki/Kadena_Air_Base",
    "https://en.wikipedia.org/wiki/III_Marine_Expeditionary_Force",
    "https://en.wikipedia.org/wiki/Camp_Hansen",
    "https://en.wikipedia.org/wiki/Camp_Schwab",
    "https://en.wikipedia.org/wiki/Camp_Foster",
    "https://en.wikipedia.org/wiki/Marine_Corps_Air_Station_Futenma",
    "https://en.wikipedia.org/wiki/Camp_Kinser",
    "https://en.wikipedia.org/wiki/Torii_Station",
    "https://en.wikipedia.org/wiki/Camp_Gonsalves",
    "https://en.wikipedia.org/wiki/Naval_Base_Okinawa",
    "https://en.wikipedia.org/wiki/Okinawa_Prefecture"
  ),
  note = paste(
    "Approximate public figures collected for package examples.",
    "Personnel scopes differ by source; use personnel_scope and",
    "personnel_geography before interpreting bubble sizes."
  ),
  stringsAsFactors = FALSE
)

save(jp_prefecture_gdp, file = "data/jp_prefecture_gdp.rda", compress = "xz")
save(jp_us_military_bases, file = "data/jp_us_military_bases.rda", compress = "xz")
