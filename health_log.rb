require 'yaml'
require 'yaml/store'

class HealthLog
  attr_reader :store, :config, :date

  def initialize(file, date: nil, config_file: 'config.yml')
    @store = YAML::Store.new file
    config_path = File.join __dir__, config_file
    @config = YAML.load File.read(config_path)
    @date = date || Date.today.to_s
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

  def graph(n=7)
    weight_diffs_for_last_n_days(n).each_with_object([]) do |diff, chart|
      symbol = diff > 0 ? '+' : '-'
      actual = target + (diff/10.0)
      chart << [symbol * diff.abs, actual].join('   ')
    end
  end

  def weight_diffs_for_last_n_days(n=7)
    weights_for_last_n_days(n).map { |w| ((w - target) * 10).to_i }
  end

  def weights_for_last_n_days(n=7)
    last_n_days(n).each_with_object([]) do |(date, data), result|
      result << data.fetch(:weight, target).to_f
    end
  end

  def target
    config['target'].to_f
  end

  def tokens
    keyword_mapping.keys
  end

  private

  def roots_for_last_n_days(n)
    (0..(n-1)).each_with_object([]) do |n, roots|
      roots << (Date.today - n).to_s
    end.reverse
  end

  def parsed_input(raw_input)
    return {} if raw_input.strip.empty?
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
      end
    end
    store_data result, current_keyword, '', chunk
    result
  end

  def keyword_match
    /\w+:/
  end

  def keyword_mapping
    @keywords ||= config['tokens'].each_with_object({}) do |(k,v), tokens|
      token = k + ':'
      tokens[token] = v
    end
  end

  def store_data(result, current_keyword, new_keyword, chunk)
    key = keyword_mapping[current_keyword].to_sym
    value = chunk.gsub(new_keyword, '').strip
    result[key] = existing_value(key) + value
  end

  def existing_value(key)
    existing = existing_values.fetch key, nil
    existing ? (existing + '. ') : ''
  end

  def existing_values
    @existing_values ||= store.fetch(date, {})
  end


end
