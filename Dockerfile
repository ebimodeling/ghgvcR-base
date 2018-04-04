# our R base image
FROM r-base

# Application code goes in /app, the data in /app/data, and our R libraries
# will be installed in the default R location (after we chown the folder)
ENV APP_PATH=/app \
  DATA_PATH=/app/data \
  USER=ghgvcr-user \
  HOME=/home/ghgvcr-user \
  R_LIBS_USER=/usr/local/lib/R/site-library

# Update the image & install required system libraries
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  libnetcdf-dev libxml2 libxml2-dev libssl-dev curl unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home $USER

# Put the R app in /app and the data (map files) in /app/data. The R library
# files are installed, by default, in the path noted below.
#
# We'll mount both fo these in the docker-compose.yml & Dockerrun.aws.json
RUN mkdir -p $APP_PATH $DATA_PATH && chown -R $USER:$USER $APP_PATH $DATA_PATH $R_LIBS_USER

# Switch to the user, so we don't install everything as root
USER $USER

# Set up the default repo in your Rprofile file. We're pulling everything
# from the default cran repo for now
RUN echo "local({\n\tr <- getOption(\"repos\")\n\tr[\"CRAN\"] <- \"http://cran.us.r-project.org/\"\n\toptions(repos = r)\n})" > /home/$USER/.Rprofile

WORKDIR $APP_PATH

# Default R folder for storing libs is /usr/local/lib/R/site-library.
# We should map this in docker-compose.yml and Dockerrun.aws.json
#
# Some of these packages would ideally not exist in the "production" image
# snapshot because they're development tools. However, the build time on these
# is enough to make local development and testing cycles slower so I'm keeping
# these in the base for now.
RUN Rscript -e "install.packages(c('devtools', 'ggplot2', 'gridExtra', 'Hmisc', 'jsonlite', 'scales', 'tidyr', 'ncdf4', 'Rserve', 'XML', 'testthat', 'readr', 'rmarkdown', 'roxygen2'))"

LABEL org.ebimodeling.maintainer="Jay Dorsey"
