require 'redis'

r = Redis.new(port: 8888)

word_count = r.zcount "words", 1, 99999999
msg_count = r.zcount "chat", 1, 99999999

words = r.zrevrange "words", 0, 15, :with_scores => true
msgs = r.zrevrange "chat", 0, 15, :with_scores => true

puts "Top words:\n"

words.each do |w|
  puts "#{w[1]}\t#{w[0]}"
end

puts "\nTop messages:\n"

msgs.each do |m|
  puts "#{m[1]}\t#{m[0]}"
end

puts "\nTotal messages:\t#{msg_count}"
puts "Total words:\t#{word_count}"
