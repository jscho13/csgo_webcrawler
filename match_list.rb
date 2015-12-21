
class MatchList

  def initialize(starting_match, keyword_config)
    @match_list = [starting_match]
    @keyword_array = keyword_config
  end

  def setup
    while last_match_is_404? == false
      add_next_match
    end
  end

  def last_match_is_404?
    @match_list.last.is_404?
  end

  def add_next_match
    last_match = @match_list.last
    incremented_url = last_match.url[0, last_match.url.length-4] + (last_match.match_id+1).to_s
    @match_list << CsgoMatch.new(incremented_url, @keyword_array)
  end

  def update_csvs
    if last_match_is_404? && @match_list.length > 1
      @match_list[0..@match_list.length-2].each do |match|
        row_data = match.parse_html
        CSV.open(match.match_id.to_s << "_csgo_stats.csv", "ab") { |csv| csv << row_data }
      end
    else
      add_next_match
      @match_list.each do |match|
        row_data = match.parse_html
        CSV.open(match.match_id.to_s << "_csgo_stats.csv", "ab") { |csv| csv << row_data }
      end
    end
  end

end
