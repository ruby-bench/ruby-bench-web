![Build Status](https://api.travis-ci.org/ruby-bench/ruby-bench-web.svg?branch=master)

http://rubybench.org

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

All benchmarks are ran on a Softlayer bare metal server in order to achieve consistent results. The bare metal server has the following configurations:

System | Type Component
--- | ---
Operating System | Ubuntu14.04-64 Minimal for Bare Metal
RAM 4x4GB Kingston | 4GB DDR3 1Rx8
Processor | 3GHz Intel Xeon-IvyBridge (E5-2690-V2-DecaCore)
Motherboard | SuperMicro X9DRI-LN4F+_R1.2A
Drive Controller | Mainboard Onboard
Power Supply | SuperMicro PWS-605P-1H
Security Device | SuperMicro AOM-TPM-9655V
Remote Management Card | SuperMicro Winbond WPCM450 - Onboard
Backplane | SuperMicro BPN-SAS-815TQ

# Contribute
List of things we need to do: https://trello.com/b/mdMX7CeK/todo
Discuss features and direction of project: http://community.rubybench.org
