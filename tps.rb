require 'redis'

db = Redis.new(port: 8888)

count1 = 0
count2 = 0
peak = 0

loop do
  count1 = db.get("total").to_i

  sleep 1

  count2 = db.get("total").to_i

  tps = count2 - count1

  peak = tps if tps > peak

  puts "Peak msg/sec: #{peak}"
  puts "#{tps} msg/sec\n\n"
end
