library(targets)

tarchives::tar_source_archive("locationchoicedatajp")

files <- locationchoicedatajp::prefectural_land_price_files()
land_price_pipeline(
  files = files,
  names = locationchoicedatajp::prefectural_land_price_target_name(files$year),
  build = "prefectural_land_price_build"
)
