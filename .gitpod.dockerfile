FROM swift

ENV VERSION 0.50500.0  # replace this with the version you need

# RUN git clone --depth 1 https://github.com/apple/swift-format.git
# WORKDIR swift-format
# RUN git checkout tags/0.50500.0
# RUN swift build -c release
# RUN cp ./.build/release/swift-format /usr/bin/swift-format

RUN apt-get update && apt-get install -y \
    sqlite3 \
    libsqlite3-dev \
    curl
    
USER gitpod