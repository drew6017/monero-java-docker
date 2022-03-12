# build libmonero-java.so
FROM ubuntu:focal AS builder
MAINTAINER drew6017

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt install -yqq --no-install-recommends tzdata openjdk-11-jdk cmake git build-essential nano \
        libjna-java maven g++ make libssl-dev libzmq3-dev libhidapi-dev libudev-dev libusb-1.0-0-dev \
        libfox-1.6-dev libboost-all-dev libunbound-dev libsodium-dev libunwind8-dev liblzma-dev \
        libreadline6-dev libldns-dev libexpat1-dev libpgm-dev qttools5-dev-tools libhidapi-dev \
        libusb-1.0-0-dev libprotobuf-dev protobuf-compiler libudev-dev libboost-chrono-dev \
        libboost-date-time-dev libboost-filesystem-dev libboost-locale-dev libboost-program-options-dev \
        libboost-regex-dev libboost-serialization-dev libboost-system-dev libboost-thread-dev ccache  \
        doxygen graphviz pkg-config && \
    apt autoremove -yqq --purge

ENV JAVA_HOME='/usr/lib/jvm/java-11-openjdk-amd64'
RUN echo "export JAVA_HOME=\"${JAVA_HOME}\"" >> ~/.bashrc

WORKDIR /monerojd
RUN git clone https://github.com/monero-ecosystem/monero-java --recursive && \
    cd monero-java && \
    git checkout v0.6.4 && \
    mvn install && \
    ./bin/update_submodules.sh

WORKDIR ./monero-java
RUN cd external/monero-cpp/external/monero-project && \
    sed -i 's/Build GUI dependencies." OFF/Build GUI dependencies." ON/' CMakeLists.txt && \
    make release-static -j12 && make release-static -j12

RUN ./bin/build_libmonero_java.sh

FROM ubuntu:focal
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt install -yqq --no-install-recommends tzdata openjdk-11-jdk git nano && \
    apt autoremove -yqq --purge
ENV JAVA_HOME='/usr/lib/jvm/java-11-openjdk-amd64'
RUN echo "export JAVA_HOME=\"${JAVA_HOME}\"" >> ~/.bashrc

# install monero runtime-depends
RUN apt install -yqq --no-install-recommends libhidapi-dev libusb-1.0-0-dev libprotobuf-dev \
        protobuf-compiler libudev-dev libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev \
        libboost-locale-dev libboost-program-options-dev libboost-regex-dev libboost-serialization-dev \
        libboost-system-dev libboost-thread-dev libssl-dev libzmq3-dev libhidapi-dev libudev-dev libusb-1.0-0-dev \
        libfox-1.6-dev libboost-all-dev libunbound-dev libsodium-dev libunwind8-dev liblzma-dev libreadline6-dev \
        libldns-dev libexpat1-dev libpgm-dev libjna-java

COPY --from=builder /monerojd/monero-java/build/libmonero-java.so /usr/lib/x86_64-linux-gnu/libmonero-java.so
COPY --from=builder /monerojd/monero-java/build/libmonero-cpp.so /usr/lib/x86_64-linux-gnu/libmonero-cpp.so
