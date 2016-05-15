gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'pathname'
require_relative 'health_log'

class HealthLogTest < MiniTest::Test
  def setup
    @file = "test.yml"
    @log = HealthLog.new @file
    @date = Date.today.to_s
  end

  def teardown
    test_file = Pathname(@file)
    test_file.delete if test_file.exist?
  end

  def test_adding_an_entry
    @log.entry sample_input
    actual = File.read @file
    assert_equal expected_output.to_yaml, actual
  end

  def test_add_partial_data_to_a_date_entry
    @log.entry sample_input
    @log.entry "x: partial entry"
    expected = expected_output
    expected[@date][:exercise] = "partial entry"
    actual = File.read @file
    assert_equal expected.to_yaml, actual
  end

  def test_handles_empty_input
    @log.entry sample_input
    @log.entry "\n"
    actual = File.read @file
    assert_equal expected_output.to_yaml, actual
  end

  def test_skipping_weight
    input = <<-TXT.gsub(/\s+/,' ').strip << ("\n")
      dq: ate cookie dv: ate too much bl: 4 s: not bad x: strong workout
    TXT
    @log.entry input
    expected = expected_output
    expected[@date].delete(:weight)
    actual = File.read @file
    assert_equal expected.to_yaml, actual
  end

  def test_reviewing_all_entries
  end

  def test_export_weights_to_csv
  end

  def test_exported_weights_inserts_missing_days
  end

  def test_report_for_last_n_days
  end

  def sample_input
    <<-TXT.gsub(/\s+/,' ').strip << ("\n")
      200.5 dq: ate cookie bl: 4 dv: ate too much s: not bad x: strong workout
    TXT
  end

  def expected_output
    {
      @date => {
        weight: 200.5,
        diet: {
          quality: "ate cookie",
          volume: "ate too much"
        },
        belt_loop: '4',
        sleep: "not bad",
        exercise: "strong workout",
      }
    }
  end

end
