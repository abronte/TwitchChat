require 'cinch'
require 'redis'
require 'json'
require 'curb'

NICK = ENV['TWITCH_USER']
NUM_STREAMS = (ARGV[0] || 30).to_i
$db = Redis.new(port: 8888)

def get_streams
  r = Curl.get("https://api.twitch.tv/kraken/streams?limit=#{NUM_STREAMS}")
  data = JSON.parse(r.body_str)

  data["streams"].map { |s| "##{s["channel"]["name"]}" }
end

$bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.twitch.tv"
    c.password = ENV['TWITCH_PW']
    c.channels = get_streams
    c.nick = NICK
  end

  on :message do |m|
    # we don't care about messages to us
    if m.params[0] != NICK
      $db.incr "total"

      # attempt to normalize some of these messages. downcase and remove and
      # trailing or leading white space
      msg = m.message.downcase.strip

      # puts "#{m.channel}\t:: #{m.message}" if m.channel == "#nightblue3"
      # puts "#{m.channel}\t:: #{m.message}"

      # make sure we're filtering out any voting/comamnd/misc messages
      if (msg =~ /^[-+]?[0-9]+$/) == nil && msg[0] != "!" && !msg.include?("░")
        begin
          $db.zincrby "chat", 1, msg 

          # this emote is notable enough to count it as word even though
          # there is a space in it
          if msg.include?("༼ つ ◕_◕ ༽つ")
            $db.zincrby "words", 1, "༼ つ ◕_◕ ༽つ"
          end

          # remove the emote because we've counted it
          # also remove double spaces
          msg = msg.gsub("༼ つ ◕_◕ ༽つ", "").gsub("  ", " ")

          msg.split(" ").each do |word|
            $db.zincrby "words", 1, word if (word =~ /^[-+]?[0-9]+$/) == nil
          end
        rescue 
          puts "\nPROBLEM MSG: #{msg}\n"
        end
      end
    end
  end
end

$bot.loggers.level = :error

# gotta start bot in a seperate thread
Thread.new {
  $bot.start
}

puts "Bot started"

sleep(60)

# main loop that monitors what channels we should be
# listening to
loop do
  channels = $bot.channels.map {|c| c.to_s}
  puts "Current channels: #{channels.join(", ")}"

  sleep(30 * 60)

  # get an updated top 30 list and join/leave
  # channels based on this list
  streams = get_streams

  join = streams - channels
  leave = channels - streams

  join.each do |c|
    puts "JOINING #{c}"
    $bot.join(c)
  end

  leave.each do |c|
    puts "LEAVING #{c}"
    $bot.part(c)
  end
end
