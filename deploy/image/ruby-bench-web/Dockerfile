FROM discourse/base:2.0.20201214-2041
MAINTAINER Alan Guo Xiang Tan "https://twitter.com/tgx_world"

RUN sudo apt-get update && sudo apt-get install -y qt5-default libqt5webkit5-dev python-pygments netcat

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile && \
    echo 'eval "$(rbenv init -)"' >> ~/.bash_profile && \
    . ~/.bash_profile && \
    mkdir -p "$(rbenv root)"/plugins && \
    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

RUN /bin/bash -l -c "rbenv install 2.7.2" && \
    /bin/bash -l -c "rbenv global 2.7.2"

RUN useradd rubybench -s /bin/bash -m -U && \
    mkdir -p /var/www && cd /var/www && \
      git clone https://github.com/ruby-bench/ruby-bench-web.git && \
      cd ruby-bench-web && \
        git config --global user.name "rubybench" && \
        git config --global user.email "https://twitter.com/tgx_world" && \
        git remote set-branches --add origin production && \
        chown -R rubybench:rubybench /var/www/ruby-bench-web

RUN cd /var/www/ruby-bench-web && \
    sudo -u rubybench bundle install --deployment --without test:development --path=vendor/bundle

WORKDIR /var/www/ruby-bench-web
