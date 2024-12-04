# Logstash Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

This filter plugin will flatten json data into strings, i.e.
```json
{
    "key_1": "value_1",
    "key_2": 2,
    "key_3": {
        "nested_key_1": "nested_value_1",
        "nested_key_2": [1, 2, "a"]
    }
}
```

example configuration:
```
filter {
    flatten_json {
        source => "message"
    }
}
```

the filter will enrich 'event' with following key-value pairs:
```ascii
key_1: "value_1"
key_2: 2
key_3.nested_key_1: "nested_value_1"
key_3.nested_key_2: ["1", "2", "a"]
```

This is very convenient if you have stats data from mongodb or docker-stats and you want to further process it or send to graphite server.

Logstash provides infrastructure to automatically generate documentation for this plugin. We use the asciidoc format to write documentation so any comments in the source code will be first converted into asciidoc and then into html. All plugin documentation are placed under one [central location](http://www.elastic.co/guide/en/logstash/current/).

- For formatting code or config example, you can use the asciidoc `[source,ruby]` directive
- For more asciidoc formatting tips, see the excellent reference here https://github.com/elastic/docs#asciidoc-guide

## Need Help?

Need help? Try #logstash on freenode IRC or the https://discuss.elastic.co/c/logstash discussion forum.

# Build

```shell
gem build logstash-filter-flatten_json.gemspec
```

# Preparing the plugin for offline installation (without an Internet connection)

To do this, you will need logstash of the required version with an Internet connection.
Execute the command:
```shell
bin/logstash-plugin install --no-verify ./logstash-filter-flatten_json-0.2.0.gem
```

```shell
bin/logstash-plugin prepare-offline-pack logstash-filter-flatten_json
```

An archive will be created in the current directory, such as logstash-offline-plugins-8.6.1.zip
This archive can be installed on logstashes without the Internet.

Important! The archive should be compiled on the same version of logstash as the target installation.

# Installing offline plugins on logstash

```shell
logstash-plugin install file://logstash-offline-plugins-8.6.1.zip
```
