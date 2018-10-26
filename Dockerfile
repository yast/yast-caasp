FROM yastdevel/ruby:sle15
RUN zypper --non-interactive in --no-recommends \
  yast2-ntp-client
COPY . /usr/src/app
