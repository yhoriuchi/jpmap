jp_prefectures <- data.frame(
  pref_code = sprintf("%02d", 1:47),
  prefecture_ja = c(
    "\u5317\u6d77\u9053", "\u9752\u68ee\u770c",
    "\u5ca9\u624b\u770c", "\u5bae\u57ce\u770c",
    "\u79cb\u7530\u770c", "\u5c71\u5f62\u770c",
    "\u798f\u5cf6\u770c", "\u8328\u57ce\u770c",
    "\u6803\u6728\u770c", "\u7fa4\u99ac\u770c",
    "\u57fc\u7389\u770c", "\u5343\u8449\u770c",
    "\u6771\u4eac\u90fd", "\u795e\u5948\u5ddd\u770c",
    "\u65b0\u6f5f\u770c", "\u5bcc\u5c71\u770c",
    "\u77f3\u5ddd\u770c", "\u798f\u4e95\u770c",
    "\u5c71\u68a8\u770c", "\u9577\u91ce\u770c",
    "\u5c90\u961c\u770c", "\u9759\u5ca1\u770c",
    "\u611b\u77e5\u770c", "\u4e09\u91cd\u770c",
    "\u6ecb\u8cc0\u770c", "\u4eac\u90fd\u5e9c",
    "\u5927\u962a\u5e9c", "\u5175\u5eab\u770c",
    "\u5948\u826f\u770c", "\u548c\u6b4c\u5c71\u770c",
    "\u9ce5\u53d6\u770c", "\u5cf6\u6839\u770c",
    "\u5ca1\u5c71\u770c", "\u5e83\u5cf6\u770c",
    "\u5c71\u53e3\u770c", "\u5fb3\u5cf6\u770c",
    "\u9999\u5ddd\u770c", "\u611b\u5a9b\u770c",
    "\u9ad8\u77e5\u770c", "\u798f\u5ca1\u770c",
    "\u4f50\u8cc0\u770c", "\u9577\u5d0e\u770c",
    "\u718a\u672c\u770c", "\u5927\u5206\u770c",
    "\u5bae\u5d0e\u770c", "\u9e7f\u5150\u5cf6\u770c",
    "\u6c96\u7e04\u770c"
  ),
  prefecture = c(
    "Hokkaido", "Aomori", "Iwate", "Miyagi", "Akita", "Yamagata",
    "Fukushima", "Ibaraki", "Tochigi", "Gunma", "Saitama", "Chiba",
    "Tokyo", "Kanagawa", "Niigata", "Toyama", "Ishikawa", "Fukui",
    "Yamanashi", "Nagano", "Gifu", "Shizuoka", "Aichi", "Mie",
    "Shiga", "Kyoto", "Osaka", "Hyogo", "Nara", "Wakayama",
    "Tottori", "Shimane", "Okayama", "Hiroshima", "Yamaguchi",
    "Tokushima", "Kagawa", "Ehime", "Kochi", "Fukuoka", "Saga",
    "Nagasaki", "Kumamoto", "Oita", "Miyazaki", "Kagoshima", "Okinawa"
  ),
  stringsAsFactors = FALSE
)

prefecture_name_from_code <- function(pref_code) {
  idx <- match(as.character(pref_code), jp_prefectures$pref_code)
  jp_prefectures$prefecture[idx]
}
