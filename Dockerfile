### IMPORTANT NOTE:
###
### This Dockerfile builds the Docker image for the MadMiner "heavy-weight" environment.
### The "heavy-weight" environment provides a working installation of MadGraph 5
### and all the necessary sub-dependencies to run Physics dependent steps:
### - pythia8
### - Delphes
###
### Please consider, that even if this Dockerfile definition is extremely similar as the one
### used for the "madminer-workflow-ph" Docker image, it is better not to depend on it,
### given that the common sections between the two will be moved to a MadMiner provided
### "heavy" version image soon enough.
###
### Check: https://github.com/diana-hep/madminer/issues/421


#### Base image
#### Reference: https://github.com/diana-hep/madminer/blob/master/Dockerfile
FROM madminertool/docker-madminer:latest


#### Install binary dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    rsync \
    ca-certificates \
    gfortran \
    build-essential \
    ghostscript \
    libboost-all-dev


#### Define working folders
ENV PROJECT_FOLDER "/madminer"
ENV SOFTWARE_FOLDER "/madminer/software"


#### Install MadGraph 5
WORKDIR ${SOFTWARE_FOLDER}

ENV MG_VERSION "MG5_aMC_v2.9.3"
ENV MG_FOLDER "MG5_aMC_v2_9_3"
ENV MG_BINARY "MG5_aMC_v2_9_3/bin/mg5_aMC"
RUN curl -sSL "https://launchpad.net/mg5amcnlo/2.0/2.9.x/+download/${MG_VERSION}.tar.gz" | tar -xzv

# ROOT environment variables
ENV ROOTSYS /usr/local
ENV PATH $PATH:$ROOTSYS/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$ROOTSYS/lib
ENV DYLD_LIBRARY_PATH $DYLD_LIBRARY_PATH:$ROOTSYS/lib

# Skip the auto-update on the first execution
RUN echo "n" | python3 ${SOFTWARE_FOLDER}/${MG_BINARY}
RUN echo "install pythia8" | python3 ${SOFTWARE_FOLDER}/${MG_BINARY}
RUN echo "install Delphes" | python3 ${SOFTWARE_FOLDER}/${MG_BINARY}
RUN echo "import model EWdim6-full" | python3 ${SOFTWARE_FOLDER}/${MG_BINARY}

# Delphes environment variables
ENV ROOT_INCLUDE_PATH $ROOT_INCLUDE_PATH:${SOFTWARE_FOLDER}/${MG_FOLDER}/Delphes/external


#### Set working directory
WORKDIR ${PROJECT_FOLDER}

#### Copy files
COPY requirements.txt ./


# Install Python2 dependencies (Numpy f2py binary)
RUN python2 -m pip install --no-cache-dir numpy

# Install Python3 dependencies
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir --requirement requirements.txt
