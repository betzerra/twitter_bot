require 'dropbox_api'
require 'net/http'
require 'twitter'

stream_client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

dropbox_access_token = ENV['DROPBOX_ACCESS_TOKEN']
client = DropboxApi::Client.new(dropbox_access_token)

search_criteria = '#TrabajoAR'
success_file = 'result.csv'

def matched_criteria(tweet)
  filter_keywords = ['pm', 'psico', 'humanos', 'project', 'manager', 'recruiter', 'administra', 'rrhh']
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
      puts "#{object.text}"

      matched = matched_criteria(object)

      line = "#{object.created_at}, #{original_tweet_url(object)}, #{matched}, #{!object.retweeted_status.nil? ? 'RT' : ''}, #{!object.retweeted_status.nil? ? source_tweet_url(object) : ''}"

      unless matched.nil?
        open(success_file, 'a') { |f| f.puts line }
        contents = IO.read(success_file)
        client.upload "/#{success_file}", contents, :mode => :overwrite
      end
    end
  rescue => e
    puts e
  end
end
