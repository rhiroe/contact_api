FROM ubuntu:mantic AS neologd
RUN apt update && \
    apt install -y git \
                   make \
                   curl \
                   xz-utils \
                   file \
                   sudo \
                   mecab \
                   libmecab-dev
RUN git clone https://github.com/neologd/mecab-ipadic-neologd.git && \
    mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -n -a -y

FROM ubuntu:mantic AS data
RUN wget https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.jp.300.bin.gz

FROM ruby:3.2 AS bundle
COPY Gemfile Gemfile
RUN bundle install

FROM ruby:3.2
RUN apt update && apt install -y mecab
COPY --from=neologd /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd
COPY --from=bundle /usr/local/bundle /usr/local/bundle
RUN sed -i '/dicdir/c dicdir = /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd' /etc/mecabrc
WORKDIR /app
