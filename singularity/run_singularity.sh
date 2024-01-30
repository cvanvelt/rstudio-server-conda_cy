#!/bin/bash

# See also https://www.rocker-project.org/use/singularity/

# Main parameters for the script with default values
PORT=${PORT:-8585}
USER=$(whoami)
PASSWORD=${PASSWORD:-rstudio}
TMPDIR=${TMPDIR:-tmp}
CONTAINER=${CONTAINER:-"./containers/tidyverse_latest.sif"}  # path to singularity container (will be automatically downloaded)
CONDA_PREFIX=${CONDA_PREFIX:-"./myPY/envs/r42_env"}
# Set-up temporary paths
RSTUDIO_TMP="${TMPDIR}/$(echo -n $CONTAINER | md5sum | awk '{print $1}')"
mkdir -p $RSTUDIO_TMP/{run,var-lib-rstudio-server,local-share-rstudio,rstudio}

R_BIN=$CONDA_PREFIX/bin/R
PY_BIN=$CONDA_PREFIX/bin/python

export XDG_DATA_HOME=$RSTUDIO_TMP

if [ ! -f $CONTAINER ]; then
	singularity build --fakeroot $CONTAINER Singularity
fi

if [ -z "$CONDA_PREFIX" ]; then
  echo "Activate a conda env or specify \$CONDA_PREFIX"
  exit 1
fi

echo "Starting rstudio service on port $PORT ..."
singularity exec \
	--bind $RSTUDIO_TMP/run:/run \
	--bind $RSTUDIO_TMP/var-lib-rstudio-server:/var/lib/rstudio-server \
	--bind $RSTUDIO_TMP:$RSTUDIO_TMP \
	--bind /sys/fs/cgroup/:/sys/fs/cgroup/:ro \
	--bind ./rstudio-server-conda/singularity/database.conf:/etc/rstudio/database.conf \
	--bind ./rstudio-server-conda/singularity/rsession.conf:/etc/rstudio/rsession.conf \
	--bind ${CONDA_PREFIX}:${CONDA_PREFIX} \
	--bind $HOME/.config/rstudio:/home/rstudio/.config/rstudio \
        `# add additional bind mount required for your use-case` \
	--env CONDA_PREFIX=$CONDA_PREFIX \
	--env RSTUDIO_WHICH_R=$R_BIN \
	--env RETICULATE_PYTHON=$PY_BIN \
	--env PASSWORD=$PASSWORD \
	--env PORT=$PORT \
	--env USER=$USER \
        $CONTAINER ./rstudio-server-conda/singularity/init.sh


