# Slack tasks
namespace :slack do
  task :post_info do
    if slack_hook = fetch(:slack_hook)

      _potential_stage = ARGV.first
      if _stage_file_exists?(_potential_stage) && _argument_included_in_stages?(_potential_stage)
        invoke _potential_stage
      elsif _stage_file_exists?(_default_stage)
        invoke _default_stage
      end

      set(:last_commit, `git log -n 1 --pretty=format:"%H" origin/#{fetch(:branch)} --`)
      set(:last_committer, `git log -n 1 --pretty=format:"%cn" origin/#{fetch(:branch)} --`)
      set(:last_commit_msg, `git log -n 1 --pretty=format:"%B" origin/#{fetch(:branch)} --`)
      
      send_slack_message(slack_deploy_message, slack_hook)
    else
      print_status 'Unable to create Slack Announcement, no slack details provided.'
    end
  end
end
