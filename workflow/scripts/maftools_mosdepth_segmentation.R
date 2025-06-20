log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

rlang::global_entrace()

library(maftools)
library(withr)
library(stringr)
library(fs)

pdf(file = snakemake@output[["plot"]],   # The directory you want to save the file in
    width = 4, # The width of the plot in inches
    height = 4) # The height of the plot in inches

working_directory <- getwd()

# this is to avoid race conditions between multiple samples
withr::with_tempdir({
  if ( exists(snakemake@input[["mosdepth"]]) ) {
    name = snakemake@wildcards[["sample"]],
    plotMosdepth_t(
      bed = snakemake@input[["mosdepth"]],
      sample_name = name,
      segment = TRUE
    )
  } else if ( exists(snakemake@input[["mosdepth_main"]]) ) {
    name = stringr::str_c(snakemake@wildcards[["group"]], ".", snakemake@wildcards[["alias"]])
    plotMosdepth(
      t_bed = snakemake@input[["mosdepth_main"]],
      n_bed = snakemake@input[["mosdepth_background"]],
      sample_name = name,
      segment = TRUE
    )
  } else {
    cli_abort(c(
            "This script expects 'mosdepth' or 'mosdepth_main' as named inputs to the snakemake rule.",
      "x" = "You provided {snakemake@input}."
    ))
  }
  fs::file_move(
    path = stringr::str_c(
      name,
      "_cbs.seg"
    ),
    new_path = file.path(
      working_directory,
      snakemake@output[["segments"]]
    ),
  )
})

dev.off()

