### Repo cloned from https://github.com/grst/rstudio-server-conda and adjusted for easier use with singularity


# Running Rstudio Server in a Conda Environment

I usually rely on the [conda package manager](https://docs.conda.io/en/latest/) to manage my environments during development. Thanks to [conda-forge](https://conda-forge.org/) and [bioconda](https://bioconda.github.io/) most R packages are now also available through conda. For production,
I [convert them to containers](https://github.com/grst/containerize-conda) as these are easier to share. 

Unfortunately, there seems to be [no straightforward way](https://community.rstudio.com/t/start-rstudio-server-session-in-conda-environment/12516/15) to use conda envs in Rstudio server. This repository provides three approaches to make rstudio server work with conda envs. 

 * [Running Rstudio Server in a Singularity Container](#running-rstudio-server-with-singularity)
 * [Running Rstudio Server in a Docker/Podman Container](#running-rstudio-server-with-podmandocker)
 * [Running Rstudio Server locally](#running-locally)

## Running Rstudio Server with Singularity

With this approach Rstudio Server runs in a Singularity container (any based on [rocker/rstudio](https://hub.docker.com/r/rocker/rstudio)).  
The conda environment gets mounted into the container - like that there's no need to rebuild the container to add a package and 
`install.packages` can be used without issues. The container-based approach has the following benefits: 

 * Authentication works ([#3](https://github.com/grst/rstudio-server-conda/issues/3))
 * Several separate instances of Rstudio server can run in parallel, even without the *Pro* version.
 * R version can easily be switched by mounting different conda environment.

### Prerequisites

 * [Singularity](https://sylabs.io/guides/3.0/user-guide/quick_start.html)
 * [conda](https://docs.conda.io/en/latest/miniconda.html) or [mamba](https://github.com/conda-forge/miniforge#mambaforge)


### Usage

 1. Clone this repository
    
 2. Activate the target conda env or set the environment variable `CONDA_PREFIX`
    to point to the location of the conda env. 
    
 3. Check the '/singularity/init.sh' script. You need to adjust the path to miniconda.

 4. Check the `run_singularity.sh` script. In particular, you may need to add additional bind mounts 
    (e.g. a global data directory), add path to your favorite container, add path to your favority conda prefix.
 
 5. Execute the `run_singularity.sh` script. It will automatically build the container if it is not available. 
 
    ```bash    
    PORT=8585 PASSWORD=rstudio CONDA_PREFIX="./my_Tools/myPY/envs/r43_env"  CONTAINER="./tidyverse_latest.sif"  ./singularity/run_singularity.sh
    ```
    
 6. Open a tunnel to the compute server running the container

    ```bash    
    ssh -N -L 8585:{node}:8585 {user}@hpc-login
    ```
 7. Log into Rstudio

     * open rstudio server at `http://localhost:8585` (or whatever port you specified)
     * login with your default username and the password you specified via the `PASSWORD` environment variable. 
     * Sometimes, running multiple sessions from the same IP adress using the same browser can result in different sessions using the same secure-cookie-key. This causes sessions to disconnect and converge into 1 session. A work-around is using Firefox container tabs; https://support.mozilla.org/en-US/kb/how-use-firefox-containers. Follow the description in the link and assign each session to its own container. Now you should be able to run multiple rstudio sessions simultaneously without sessions interfering with each other.

