require 'twitter'
require 'net/http'


stream_client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

search_criteria = '#planfmi'
success_file = 'trabajos.csv'
# log_file = 'log.csv'

def matched_criteria(tweet)
  filter_keywords = ['rrhh', 'pm', 'psico', 'humanos', 'project', 'manager', 'recruiter', 'administra', 'cobranzas', 'banco', 'contador']
  matched = nil

  filter_keywords.each do |x|
    if tweet.text.downcase.include? x
      matched = x
      break
    end
  end

  matched
end

def original_tweet_url(tweet)
  if tweet.retweeted_status.nil?
    "http://www.twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}"
  else
    "http://www.twitter.com/#{tweet.retweeted_status.user.screen_name}/status/#{tweet.retweeted_status.id}"
  end
end

def source_tweet_url(tweet)
  "http://www.twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}"
end

stream_client.filter(track: search_criteria) do |object|
  begin
    if object.is_a?(Twitter::Tweet)
      puts object.text
=begin
      matched = matched_criteria(object)

      line = "#{object.created_at}, #{original_tweet_url(object)}, #{matched}, #{!object.retweeted_status.nil? ? 'RT' : ''}, #{!object.retweeted_status.nil? ? source_tweet_url(object) : ''}"

      if matched.nil?
        open(log_file, 'a') { |f|
          f.puts line
        }
      else
        open(success_file, 'a') { |f|
          f.puts line
        }
        system("./dropbox_uploader.sh upload #{success_file} /")
      end
=end
    end
  rescue => e
    puts e
  end
end
