test_that("NAs are caught by gantt_verify", {
  expect_warning(object = {
    project <- data.frame(
      wp = letters[1:3],
      activity = month.name[1:3],
      start_date = 1:3,
      end_date = 4:6
    )

    project[2, 2] <- NA_character_
    gantt_verify(project)
  })

  expect_identical(
    object = {
      project <- data.frame(
        wp = letters[1:3],
        activity = month.name[1:3],
        start_date = 1:3,
        end_date = 4:6
      )

      project[2, 2] <- NA_character_

      suppressWarnings(nrow(gantt_verify(project)))
    },
    expected = 2L
  )



  expect_identical(
    object = {
      project <- data.frame(
        wp = letters[1:3],
        activity = month.name[1:3],
        start_date = 1:3,
        end_date = 4:6
      )

      project[2:3, 2] <- NA_character_

      suppressWarnings(nrow(gantt_verify(project)))
    },
    expected = 1L
  )
})
