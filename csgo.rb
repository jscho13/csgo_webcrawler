require 'open-uri'
require 'nokogiri'
require 'csv'
require 'pry'

# puts "Please enter the script duration (sec), increment (sec), and starting URL split by ', ' (e.g. '86400,30,http://csgolounge.com/match?m=7078')"
# #the example would extract all day, every 30 seconds, starting from match 7078 and going up from there
# extract_config = gets.chomp.split(',')
# puts "Please enter keywords split by ', ' (e.g. 'loungesan,Factory New,karambit')"
# #an @*** tag will be applied to the beginning of all keywords. I think you can create an excel rule to highlight anything with that tag.
# keyword_config = gets.chomp.split(',')

class CsgoData

  def initialize(extract_config, keyword_config)
    @max_time = extract_config[0].to_i
    @increment = extract_config[1].to_i
    @url = extract_config[2]
    @keyword_array = keyword_config
  end

  def extraction_loop
    timer = 0
    while timer < @max_time
      raw_extract = Nokogiri::HTML(open(@url))
      game_data = parse_html(raw_extract)
      CSV.open(match_number << "_csgo_stats.csv", "ab") { |csv| csv << game_data }
      string_increment
      timer += @increment
      sleep @increment
    end
  end

  def parse_html(html)
    stats_string = []
    html.search('br').each { |n| n.replace("\n") }
    unless html.xpath("//section[@class='full']")[0].text.match(/Looks like there\'s no site/).nil?
      return "############ Faulty Extract ############"
    else
      ratios = html.xpath("//div[@class='half']")
      ratios.each_with_index do |ratio, index|
        stats_string << ratio.text.gsub(/  +/,'') unless index.between?(0,1)
      end

      betting_items = html.xpath(
      "//div[@id='last30bets']
      /div[@id='bets']
      /div[@class='winsorloses']
      /div[@class='oitm']
      /div
      /img
      /@alt
      |
      //div[@id='last30bets']
      /div[@id='bets']
      /div[@class='winsorloses']
      /div[@class='betheader']
      /span[@class='user']")
      betting_items.each_with_index do |bet_item, index|
        @keyword_array.each do |match_string|
          unless bet_item.text.match(/#{match_string}/).nil?
            flagged_string = "@***" << bet_item.text.gsub(/  +/,'')
            stats_string << flagged_string
          else
            stats_string << bet_item.text.gsub(/  +/,'')
          end
        end
      end
      return stats_string << "\n"
    end
  end

  def string_increment
    incremented_match_number = match_number + 1
    @url = @url[0, @url.length-4] << incremented_match_number.to_s
  end

  def match_number
    @url[-4..-1].to_i
  end
end

extract_config = [10, 50, "http://csgolounge.com/match?m=10000"]
keyword_config = []
object = CsgoData.new(extract_config, keyword_config)
object.extraction_loop
