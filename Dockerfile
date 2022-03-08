FROM rocker/r-ver:4.1.2
RUN apt-get update && apt-get install -y  libcurl4-openssl-dev libpng-dev libssl-dev make zlib1g-dev fonts-roboto fonts-roboto-fontface libfontconfig1-dev libcairo2-dev libxt6 && rm -rf /var/lib/apt/lists/*
RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" >> /usr/local/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
RUN Rscript -e 'remotes::install_version("magrittr",upgrade="never", version = "2.0.2")'
RUN Rscript -e 'remotes::install_version("tibble",upgrade="never", version = "3.1.6")'
RUN Rscript -e 'remotes::install_version("dplyr",upgrade="never", version = "1.0.8")'
RUN Rscript -e 'remotes::install_version("readxl",upgrade="never", version = "1.3.1")'
RUN Rscript -e 'remotes::install_version("svglite",upgrade="never", version = "2.0.0")'
RUN Rscript -e 'remotes::install_version("extrafont",upgrade="never", version = "0.17")'
RUN Rscript -e 'remotes::install_version("googlesheets4",upgrade="never", version = "1.0.0")'
RUN Rscript -e 'remotes::install_version("DT",upgrade="never", version = "0.21")'
RUN Rscript -e 'remotes::install_version("shiny",upgrade="never", version = "1.7.1")'
RUN Rscript -e 'remotes::install_version("tidyr",upgrade="never", version = "1.2.0")'
RUN Rscript -e 'remotes::install_version("lubridate",upgrade="never", version = "1.8.0")'
RUN Rscript -e 'remotes::install_version("wesanderson",upgrade="never", version = "0.3.6")'
RUN Rscript -e 'remotes::install_version("zoo",upgrade="never", version = "1.8-9")'
RUN Rscript -e 'remotes::install_version("readr",upgrade="never", version = "2.1.2")'
RUN Rscript -e 'remotes::install_version("ggplot2",upgrade="never", version = "3.3.5")'
RUN R -e 'extrafont::font_import(prompt=FALSE)'
RUN R -e 'extrafont::loadfonts()'
RUN mkdir /build_zone
ADD . /build_zone
WORKDIR /build_zone
RUN R -e 'remotes::install_local(upgrade="never")'
RUN rm -rf /build_zone
EXPOSE 80
CMD R -e "options('shiny.port'=80,shiny.host='0.0.0.0');ganttrify::shiny_ganttrify()"
