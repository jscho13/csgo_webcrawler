require 'open-uri'
require 'nokogiri'
require 'csv'

print "How many seconds do you want the script to run for (i.e. 600): "
max_time = gets.chomp
print "How often do you want to extract (will be calculated in seconds): "
increment = gets.chomp
counter = 0
puts "Starting script. If you put in letters or weird shit the program will break."

while counter < max_time.to_i

  stats_string = []
  #REPLACE URL WITH EXTRACTION SOURCE
  doc = Nokogiri::HTML(open("http://csgolounge.com/match?m=6992"))
  doc.search('br').each do |n|
    n.replace("\n")
  end
  ratios = doc.xpath("//div[@class='half']")

  ratios.each_with_index do |ratio, index|
    if index.between?(0,1)
    else
      stats_string << ratio.text.gsub(/  +/,'')
    end
  end

  betting_items = doc.xpath(
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
    stats_string << bet_item.text.gsub(/  +/,'')
  end
  stats_string << "\n"
  #REPLACE CSV FILE WITH TARGET FILE
  CSV.open("csgo_stats.csv", "ab") do |csv|
    csv << stats_string
  end
  counter += increment.to_i
  sleep increment.to_i
end

puts "The script has finished running for #{max_time} seconds at #{increment} second intervals."
