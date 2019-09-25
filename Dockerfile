FROM lsiobase/alpine:3.10

LABEL maintainer="xthursdayx"

ARG APP_DIR="/usr/src/app"
ARG FERDI_RELEASE

ENV NODE_VERSION=10.16.3 
ENV NPM_VERSION=6 
ENV YARN_VERSION=1.17.3
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# install packages
RUN \
  echo "**** installing build packages ****" && \
  apk add --no-cache \
   libstdc++ \
   nano && \
  apk add --no-cache --virtual .build-deps \
   binutils-gold \
   curl \
   gnupg \
   gcc \
   g++ \
   linux-headers \
   make \
   memcached \
   python && \
  echo "**** downloading keys ****" && \
  # gpg keys listed at https://github.com/nodejs/node#release-keys
  for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
    B9E2F5981AA6E0CD28160D9FF13993A75599653C \
  ; do \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done && \
  echo "**** installing node ****" && \
  curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" && \
  curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" && \
  gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc && \
  grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - && \
  tar -xf "node-v$NODE_VERSION.tar.xz" && \
  cd "node-v$NODE_VERSION" && \
  ./configure --prefix=/usr && \
  make -j$(getconf _NPROCESSORS_ONLN) V= && \
  make install && \
  apk del .build-deps && \
  cd / && \
  rm -Rf "node-v$NODE_VERSION" && \
  rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt
  
RUN \
  apk add --no-cache --virtual .build-deps-yarn \
  curl \
  gnupg \
  tar && \
  echo "**** installing npm and yarn ****" && \
  npm install -g npm@${NPM_VERSION} && \
  find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf && \
  for key in \
      6A010C5166006599AA17F08146C2130DFD2497F5 \
    ; do \
      gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
      gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
      gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
    done && \
  curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" && \
  curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" && \
  gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz && \
  mkdir -p /usr/local/share/yarn && \
  tar -xzf yarn-v$YARN_VERSION.tar.gz -C /usr/local/share/yarn --strip 1 && \
  ln -s /usr/local/share/yarn/bin/yarn /usr/local/bin/ && \
  ln -s /usr/local/share/yarn/bin/yarnpkg /usr/local/bin/ && \
  echo "**** install ferdi server ****" && \
  mkdir -p /ferdi && \
  curl -o /ferdi/ferdi.tar.gz -L "https://github.com/getferdi/server/archive/master.tar.gz" && \
  echo "**** cleanup ****" && \
  apk del .build-deps-yarn && \
  rm -rf \
   yarn-v${YARN_VERSION}.tar.gz* \
   ${RM_DIRS} \
   /node-${NODE_VERSION}* \
   /SHASUMS256.txt \
   /tmp/* \
   /var/cache/apk/* \
   /usr/share/man/* \
   /usr/share/doc \
   /root/.npm \
   /root/.node-gyp \
   /root/.config \
   /usr/lib/node_modules/npm/man \
   /usr/lib/node_modules/npm/doc \
   /usr/lib/node_modules/npm/html \
   /usr/lib/node_modules/npm/scripts
  
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config