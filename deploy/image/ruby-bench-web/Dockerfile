FROM samsaffron/discourse_base_22:1.0.0
MAINTAINER Alan Guo Xiang Tan "https://twitter.com/tgx_world"

RUN sudo apt-get update && sudo apt-get install -y qt5-default libqt5webkit5-dev

RUN useradd rubybench -s /bin/bash -m -U &&\
    mkdir -p /var/www && cd /var/www &&\
      git clone https://github.com/ruby-bench/ruby-bench-web.git &&\
      cd ruby-bench-web &&\
        git config --global user.name "rubybench" &&\
        git config --global user.email "https://twitter.com/tgx_world" &&\
        git remote set-branches --add origin production &&\
    chown -R rubybench:rubybench /var/www/ruby-bench-web &&\
    mkdir -p /shared/gems && chown -R rubybench /shared/gems && \
    cd /var/www/ruby-bench-web &&\
      sudo -u rubybench bundle install --deployment \
      --without test:development --path=/shared/gems
