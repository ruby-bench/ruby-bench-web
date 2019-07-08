require 'test_helper'

class UserBenchTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def err(key, *args)
    I18n.t("user_scripts.errors.#{key}", *args)
  end

  def new_bench(name = nil, url = nil, sha = nil, sha2 = nil)
    UserBench.new(name, url, sha, sha2)
  end

  def valid_name
    'valid_name'
  end

  def valid_url(ext = 'rb')
    "https://raw.githubusercontent.com/ruby/ruby/master/benchmark/irb_color.#{ext}"
  end

  def valid_ruby
    <<~RUBY
      def msdasd
        puts 54544
      end
    RUBY
  end
  test '#validate! @name presence, uniqueness and allowed characters' do
    bench = new_bench('')
    bench.validate!
    assert_includes bench.errors, err('missing_name')

    BenchmarkType.create!(
      category: 'taken_name',
      script_url: valid_url,
      repo_id: 77
    )

    Net::HTTP.stubs(:get).returns(valid_ruby)
    bench = new_bench('taken_name', valid_url, 'asdasd')
    bench.validate!
    assert_includes bench.errors, err('name_already_taken', names: 'taken_name')

    bench = new_bench('/invalid name', valid_url, 'dads')
    bench.validate!
    assert_includes bench.errors, err('unallowed_characters', name: '/invalid name')
  end

  test '#validate! @url presence and format' do
    bench = new_bench(valid_name, '')
    bench.validate!
    assert_includes bench.errors, err('missing_url')

    bench = new_bench(valid_name, 'http:\\\\malformed;;', 'dasd')
    bench.validate!
    assert_includes bench.errors, err('bad_url')
  end

  test '#validate! @sha presence and existence on github' do
    bench = new_bench(valid_name, valid_url, '')
    bench.validate!
    assert_includes bench.errors, err('missing_sha')

    bench = new_bench(valid_name, valid_url, 'doesntexist')
    Net::HTTP.stubs(:get).returns(valid_ruby)
    VCR.use_cassette('github ruby doesntexist') do
      bench.validate!
    end
    assert_includes bench.errors, err('bad_sha', sha: 'doesntexist')
  end

  test '#validate! when everything is valid' do
    bench = new_bench(valid_name, valid_url, '6ffef8d459')
    Net::HTTP.stubs(:get).returns(valid_ruby)
    VCR.use_cassette('github ruby 6ffef8d459') do
      bench.validate!
    end
    assert bench.valid?
    assert_equal bench.commits.size, 1
    assert_equal bench.commits.first.sha, '6ffef8d459e6423bf4fe35cccb24345bad862448'
  end

  test "#validate! @sha2 existence on github only if it's given" do
    bench = new_bench(valid_name, valid_url, '6ffef8d459', 'doesntexist')
    Net::HTTP.stubs(:get).returns(valid_ruby)
    VCR.use_cassette('github ruby 6ffef8d459') do
      VCR.use_cassette('github ruby doesntexist') do
        bench.validate!
      end
    end
    assert_includes bench.errors, err('bad_sha', sha: 'doesntexist')
  end

  test '#validate! allows 2 shas' do
    bench = new_bench(valid_name, valid_url, '6ffef8d459', 'fe0ddf0e58')
    Net::HTTP.stubs(:get).returns(valid_ruby)
    VCR.use_cassette('github ruby 6ffef8d459') do
      VCR.use_cassette('github ruby fe0ddf0e58') do
        bench.validate!
      end
    end
    assert bench.valid?
    assert_equal bench.commits.size, 2
    assert_equal bench.commits.map(&:sha), %w{fe0ddf0e58e65ab3ae3d6e73382c3bebcd4541e5 6ffef8d459e6423bf4fe35cccb24345bad862448}

    first_commit_date = bench.commits.first.commit.committer.date
    second_commit_date = bench.commits.second.commit.committer.date
    assert first_commit_date < second_commit_date
  end

  test '#validate! yaml file and benchmark names inside of it are validated' do
    yaml = <<~YAML
      prelude: |
        str1 = [*"a".."z",*"0".."9"].join("")
        str10 = str1 * 10
        str100 = str10 * 10
        str1000 = str100 * 10
      benchmark:
        upcase-1: str1.upcase
        upcase-10: str10.upcase
        upcase-100: str100.upcase
        upcase-1000: str1000.upcase
    YAML
    Net::HTTP.stubs(:get).returns(yaml)
    bench = new_bench(valid_name, valid_url('yml'), '6ffef8d459')
    VCR.use_cassette('github ruby 6ffef8d459') do
      bench.validate!
    end
    expected = %w{upcase-1 upcase-10 upcase-100 upcase-1000}
    assert bench.valid?
    assert_equal bench.names.size, expected.size
    expected.each { |e| assert_includes bench.names, e }
  end

  test '#validate! yaml syntax and benchmark-driver format' do
    yaml = <<~YAML
      prelude: |
        str1 = [*"a".."z",*"0".."9"].join("")
        str10 = str1 * 10
        str100 = str10 * 10
        str1000 = str100 * 10
    YAML
    Net::HTTP.stubs(:get).returns(yaml)
    bench = new_bench(valid_name, valid_url('yml'), '6ffef8d459')
    VCR.use_cassette('github ruby 6ffef8d459') do
      bench.validate!
    end
    assert_not bench.valid?
    assert_includes bench.errors, err('yaml_file_without_benchmarks')

    yaml = 'asddsf: weads:'
    Net::HTTP.stubs(:get).returns(yaml)
    bench = new_bench(valid_name, valid_url('yml'), '6ffef8d459')
    VCR.use_cassette('github ruby 6ffef8d459') do
      bench.validate!
    end
    assert_not bench.valid?
    assert_includes bench.errors, err('invalid_yaml')
  end

  test '#validate! ruby code' do
    bad_ruby = <<~RUBY
      def txxsr(
        [1,2,].each do
    RUBY
    Net::HTTP.stubs(:get).returns(bad_ruby)
    bench = new_bench(valid_name, valid_url, '6ffef8d459')
    VCR.use_cassette('github ruby 6ffef8d459') do
      bench.validate!
    end
    assert_not bench.valid?
    assert_includes bench.errors.map(&:strip), err('invalid_ruby_code', lines: bad_ruby).strip
  end
end
