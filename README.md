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

## Dependency
PostgreSQL 9.x in order to enable the hstore extension.

Redis

## Setup
```bash
bundle exec rake db:create
bundle exec rake db:setup
redis-server
unicorn -c config/unicorn.rb
```

## Testing
```
redis-server
bundle exec rake test
```

## Discussion
Discuss features and direction of project: http://community.rubybench.org
