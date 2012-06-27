# coding: utf-8
require 'cgi'

module Cinch
  module Plugins
    module Twitter
      module Formatter

        def format_tweet(tweet)
          tweet_text = expand_uris(tweet.text, tweet.attrs["entities"]["urls"])
          parts, head, body, tail, urls = [], [], [], [], []
          head = Format(:bold,"#{tweet.user.screen_name} »")
          body << CGI::unescapeHTML(tweet_text.gsub("\n", " ").squeeze(" "))
          body << Format(:aqua,"*twoosh*") if tweet.text.length == 140
          tail << "From #{tweet.place.full_name}" if !tweet.place.blank?
          tail << "at #{tweet.created_at.strftime("%B %-d, %Y, %-I:%m%P")}"
          tail << "via #{tweet.source.gsub( %r{</?[^>]+?>}, '' )}"
          urls << "https://twitter.com/#{tweet.user.screen_name}"
          urls << Format(:grey,"in reply to") if !tweet.in_reply_to_screen_name.blank?
          urls << "http://twitter.com/#{tweet.in_reply_to_screen_name}#{"/statuses/#{tweet.in_reply_to_status_id.to_s}" if !tweet.in_reply_to_status_id.blank?}" if !tweet.in_reply_to_screen_name.blank?
          parts = [head, body, ["(", tail.join(" "), ")"].join, urls].flatten
          parts.join(" ")
        end

        def format_search(tweet)
          tweet_text = expand_uris(tweet.text, tweet.attrs["entities"]["urls"])
          parts, head, body, tail, urls = [], [], [], [], []
          head = Format(:bold,"#{tweet.from_user} »")
          body << CGI::unescapeHTML(tweet_text.gsub("\n", " ").squeeze(" "))
          body << Format(:aqua,"*twoosh*") if tweet.text.length == 140
          tail << "at #{tweet.created_at.strftime("%B %-d, %Y, %-I:%m%P")}"
          urls << "https://twitter.com/#{tweet.from_user}"
          parts = [head, body, ["(", tail.join(" "), ")"].join, urls].flatten
          parts.join(" ")
        end

        def format_tweep_info(tweep)
          tweep_status_text = expand_uris(tweep.status.text, tweep.status.attrs["entities"]["urls"])
          head =  "#{Format(:aqua,tweep.name)}" + Format(:silver," (#{tweep.screen_name})") + Format(:grey," - #{tweep.url} https://twitter.com/#{tweep.screen_name}")
          bio = ""
          bio = Format(:aqua,"\"#{tweep.description.strip}\"") if !tweep.description.blank?
          location = ""
          location = "They are from #{Format(:aqua,tweep.location.strip)}" if !tweep.location.blank?
          desc = [] << "has made #{tweep.statuses_count} tweets since #{tweep.created_at.strftime("%B %-d, %Y")}"
          desc << "follows #{tweep.friends_count} tweeps" if tweep.friends_count > 0
          desc << "has #{tweep.followers_count} followers" if tweep.followers_count > 0
          desc << "has favourited #{tweep.favourites_count} tweets" if tweep.favourites_count > 0
          desc << "is also in #{tweep.listed_count} lists" if tweep.listed_count > 0
          flags = []
          flags << "is actually a group-run account" if tweep.contributors_enabled?
          flags << "is a translator for Twitter" if tweep.is_translator?
          flags << "is verified" if tweep.verified?
          flags << "would rather keep their life secret" if tweep.protected?
          tweet = [] << Format(:aqua,"Their latest tweet:")
          tweet << CGI::unescapeHTML(tweep_status_text.gsub("\n", " ").squeeze(" "))
          tweet_tail = []
          tweet_tail << "from #{tweep.status.place.full_name}" if !tweep.status.place.blank?
          tweet_tail << "at #{tweep.status.created_at.strftime("%B %-d, %Y, %-I:%m%P")}"

          parts = [head, bio, location, desc, flags].reject(&:blank?).map {|e| e.is_a?(Array) ? "#{tweep.name} " + e.to_sentence + "." : e }
          parts << [tweet, Format(:silver,["(", tweet_tail.join(" "), ")"].join)].join(" ")
          parts.join("\n")
        end
      
        private
        
        def expand_uris t, uris
          tweet = t.dup
          uris.each {|u|
            expanded_url, url = u["expanded_url"], u["url"]
            tweet.gsub! url, expanded_url
          }
          return tweet
        end

      end
    end
  end
end