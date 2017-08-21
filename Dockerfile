FROM ubuntu:latest
MAINTAINER Diego Ferigo <diego.ferigo@iit.it>

# Useful tools
RUN apt-get update &&\
    apt-get install -y \
        tree \
        sudo \
        &&\
    rm -rf /var/lib/apt/lists/*

# Dependencies
RUN apt-get update &&\
    apt-get install -y \
        # Jekyll
        ruby \
        ruby-dev \
        make \
        gcc \
        # github-pages dependencies
        nodejs \
        # nokogiri dependencies
        libxml2-dev \
        libxslt-dev \
        pkg-config \
        &&\
    rm -rf /var/lib/apt/lists/*

# Nokogiri doesn't build with its own libraries. Force using system's libraries as workaround
# http://www.nokogiri.org/tutorials/installing_nokogiri.html#using_your_system_libraries
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES=1

RUN gem install \
        jekyll \
        bundler \
        &&\
    gem clean &&\
    jekyll -v

EXPOSE 4000

# Setup an entrypoint script
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

ENV JEKYLL_DIR="/srv/jekyll"
ENV WWW_DIR="/srv/jekyll/www"
WORKDIR $JEKYLL_DIR

ARG USERNAME=jekyll

RUN useradd -m -s /bin/bash $USERNAME &&\
    chown -R $USERNAME:$USERNAME $JEKYLL_DIR &&\
    echo "$USERNAME ALL=NOPASSWD:ALL" >> /etc/sudoers
USER $USERNAME

ENV GEM_HOME /var/lib/gems
RUN sudo chown -R $USERNAME:$USERNAME $GEM_HOME

CMD ["jekyll", "--help"]
