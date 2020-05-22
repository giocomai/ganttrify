test_project <- tibble::tribble(~wp, ~activity, ~start_date, ~end_date,
                                "WP1 - Whatever admin", "1.1. That admin activity", 1, 6, 
                                "WP1 - Whatever admin", "1.2. Another admin activity", 3, 6,
                                "WP1 - Whatever admin", "1.3. Fancy admin activity", 4, 7,
                                "WP2 - Whatever actual work", "2.1. Actual stuff", 5, 10,
                                "WP2 - Whatever actual work", "2.2. Actual R&D stuff", 6, 12,
                                "WP2 - Whatever actual work", "2.3. Really real research", 9, 12,
                                "WP2 - Whatever actual work", "2.4. Ethics!", 3, 5,
                                "WP2 - Whatever actual work", "2.4. Ethics!", 8, 9,
                                "WP3 - Dissemination", "3.1. Disseminate near", 6, 9,
                                "WP3 - Dissemination", "3.1. Disseminate near", 12, 12,
                                "WP3 - Dissemination", "3.2. Disseminate far", 8, 12) 
usethis::use_data(test_project, overwrite = TRUE)

test_spots <- tibble::tribble(~activity, ~spot_type, ~spot_date,
                "1.1. That admin activity", "D",5,
                "1.3. Fancy admin activity", "E", 7,
                "2.2. Actual R&D stuff", "O", 7,
                "2.2. Actual R&D stuff", "O", 9,
                "2.2. Actual R&D stuff", "O", 11,
                "WP2 - Whatever actual work", "M", 6
)

usethis::use_data(test_spots, overwrite = TRUE)



test_project_date_month <- tibble::tribble(~wp, ~activity, ~start_date, ~end_date,
                                "WP1 - Whatever admin", "1.1. That admin activity", "2021-01", "2021-06", 
                                "WP1 - Whatever admin", "1.2. Another admin activity", "2021-03", "2021-06",
                                "WP1 - Whatever admin", "1.3. Fancy admin activity", "2021-04", "2021-07",
                                "WP2 - Whatever actual work", "2.1. Actual stuff", "2021-05", "2021-10",
                                "WP2 - Whatever actual work", "2.2. Actual R&D stuff", "2021-06", "2021-12",
                                "WP2 - Whatever actual work", "2.3. Really real research", "2021-09", "2021-12",
                                "WP2 - Whatever actual work", "2.4. Ethics!", "2021-03", "2021-05",
                                "WP2 - Whatever actual work", "2.4. Ethics!", "2021-08", "2021-09",
                                "WP3 - Dissemination", "3.1. Disseminate near", "2021-06", "2021-09",
                                "WP3 - Dissemination", "3.1. Disseminate near", "2021-12", "2021-12",
                                "WP3 - Dissemination", "3.2. Disseminate far", "2021-08", "2021-12",) 
usethis::use_data(test_project_date_month, overwrite = TRUE)


test_spots_date_month <- tibble::tribble(~activity, ~spot_type, ~spot_date,
                              "1.1. That admin activity", "D", "2021-05",
                              "1.3. Fancy admin activity", "E", "2021-07",
                              "2.2. Actual R&D stuff", "O", "2021-07",
                              "2.2. Actual R&D stuff", "O", "2021-09",
                              "2.2. Actual R&D stuff", "O", "2021-11",
                              "WP2 - Whatever actual work", "M", "2021-06"
)

usethis::use_data(test_spots_date_month, overwrite = TRUE)


test_project_date_day <- tibble::tribble(~wp, ~activity, ~start_date, ~end_date,
                                         "Data team", "Data collection", "2020-09-01", "2020-09-10", 
                                         "Data team", "Data processing", "2020-09-08", "2020-09-14",
                                         "Data team", "Reporting", "2020-09-14","2020-09-16",
                                         "Data team", "Data visualisation", "2020-10-23","2020-10-30",
                                         "Investigative team", "Fieldwork", "2020-09-05", "2020-09-15",
                                         "Investigative team", "Fieldwork", "2020-10-10", "2020-10-20",
                                         "Investigative team", "Writing", "2020-10-21", "2020-10-31",
                                         "Social media team", "Draft outputs", "2020-10-25", "2020-10-28",
                                         "Social media team", "Active promo", "2020-10-31","2020-12-15",
                                       ) 
usethis::use_data(test_project_date_day, overwrite = TRUE)


test_spots_date_day <- tibble::tribble(~activity, ~spot_type, ~spot_date,
                                         "Data visualisation", "O", "2020-10-30",
                                         "Writing", "O", "2020-10-31"
)

usethis::use_data(test_spots_date_day, overwrite = TRUE)
