FROM elementary/docker:loki


ENV DEBIAN_FRONTEND=noninteractive \
    LANG=ja_JP.UTF-8 \
    LC_ALL=${LANG} \
    LANGUAGE=${LANG} \
    TZ=Asia/Tokyo

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Install packages
RUN apt-get update && \
    # Install the required packages for desktop    
    apt-get install -y \
      supervisor \
      xvfb \
      xfce4 \
      x11vnc \
      && \
    # Install utilities(optional).
    apt-get install -y \
      wget \
      curl \
      sudo \
      net-tools \
      vim-tiny \
      xfce4-terminal \
      iputils-ping \
      firefox \
      git \
      default-jre \
      default-jdk \
      && \
    # Install japanese language packs(optional)
    apt-get install -y \
      language-pack-ja-base language-pack-ja \
      ibus-anthy \
      fonts-takao 

# Install noVNC
RUN mkdir -p /opt/noVNC/utils/websockify && \
    wget -qO- "http://github.com/novnc/noVNC/tarball/master" | tar -zx --strip-components=1 -C /opt/noVNC && \
    wget -qO- "https://github.com/novnc/websockify/tarball/master" | tar -zx --strip-components=1 -C /opt/noVNC/utils/websockify && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# DownLoad and install Scala
RUN \
 mkdir -p /scaladev/ \
 && wget "https://downloads.lightbend.com/scala/2.12.2/scala-2.12.2.deb" -O /tmp/scala-2.12.2.deb \
 && apt-get install -y /tmp/scala-2.12.2.deb \
 && rm -rf /tmp/scala-2.12.2.deb

# DownLoad and install Go
RUN \
 mkdir -p /godev/ \
 && mkdir -p /usr/src/go \
 && mkdir -p /usr/src/go-third-party \
 && wget -qO- "https://dl.google.com/go/go1.10.1.linux-amd64.tar.gz" | tar -zx --strip-components=1 -C /usr/src/go/

# DownLoad and install Vim
RUN \
 apt-get install -y software-properties-common python-software-properties \
 && add-apt-repository ppa:jonathonf/vim \
 && apt-get update -y \
 && apt-get install -y vim \

# DownLoad and install Powerlice fonts
RUN \
 wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py \
 && pip install powerline-status \
 && git clone https://github.com/powerline/fonts.git && cd fonts && sh ./install.sh
 
# Installer Clean up
RUN \
 apt-get clean && \
 rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Rename user directories Japanese to English.
RUN LANG=C xdg-user-dirs-update --force

ADD startup.sh /opt/startup.sh
ADD .env /opt/.env

EXPOSE 8080
COPY supervisord/* /etc/supervisor/conf.d/
ENTRYPOINT ["/opt/startup.sh"]
