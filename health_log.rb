require 'yaml'
require 'yaml/store'

class HealthLog
  attr_reader :store

  def initialize(file)
    @store = YAML::Store.new file
  end

  def entry(raw_input)
    store.transaction do
      current_data = store[date] || {}
      store[date] = current_data.merge parsed_input(raw_input)
    end
  end

  def last_n_days(n=7)
    store.transaction do
      roots_for_last_n_days(n).each_with_object({}) do |date, entries|
        entries[date] ||= {}
        entries[date] = store.fetch(date, {results: '-'}).to_hash
      end
    end
  end

  private

  def roots_for_last_n_days(n)
    (0..(n-1)).each_with_object([]) do |n, roots|
      roots << (Date.today - n).to_s
    end
  end

  def date
    Date.today.to_s
  end

  def parsed_input(raw_input)
    chunk = ""
    result = {}
    current_keyword = nil
    raw_input.each_char do |char|
      chunk << char
      if chunk =~ keyword_match
        new_keyword = Regexp.last_match.to_s
        if current_keyword
          store_data result, current_keyword, new_keyword, chunk
        end
        current_keyword = new_keyword
        chunk = ""
      elsif /\d\d\d\.\d/ =~ chunk.strip
        result[:weight] = chunk.strip.to_f
        chunk = ""
      end
    end
    store_data result, current_keyword, '', chunk
    result
  end

  def keyword_match
    /\w+:/
  end

  def keywords
    keyword_mapping.keys
  end

  def keyword_mapping
    { 's:' => "sleep",
      'bl:' => "belt_loop",
      'c:' => 'comments',
      'x:' => "exercise",
      'dq:' => {"diet" => 'quality'},
      'dv:' => {"diet" => 'volume'}
    }
  end

  def store_data(result, current_keyword, new_keyword, chunk)
    key = keyword_mapping[current_keyword]
    value = chunk.gsub(new_keyword, '').strip
    if key.is_a? Hash
      parent_key = key.keys.first.to_sym
      sub_key = key.values.first.to_sym
      result[parent_key] ||= {}
      result[parent_key][sub_key] = value
    elsif key.is_a? String
      result[key.to_sym] = value
    end
  end


end
