FROM discourse/base:1.3.5
MAINTAINER Alan Guo Xiang Tan "https://twitter.com/tgx_world"

RUN sudo apt-get update && sudo apt-get install -y qt5-default libqt5webkit5-dev python-pygments

RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv && \
    git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build && \
    ./root/.rbenv/plugins/ruby-build/install.sh

ENV PATH /root/.rbenv/bin:$PATH

RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh && \
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc

RUN /bin/bash -l -c "rbenv install 2.3.0" && \
    /bin/bash -l -c "rbenv global 2.3.0"

RUN useradd rubybench -s /bin/bash -m -U && \
    mkdir -p /var/www && cd /var/www && \
      git clone https://github.com/ruby-bench/ruby-bench-web.git && \
      cd ruby-bench-web && \
        git config --global user.name "rubybench" && \
        git config --global user.email "https://twitter.com/tgx_world" && \
        git remote set-branches --add origin production && \
        chown -R rubybench:rubybench /var/www/ruby-bench-web && \
        cp config/database.yml.example config/database.yml

RUN mkdir -p /shared/gems && chown -R rubybench /shared/gems && \
      cd /var/www/ruby-bench-web && \
      sudo -u rubybench bundle install --deployment --without test:development --path=/shared/gems

WORKDIR /var/www/ruby-bench-web
