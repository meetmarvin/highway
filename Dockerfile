FROM debian

RUN apt update && apt upgrade -y

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt install -y postgresql ruby git libpq-dev build-essential patch ruby-dev zlib1g-dev liblzma-dev libssl-dev sudo

RUN gem update --system && gem install bundler

WORKDIR /root/

COPY "highway.tar.gz" /

RUN tar -xf /highway.tar.gz

WORKDIR /root/highway/

RUN bundle install

COPY "start.sh" /

ENTRYPOINT ["/start.sh"]
