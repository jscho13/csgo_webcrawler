
class CsgoMatch

  attr_reader :match_id, :url

  def initialize(url, keyword_array)
    @match_html = Nokogiri::HTML(open(url))
    @match_id = url[-4..-1].to_i
    @url = url
    @keyword_array = keyword_array
  end

  def parse_html
    parsed_array = []
    @match_html.search('br').each { |n| n.replace("\n") }
    ratios = @match_html.xpath("//div[@class='half']")
    ratios.each_with_index do |ratio, index|
      parsed_array << ratio.text.gsub(/  +/,'') unless index.between?(0,1)
    end

    betting_items = betting_items_directory
    betting_items.each_with_index do |bet_item, index|
      unless keyword_match(bet_item.text).empty?
        parsed_array << keyword_match(bet_item.text)
      else
        parsed_array << bet_item.text.gsub(/  +/,'')
      end
    end
    parsed_array << "\n"
  end

  def betting_items_directory
    betting_items = @match_html.xpath(
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
  end

  def keyword_match(text)
    @keyword_array.each do |match_string|
      unless text.match(/#{match_string}/).nil?
        flagged_string = "@***" + text.gsub(/  +/,'')
        return flagged_string
      end
    end
    []
  end

  def is_404?
    fourohfour_match = @match_html.xpath("//section[@class='full']")[0]
    unless fourohfour_match.nil?
      return true
    else
      return false
    end
  end

end
