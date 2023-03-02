FROM rocker/r-ver:4.1.3

RUN apt-get update -y && \
    apt-get install -y procps pandoc && \
    rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages(c( \
                'ggpubr', 'scales', \
                'furrr', 'argparse', \
                'remotes'))" && \
    R -e "remotes::install_github('YuLab-SMU/ggmsa'))"

ADD msa-vis.R /usr/local/bin/

ADD data/ /data/

RUN chmod 777 /usr/local/bin/msa-vis.R