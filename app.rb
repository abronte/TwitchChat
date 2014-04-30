require 'cinch'
require 'redis'
require 'json'
require 'curb'

NICK = ENV['TWITCH_USER']

NUM_STREAMS = (ARGV[0] || 30).to_i
STREAM_PER_PROC = (ARGV[1] || 4).to_i

def start_bot(channels)
  bot = Cinch::Bot.new do
    db = Redis.new(port: 8888)

    configure do |c|
      c.server = "irc.twitch.tv"
      c.password = ENV['TWITCH_PW']
      c.channels = channels
      c.nick = NICK
    end

    on :message do |m|
      if m.params[0] != NICK
        db.incr "total"

        msg = m.message.downcase

        puts "#{m.channel}\t:: #{m.message}"

        if (msg =~ /^[-+]?[0-9]+$/) == nil && msg[0] != "!" && !msg.include?("░")
          db.zincrby "chat", 1, msg 

          if msg.include?("༼ つ ◕_◕ ༽つ")
            db.zincrby "words", 1, "༼ つ ◕_◕ ༽つ"
          end

          msg = msg.gsub("༼ つ ◕_◕ ༽つ", "").gsub("  ", " ")

          msg.split(" ").each do |word|
            db.zincrby "words", 1, word if (word =~ /^[-+]?[0-9]+$/) == nil
          end
        end
      end
    end
  end

  bot.loggers.level = :error
  bot.start
end

procs = []

loop do
  puts "Grabbing fresh stream list"

  r = Curl.get("https://api.twitch.tv/kraken/streams?limit=#{NUM_STREAMS}")
  data = JSON.parse(r.body_str)

  streams = []

  data["streams"].each do |s|
    streams << "##{s["channel"]["name"]}"
  end

  streams.each_slice(STREAM_PER_PROC) do |slice|
    procs << fork { start_bot(slice) }
  end

  # grab a new top list every 30 minutes
  sleep(30*60)

  puts "KILLING"

  procs.each do |pid| 
    Process.kill("KILL", pid)
  end

  procs = []
end
