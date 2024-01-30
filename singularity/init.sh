#!/bin/bash

source /home/cindy.vanvelthoven/miniconda3/etc/profile.d/conda.sh && \
  conda activate $CONDA_PREFIX && \
  rserver \
    --www-address=0.0.0.0 \
    --www-port=$PORT \
    --rsession-which-r=$RSTUDIO_WHICH_R \
    --rsession-ld-library-path=$CONDA_PREFIX/lib \
    `# optional: old behaviour of R sessions` \
    --auth-timeout-minutes=0 --auth-stay-signed-in-days=30  \
    `# activate password authentication` \
    --auth-none=1 \
    --auth-pam-helper-path=pam-helper \
    --auth-minimum-user-id=500 \
    --server-user $USER

