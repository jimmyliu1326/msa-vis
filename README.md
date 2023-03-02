# msa-vis 
![r-vers](https://img.shields.io/badge/%20-v4.1.3-gray?labelColor=blue&logo=R)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

![docker build](https://github.com/jimmyliu1326/msa-vis/actions/workflows/docker-image.yml/badge.svg)
![docker image size](https://img.shields.io/docker/image-size/jimmyliu1326/msa-vis)

## Introduction
`msa-vis` is developed to generate publication-grade visualizations for multiple sequence alignments (MSA).

## Getting started

The source code and required dependencies are containerized as a single image file that can be downloaded via `Docker` or `Singularity`.

#### Docker
```
docker pull jimmyliu1326/msa-vis
```
#### Singularity
```
singularity pull docker://jimmyliu1326/msa-vis
```

Once the image has been downloaded, try calling `msa-vis.R` to print the script usage message to screen.

#### Docker
```
docker run jimmyliu1326/msa-vis msa-vis.R --help
```
#### Singularity
```
singularity exec msa-vis.sif msa-vis.R --help
```

If the help message successfully prints to screen, then you are all set! :partying_face:

## Example visualizations
### DNA alignment
![](img/dna.png)
### Amino acid alignment
![](img/aa.png)

## Credit
`msa-vis` would not have been possible without the following open source packages developed by the amazing R community:

* [ggmsa](https://github.com/YuLab-SMU/ggmsa)
* [ggpubr](https://github.com/kassambara/ggpubr)
* [scales](https://github.com/r-lib/scales)
* [furrr](https://github.com/DavisVaughan/furrr)
* [Biostrings](https://github.com/Bioconductor/Biostrings)