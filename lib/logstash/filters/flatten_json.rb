# encoding: utf-8
require "logstash/filters/base"

# This filter will flatten json data into convenient strings, i.e.
# Imagine you have json data (from mongodb or docker-stats, for example) and you
# want to flatten it for further processing (or send it to graphite server maybe)
# [source,json]
# {
#     "key_1": "value_1",
#     "key_2": 2,
#     "key_3": {
#         "nested_key_1": "nested_value_1",
#         "nested_key_2": [1, 2, "a"]
#     }
# }
#
# the filter will enrich 'event' with following key-value pairs:
# [source]
# key_1: "value_1"
# key_2: 2,
# key_3.nested_key_1: "nested_value_1"
# key_3.nested_key_2.0: 1
# key_3.nested_key_2.1: 2
# key_3.nested_key_2.2: "a"
#
class LogStash::Filters::FlattenJson < LogStash::Filters::Base

  config_name "flatten_json"

  # The above would parse the json from the `message` field and enrich `event` with flattened data
  # [source,ruby]
  # filter {
  #    flatten_json {
  #        source => 'message'
  #    }
  # }
  #
  config :source, :validate => :string, :required => true

  public
  def register
    # Nothing to do here
  end

  public
  def filter(event)
    @logger.debug? && @logger.debug("Running flatten_json filter", :event => event)

    source = event.get(@source)
    return unless source

    flatten_json = flatten(source, '')
    flatten_json.each do |key, value|
      # if field is @timestamp, adding prefix
      if key.eql? "@timestamp"
        event.set("parsed_timestamp", value)
      else
        event.set(key, value)
      end
    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
    @logger.debug? && @logger.debug("Event after flatten_json filter", :event => event)
  end

  def flatten(json, prefix)
    if json && !json.empty?
      json.keys.each do |key|
        if prefix.empty?
          full_path = key
        else
          full_path = [prefix, key].join('.')
        end

        if json[key].is_a?(Hash)
          value = json[key]
          json.delete key
          json.merge! flatten(value, full_path)
        elsif json[key].is_a?(Array)
          # if field is array, convert its values to a strings
          arr_of_strs = []
          json[key].each do |obj|
            arr_of_strs.push(obj.to_s)
          end
          json.delete key
          json[full_path] = arr_of_strs
        else
          value = json[key]
          json.delete key
          json[full_path] = value
        end
      end
    end
    return json
  end

end
