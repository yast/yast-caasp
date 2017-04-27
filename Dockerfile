FROM yastdevel/ruby:caasp-1_0
RUN zypper --gpg-auto-import-keys --non-interactive in --no-recommends \
  yast2-ntp-client
COPY . /usr/src/app
