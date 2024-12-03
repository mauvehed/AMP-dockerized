FROM debian:12-slim

# Set default environment variables
ENV UID=1000
ENV GID=1000
ENV TZ=Etc/UTC
ENV PORT=8080
ENV USERNAME=admin
ENV PASSWORD=password
ENV IPBINDING=0.0.0.0

ENV AMP_AUTO_UPDATE=true
ENV AMP_LICENCE=notset
ENV AMP_MODULE=ADS
ENV AMP_RELEASE_STREAM=Mainline
ENV AMP_SUPPORT_LEVEL=UNSUPPORTED
ENV AMP_SUPPORT_TOKEN=AST0/MTAD
ENV AMP_SUPPORT_TAGS="nosupport docker community unofficial unraid"
ENV AMP_SUPPORT_URL="https://github.com/MitchTalmadge/AMP-dockerized/"
ENV LD_LIBRARY_PATH="./:/opt/cubecoders/amp/:/AMP/"

ARG DEBIAN_FRONTEND=noninteractive

# Update and install base dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-transport-https \
    jq \
    sed \
    tzdata \
    wget \
    gnupg \
    locales && \
    apt-get -y clean && \
    apt-get -y autoremove --purge && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Configure locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install Mono
RUN apt-get update && \
    apt-get install -y \
    dirmngr \
    ca-certificates \
    gnupg && \
    mkdir -p /root/.gnupg && chmod 700 /root/.gnupg && \
    gpg --homedir /root/.gnupg --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/debian stable-buster main" | tee /etc/apt/sources.list.d/mono-official-stable.list && \
    apt-get update && \
    apt-get install -y mono-devel && \
    apt-get -y clean && \
    apt-get -y autoremove --purge && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Install AMP dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    bzip2 \
    coreutils \
    curl \
    gdb \
    git \
    git-lfs \
    gnupg \
    iputils-ping \
    libc++-dev \
    libc6 \
    libatomic1 \
    libgdiplus \
    liblua5.3-0 \
    libpulse-dev \
    libsqlite3-0 \
    libzstd1 \
    locales \
    numactl \
    procps \
    software-properties-common \
    socat \
    tmux \
    unzip \
    xz-utils \
    lib32gcc-s1 \
    lib32stdc++6 \
    lib32z1 \
    libbz2-1.0 \
    libcurl4 \
    libncurses5 \
    libsdl2-2.0-0 \
    libtinfo5 && \
    apt-get -y clean && \
    apt-get -y autoremove --purge && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Install Adoptium JDK
RUN curl -fsSL https://api.adoptium.net/v3/binary/latest/8/ga/linux/x64/jdk/hotspot/normal/eclipse -o /tmp/temurin-8.tar.gz && \
    tar -xzf /tmp/temurin-8.tar.gz -C /opt && \
    rm /tmp/temurin-8.tar.gz && \
    ln -s /opt/jdk*/bin/* /usr/local/bin/

# Add CubeCoders repository and install AMP manager
RUN wget -qO - https://repo.cubecoders.com/archive.key | gpg --dearmor > /etc/apt/trusted.gpg.d/cubecoders-archive-keyring.gpg && \
    echo "deb https://repo.cubecoders.com/ debian/" | tee /etc/apt/sources.list.d/cubecoders.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends --download-only ampinstmgr && \
    mkdir -p /tmp/ampinstmgr && \
    dpkg-deb -x /var/cache/apt/archives/ampinstmgr_*.deb /tmp/ampinstmgr && \
    mv /tmp/ampinstmgr/opt/cubecoders/amp/ampinstmgr /usr/local/bin/ampinstmgr && \
    apt-get -y clean && \
    apt-get -y autoremove --purge && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Set up entrypoint
COPY entrypoint /opt/entrypoint
RUN chmod -R +x /opt/entrypoint

VOLUME ["/home/amp/.ampdata"]

ENTRYPOINT ["/opt/entrypoint/main.sh"]

