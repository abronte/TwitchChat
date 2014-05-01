require 'redis'
require 'json'

r = Redis.new(port: 8888)

word_count = r.zcount "words", 1, 99999999
msg_count = r.zcount "chat", 1, 99999999

words = r.zrevrange "words", 0, 49, :with_scores => true
msgs = r.zrevrange "chat", 0, 49, :with_scores => true

total = r.get "total"

if ARGV[0]
  data = {
    words: words,
    messages: msgs,
    total_messages: msg_count,
    total_words: word_count,
    total_processed: total.to_i
  }

  File.write(ARGV[0], data.to_json)

  exit
end

puts "Top words:\n"

words.each do |w|
  puts "#{w[1]}\t#{w[0]}"
end

puts "\nTop messages:\n"

msgs.each do |m|
  puts "#{m[1]}\t#{m[0]}"
end

puts "\nTotal messages:\t\t#{msg_count}"
puts "Total words:\t\t#{word_count}"
puts "Total processed:\t#{total}"
