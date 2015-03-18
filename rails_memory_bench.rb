require "net/http"

def start_server
  # Remove the X to enable the parameters for tuning.
  # These are the default values as of Ruby 2.2.0.
  @child = spawn(<<-EOC.split.join(" "))
    RUBY_GC_HEAP_FREE_SLOTS=4096
    RUBY_GC_HEAP_INIT_SLOTS=10000
    RUBY_GC_HEAP_GROWTH_FACTOR=1.8
    RUBY_GC_HEAP_GROWTH_MAX_SLOTS=0
    RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR=2.0
    RUBY_GC_MALLOC_LIMIT=16777216
    RUBY_GC_MALLOC_LIMIT_MAX=33554432
    RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR=1.4
    RUBY_GC_OLDMALLOC_LIMIT=16777216
    RUBY_GC_OLDMALLOC_LIMIT_MAX=134217728
    RUBY_GC_OLDMALLOC_LIMIT_GROWTH_FACTOR=1.2
    rails server > /dev/null
  EOC
  sleep 5
end

def alive?
  system("curl localhost:3000 &> /dev/null")
end

def stop_server
  Process.kill "HUP", server_pid
  Process.wait @child
end

def server_pid
  `cat tmp/pids/server.pid`.to_i
end

def memory_size_mb
  (`ps -o rss= -p #{server_pid}`.to_i * 1024).to_f / 2**20
end

def do_request
  uri = URI("http://localhost:3000/ruby/ruby/commits?result_type=discourse_categories&display_count=1000")
  req = Net::HTTP::Get.new(uri)

  Net::HTTP.start("localhost", uri.port) do |http|
    http.read_timeout = 60
    http.request(req)
  end
end

results = []

# You canâ€™t just measure once: memory usage has some variance.
# We will take the mean of 7 runs.
1.times do
  start_server

  used_mb = nil
  (1..50).map do |n|
    print "Request #{n}..."
    do_request
    used_mb = memory_size_mb
    puts "#{used_mb} MB"
  end

  final_mb = used_mb
  results << final_mb
  puts "Final Memory: #{final_mb} MB"

  stop_server
end

# mean_final_mb = results.reduce(:+) / results.size
# puts "Mean Final Memory: #{mean_final_mb} MB"
