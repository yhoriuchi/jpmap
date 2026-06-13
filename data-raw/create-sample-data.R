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

if (!file.exists(natural_earth_zip)) {
  utils::download.file(natural_earth_url, natural_earth_zip, mode = "wb")
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
    "Kadena Air Base",
    "Camp Hansen",
    "Camp Schwab"
  ),
  branch = c(
    "Air Force", "Air Force", "Navy", "Navy",
    "Marine Corps", "Air Force", "Marine Corps", "Marine Corps"
  ),
  prefecture = c(
    "Aomori", "Tokyo", "Kanagawa", "Kanagawa",
    "Yamaguchi", "Okinawa", "Okinawa", "Okinawa"
  ),
  municipality = c(
    "Misawa", "Fussa", "Yokosuka", "Ayase/Yamato",
    "Iwakuni", "Kadena/Chatan/Okinawa", "Kin", "Nago/Ginoza"
  ),
  lon = c(141.3684, 139.3489, 139.6722, 139.4505, 132.2357, 127.7676, 127.9200, 128.0440),
  lat = c(40.7032, 35.7485, 35.2876, 35.4546, 34.1439, 26.3517, 26.4600, 26.5310),
  personnel = c(5200L, 14000L, 27000L, 350L, 10000L, 20000L, 6000L, 242L),
  personnel_scope = c(
    "U.S. military personnel",
    "base personnel",
    "Seventh Fleet sailors and Marines; command-level figure, not an installation headcount",
    "military personnel remaining when the carrier is in port after fixed-wing relocation",
    "Marines, sailors, and family members",
    "American servicemembers, family members, and Japanese employees",
    "Marines",
    "stationed Marine employees"
  ),
  source_url = c(
    "https://en.wikipedia.org/wiki/Misawa_Air_Base",
    "https://en.wikipedia.org/wiki/Yokota_Air_Base",
    "https://en.wikipedia.org/wiki/United_States_Seventh_Fleet",
    "https://en.wikipedia.org/wiki/Naval_Air_Facility_Atsugi",
    "https://en.wikipedia.org/wiki/Marine_Corps_Air_Station_Iwakuni",
    "https://en.wikipedia.org/wiki/Kadena_Air_Base",
    "https://en.wikipedia.org/wiki/Camp_Hansen",
    "https://en.wikipedia.org/wiki/Camp_Schwab"
  ),
  note = paste(
    "Approximate public figures collected for package examples;",
    "some rows describe broader installation or command populations."
  ),
  stringsAsFactors = FALSE
)

save(jp_prefecture_gdp, file = "data/jp_prefecture_gdp.rda", compress = "xz")
save(jp_us_military_bases, file = "data/jp_us_military_bases.rda", compress = "xz")
