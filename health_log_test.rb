gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'pathname'
require_relative 'health_log'

class HealthLogTest < MiniTest::Test
  def setup
    @file = "test.yml"
    @log = HealthLog.new @file, config_file: 'test_config.yml'
    @date = Date.today.to_s
  end

  def teardown
    fixture_file = Pathname('fixture.yml')
    fixture_file.delete if fixture_file.exist?
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

  def test_reviewing_all_entries
  end

  def test_export_weights_to_csv
  end

  def test_exported_weights_inserts_missing_days
  end

  def test_report_for_last_n_days
    expected = {
      "#{Date.today.to_s}" => {
        sleep: '6.5',
        exercise: 'none, gym was closed',
        diet: {
          quality: '2 or 3 servings of sugar',
          volume: 'not bad'
        },
        'belt loop' => '4'
      },

      "#{(Date.today - 1).to_s}" => {
        results: '-'
      },
      "#{(Date.today - 2).to_s}" => {
        sleep: '5.5',
        exercise: 'great',
        diet: {
          quality: 'good',
          volume: 'very good',
        },
        belt_loop: '3'
      }
    }

    first_entries = expected.dup
    first_entries.delete (Date.today - 1).to_s
    sample_data = first_entries.merge({
      "#{(Date.today - 4).to_s}" => {
        sleep: '9.5',
        exercise: 'great',
        diet: {
          quality: 'good',
          volume: 'very good',
        },
        belt_loop: '3'
      },
    }).to_yaml
    File.open('fixture.yml', 'w') { |f| f.write sample_data }

    log = HealthLog.new 'fixture.yml'
    assert_equal expected, log.last_n_days(3)
  end

  def sample_input
    <<-TXT.gsub(/\s+/,' ').strip << ("\n")
      w: 200.5 dq: ate cookie bl: 4 dv: ate too much s: not bad c: random comments x: strong workout
    TXT
  end

  def expected_output
    {
      @date => {
        weight: '200.5',
        'diet quality': "ate cookie",
        'belt loop': '4',
        'diet volume': "ate too much",
        sleep: "not bad",
        comments: 'random comments',
        exercise: "strong workout",
      }
    }
  end

end
