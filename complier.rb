require 'open-uri'
require 'nokogiri'
require 'csv'
require 'pry'

require_relative 'csgo_match.rb'
require_relative 'match_list.rb'

puts "Input duration(sec), increment(sec), and starting URL: (e.g. '60,10,http://csgolounge.com/match?m=7078')"
#the example would extract all day, every 30 seconds, starting from match 7078 and going up from there
extract_config = gets.chomp.split(',')
puts "Input keywords: (e.g. 'noname,Factory New,karambit')"
#an @*** tag will be applied to the beginning of all keywords. I think you can create an excel rule to highlight anything with that tag.
keyword_config = gets.chomp.split(',')

class WebCrawler

  def initialize(extract_config, keyword_config)
    @max_time = extract_config[0].to_i
    @increment = extract_config[1].to_i
    first_match = CsgoMatch.new(extract_config[2], keyword_config)
    @match_list = MatchList.new(first_match, keyword_config)
  end

  def extraction_loop
    timer = 0
    @match_list.setup
    while timer < @max_time
      @match_list.update_csvs
      timer += @increment
      sleep @increment
    end
  end

end

object = WebCrawler.new(extract_config, keyword_config)
object.extraction_loop
