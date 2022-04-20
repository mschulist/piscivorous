## General Functions
## Script which includes any of the user-defined functions used across scripts
## Mark Schulist - January 2022

drive_sync <- function(local_dir, drive_folder, pattern = NULL) {
  # First creating the local_dir if it does not exist
  if (dir.exists(local_dir) == FALSE) {
    dir.create(local_dir)
  }
  
  
  # Getting info about the directories and the files in them
    if (is.null(pattern) == TRUE) {
      google_files <- drive_ls(as_dribble(drive_folder))
    } else {
      google_files <- drive_ls(as_dribble(drive_folder)) %>%
        filter(str_detect(name, pattern = pattern))
    }
  
  # Making it work on windows and unix systems
  if (Sys.info()["sysname"] == "Windows") {
    local_files <- list.files(local_dir)
  } else {
    if (is.null(pattern) == TRUE) {
      local_files <- basename(system(paste0("find ", local_dir, " -mindepth 1 -maxdepth 1 ! -type l"), intern = TRUE))
    } else {
      local_files <- basename(system(paste0("find ", local_dir, " -mindepth 1 -maxdepth 1 ! -type l"), intern = TRUE)) %>%
        str_subset(pattern = pattern)
    }
  }
  
  # Comparing the two directories
  only_local <- local_files[!(local_files %in% google_files$name)]
  only_google <- google_files %>% filter(!(google_files$name %in% local_files))
  
  # Uploading the only_local and downloading the only_google
  map(
    only_local,
    ~ drive_upload(paste0(local_dir, .x), path = as_dribble(drive_folder))
  )
  
  map2(
    only_google$id, only_google$name,
    ~ drive_download(.x, path = paste0(local_dir, .y))
  )
}
