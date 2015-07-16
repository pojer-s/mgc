# MCG

MCG is a web daemon that automatically generate file from template and execute commands for web services deployed on Apache Mesos and Marathon.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mcg'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mcg

## Usage

Create configuration file like this exemple:  

```json
{
    "bind": "127.0.0.1",
    "port": 8000,
    "marathon": "http://localhost:8080",
    "host": "http://127.0.0.1:8000/callback",
    "actions": {
        "apache": {
            "template": "/etc/mgc/apache-template.conf.erb",
            "output": "/etc/apache2/sites-enabled/all_site",
            "reload_command": "apachectl -t && apachectl graceful"
        }
    }
}
```

and template like this exemple:  

```
<% @data.tasks.each do |name, conf| %>
# Generated configuration for <%= name %>

<VirtualHost *:80>
	ServerAdmin admin@foo.fr
	ServerName <%= name %>

	ProxyRequests Off
	ProxyPreserveHost On
	SetEnv proxy-sendcl 1

	<Proxy balancer://<%= name.gsub(/[\.-]/, '_') %>>
		<% conf.each do |c| %>
		BalancerMember <%= c[:host] %>:<%= c[:port] %>
		<% end %>
	</Proxy>

	ProxyPass / balancer://<%= name.gsub(/[\.-]/, '_') %>/
	ProxyPassReverse / balancer://<%= name.gsub(/[\.-]/, '_') %>/

</VirtualHost>
<% end %>
```

and start the daemon like this:  

```
mcg -f conf.json
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/pojer-s/mcg/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
