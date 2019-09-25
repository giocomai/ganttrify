## code to prepare `test_project` dataset goes here


test_project <- tibble::tribble(~wp, ~activity, ~start_month, ~end_month, 
                                "WP1 - Whatever admin", "1.1. That admin activity", 1, 6,
                                "WP1 - Whatever admin", "1.2. Another admin activity", 3, 6,
                                "WP1 - Whatever admin", "1.3. Fancy admin activity", 4, 5,
                                "WP2 - Whatever actual work", "2.1. Actual stuff", 5, 10,
                                "WP2 - Whatever actual work", "2.2. Actual R&D stuff", 6, 12,
                                "WP2 - Whatever actual work", "2.3. Really real research", 9, 12,
                                "WP2 - Whatever actual work", "2.4. Ethics!", 3, 5,
                                "WP2 - Whatever actual work", "2.4. Ethics!", 8, 9,
                                "WP3 - Dissemination", "3.1. Disseminate near", 6, 9,
                                "WP3 - Dissemination", "3.1. Disseminate near", 12, 12,
                                "WP3 - Dissemination", "3.2. Disseminate far", 8, 12) 
usethis::use_data(test_project)
