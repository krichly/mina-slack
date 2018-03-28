# Required
set :slack_hook,       -> { ENV['SLACK_HOOK'] }

# Optional
set :slack_stage,       -> { ENV['SLACK_STAGE'] || ENV['TO'] || ENV['to'] || fetch(:rails_env) }
set :slack_username,    -> { ENV['SLACK_USERNAME'] || 'deploybot' }
set :slack_emoji,       -> { ENV['SLACK_EMOJI'] || ':cloud:' }
# Git
set :deployer,          -> { ENV['GIT_AUTHOR_NAME'] || %x[git config user.name].chomp }
