[![Build Status](https://travis-ci.org/ruby-bench/ruby-bench-web.svg?branch=master)](https://travis-ci.org/ruby-bench/ruby-bench-web)

https://rubybench.org

# Introduction

RubyBench was born out from
[Sam Saffron's call](http://samsaffron.com/archive/2013/12/11/call-to-action-long-running-ruby-benchmark) for a long running Ruby benchmark.

# Benchmark Scripts

Ruby Scripts: https://github.com/ruby/ruby/tree/trunk/benchmark

Discourse Scripts: https://github.com/discourse/discourse/tree/master/script

The scripts are executed in a bare metal server using Docker containers to ensure
consistent results. To view how the scripts are executed, head over to
https://github.com/ruby-bench/ruby-bench-docker.

# Hardware

Our current bare metal server is sponsored by the team over at
[RubyTune.com](https://rubytune.com/).

All benchmarks are run on a bare metal server in order to achieve
consistent and repeatable results. We **will not** publish CPU results gathered
on virtual hosts where we can not control our CPU allocation. The only results
published are run on production level bare metal servers.

The bare metal server is purchased from
[Hetzner Online](http://www.hetzner.de/en/hosting/produkte_rootserver/px60ssd)
and has the following configurations:

System | Type Component
--- | ---
Operating System | Ubuntu-1404-trusty-64-minimal
RAM | 4 x 8GB Micron ECC, Part Number: 18KSF1G72AZ-1G6E1
Processor | 3.6GHz Intel® Xeon® E3-1270 v3 Quad-Core Haswell incl. Hyper-Threading Technology
Hard Drive | 2 x Samsung SSD 845DC EVO - 240 GB - 2,5" SATA III
Motherboard | Intel Coporation S1200RP

# Contribute

## Dependencies
- PostgreSQL 9.x in order to enable the hstore extension.
- Redis
- PhantomJS

## Setup
```bash
redis-server

# Make sure that the current user has a Postgres account 
# If not run : sudo -u postgres createuser <username> -s
bundle exec rake db:setup

unicorn -c config/unicorn.rb
```

## Testing

#### Install [PhantomJS](http://phantomjs.org/)

Note: you can use directory other than `$HOME`

```
wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 -O $HOME/phantomjs/phantomjs-2.1.1-linux-x86_64.tar.bz2

tar -xvf $HOME/phantomjs/phantomjs-2.1.1-linux-x86_64.tar.bz2 -C $HOME/phantomjs

export PATH=$HOME/phantomjs/phantomjs-2.1.1-linux-x86_64/bin:$PATH


# Check version installed

phantomjs -v
```
#### Start redis server if you haven't already
```
redis-server
```
#### Run tests
```
bundle exec rake test
```

## Discussion
Discuss features and direction of project: http://community.rubybench.org

## Operations
This section describes how to operate the server hosting this application.

### Run ruby benchmarks manually

Use Admin Console:

https://rubybench.org/admin/repos/ruby

Pattern: "all" is replaced with "", and any other string can filter benchmarks.

### Run rails console

```bash
docker exec -it [container-id] sudo -E -u rubybench bundle exec rails c
```

### Dump and load database

```bash
docker exec -it [container-id] sudo -E -u postgres bash -c "pg_dump rubybench_production > /tmp/dump.sql"
docker cp [container-id]:/tmp/dump.sql /tmp/dump.sql
zip /tmp/dump.zip /tmp/dump.sql
```

```bash
scp ruby-bench-server:/tmp/dump.zip /tmp/dump.zip
unzip /tmp/dump.zip -d /
bundle exec rake db:drop db:create RAILS_ENV=development DISABLE_DATABASE_ENVIRONMENT_CHECK=1
cat /tmp/dump.sql | psql -U rubybench ruby-bench-web_development
```
