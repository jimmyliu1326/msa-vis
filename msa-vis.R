#!/usr/bin/env Rscript

# load pkgs
suppressPackageStartupMessages(library(ggmsa))
suppressPackageStartupMessages(library(scales))
suppressPackageStartupMessages(library(ggpubr))
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(furrr))

# add parser
parser <- ArgumentParser()

# add cli options
parser$add_argument("-i", "--input", type="character", required=TRUE,
    help = "Path to MSA in FASTA format")
parser$add_argument("-o", "--output", type="character", default="./msa-vis.pdf",
    help="Path to output visualization [default %(default)s]")
parser$add_argument("--type", type="character", required=TRUE,
    choices = c("dna", "aa"),
    help="Specify input MSA is DNA or amino acid alignment")
parser$add_argument("--include_legend", action="store_true",
    help="Add colour legend")
parser$add_argument("--hide_letters", action="store_true",
    help="Do not display nucleotide/amino acid letters")
parser$add_argument("--chunk_len", type="integer", default=50,
    help="Number of base pairs to show per alignment chunk [default \"%(default)s\"]")
parser$add_argument("--font", type="character", default='helvetical',
    choices = c('helvetical', 'mono', 'DroidSansMono', 'TimesNewRoman'),
    help="Font style [default \"%(default)s\"]")
parser$add_argument("--fontsize", type="integer", default=9,
    help="Font size [default \"%(default)s\"]")
parser$add_argument("-t", "--threads", type="double", default=1,
    help="Number of threads to use [default \"%(default)s\"]")

# parse args
args <- parser$parse_args()

# hide warning msgs in ggplot

# get executing script name
src_name <- gsub("--file=", "", commandArgs()[4])

# params check
check_params <- function(args) {
    # check if input file exists
    if ( !file.exists(args$input) ) { 
        message(paste0(src_name, ": Input MSA [ ", args$input, " ] does not exist, exiting."))
        quit(status=1)
    }
}

# plot msa
plot_msa <- function(
    msa, start, end, 
    scheme="Chemistry_NT", 
    font_size=10, 
    font = 'helvetical', 
    name = T,
    char_width = 0.5,
    show_legend = F,
    show_letter = T
    ) {
        suppressMessages(
            p <- msa %>% 
                ggmsa(
                    start, end, 
                    seq_name = name,
                    color = scheme,
                    char_width = char_width,
                    show.legend = show_legend,
                    font = font
                ) +
                theme_minimal(font_size) +
                geom_seqlogo(color = scheme) +
                theme(
                    panel.grid = element_blank(),
                    # plot.margin = margin(t = 0,  # Top margin
                    #                      r = 0,  # Right margin
                    #                      b = 0,  # Bottom margin
                    #                      l = 0), # Left margin
                    #axis.text.y = element_text(colour = cols),
                    legend.position = "top"
                ) +
                scale_x_continuous(
                    labels = comma,
                    expand = c(0,0)
                ) +
                labs(fill = "")
        )
            
        p
}

# main
main <- function() {
    # validate args
    check_params(args)
    # set up parellel processing
    if ( args$threads > 1) { plan(future::cluster, workers = args$threads) }
    # read msa
    msa <- Biostrings::readDNAStringSet(args$input)
    # revise fasta header names; only keep strings before the first blank space
    names(msa) <- gsub(" .*", "", names(msa))
    # create msa viz for each subregion with length of chunk_len
    plots <- future_map(
        seq(1, msa@ranges@width[1], args$chunk_len),
        ~plot_msa(
            msa,
            start=.,
            end=. + args$chunk_len - 1,
            scheme=ifelse(args$type == "dna", "Chemistry_NT", "Chemistry_AA"),
            show_legend=args$include_legend,
            font=unlist(ifelse(args$hide_letters, list(NULL), list(args$font))),
            font_size=args$fontsize
            ),
        .progress = T
        )
    # combine all subregion plots into one figure
    fig <- ggarrange(
        plotlist = plots,
        ncol = 1,
        nrow = ifelse(round(35/length(msa@ranges)) < 1, 1, round(35/length(msa@ranges))),
        common.legend = T
        )
    # export figure
    ggexport(fig, filename = args$output)
    unlink("Rplots.pdf")

    # Shut down parallel sessions
    if (!inherits(plan(), "sequential")) plan(sequential)
}

main()