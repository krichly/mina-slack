# Mina::Slack

Announce Mina deployments to a slack channel.

## Installation

Add this line to your application's Gemfile:

    gem 'mina-slack', github: "eManPrague/mina-slack"

And then execute:

    $ bundle

## Usage

### Load the recipe
Include the recipe in your deploy.rb

    # config/deploy.rb
    require 'mina/slack'

### Setup Mina Slack
You'll need to setup your slack details with an API key, room and subdomain. You can add these as ENV variables or in the config/deploy.rb

    # required
    set :slack_hook, 'https://hooks.slack.com/services/<YOUR-STRING1>/<YOUR-STRING2>/<YOUR-STRING3>' # comes from inbound webhook integration

    # optional
    set :slack_username, 'Deploy Bot' # displayed as name of message sender
    set :slack_emoji, ':cloud:' # will be used as the avatar for the message
    set :slack_stage, 'staging' # will be used to specify the deployment environment

Or use the ENV variables:

    # required
    ENV['SLACK_HOOK'] = ''

    # optional
    ENV['SLACK_USERNAME'] = ''
    ENV['SLACK_EMOJI'] = ''
    ENV['SLACK_STAGE'] = '' # or ENV['to']

 Update `deploy` task to invoke `slack:post_info` task:

 ```ruby
task :deploy do
  invoke :'slack:post_info'
end
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/mina-slack/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
