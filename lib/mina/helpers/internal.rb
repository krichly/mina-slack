module Mina
  module Helpers
    module Internal
      include Helpers::Output

      def deploy_script
        yield
        erb Mina.root_path(fetch(:deploy_script))
      end

      def erb(file, b = binding)
        require 'erb'
        erb = ERB.new(File.read(file))
        erb.result b
      end

      def echo_cmd(code, ignore_verbose = false)
        if fetch(:verbose) && !ignore_verbose
          "echo #{Shellwords.escape('$ ' + code)} &&\n#{code}"
        else
          code
        end
      end

      def indent(count, str)
        str.gsub(/^/, ' ' * count)
      end

      def unindent(code)
        if code =~ /^\n([ \t]+)/
          code = code.gsub(/^#{$1}/, '')
        end

        code.strip
      end

      def report_time
        time_start = Time.now
        output = yield
        print_info "Elapsed time: %.2f seconds" % [Time.now - time_start]
        output
      end

      def next_version
        case fetch(:version_scheme)
        when :datetime
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        when :sequence
          "$((`ls -1 #{fetch(:releases_path)} | sort -n | tail -n 1`+1))"
        else
          error! 'Unrecognizes version scheme. Use :datetime or :sequence'
        end
      end

      def error!(message)
        url = fetch(:slack_hook)
        send_slack_message(slack_deploy_fail_message, url) if (url)
        print_error message
        exit 1
      end

      def slack_deploy_message
        attachment = {
          fallback: "Deployed #{short_revision}",
          color: '#36a64f',
          fields: [attachment_project, attachment_enviroment, attachment_deployer, attachment_committer, 
            attachment_branch, attachment_commit, attachment_commit_msg, attachment_url]
        }

        message = {
          'parse'       => 'full',
          'username'    => fetch(:slack_username),
          'attachments' => [attachment],
          'icon_emoji'  => fetch(:slack_emoji)
        }
      end

      def slack_deploy_fail_message
        attachment = {
          fallback: 'Required plain-text summary of the attachment.',
          color: '#ff3300',
          fields: [attachment_deploy_failed]
        }

        message = {
          'parse'       => 'full',
          'username'    => fetch(:slack_username),
          'attachments' => [attachment],
          'icon_emoji'  => fetch(:slack_emoji)
        }
      end

      def send_slack_message(message, slack_hook)
        uri = URI.parse(slack_hook)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(payload: message.to_json)

        http.request(request)
      rescue Encoding::InvalidByteSequenceError
        comment 'Invalid byte sequence'
      end

      def short_revision
        deployed_revision = fetch(:last_commit)
        deployed_revision[0..8] if deployed_revision
      end

      def attachment_project
        { title: 'Project', value: fetch(:application_name), short: true }
      end

      def attachment_enviroment
        { title: 'Environment', value: fetch(:slack_stage), short: true }
      end

      def attachment_deployer
        { title: 'Deployer', value: fetch(:deployer), short: true }
      end

      def attachment_committer 
        { title: 'Committer', value: fetch(:last_committer), short: true }
      end

      def attachment_commit
        { title: 'Revision', value: "#{short_revision}", short: true }
      end

      def attachment_branch
        { title: 'Branch', value: fetch(:branch), short: true }
      end

      def attachment_commit_msg
        { title: 'Commit Message', value: fetch(:last_commit_msg), short: false }
      end

      def attachment_url
        { title: 'Url', value: fetch(:domain), short: false}
      end

      def attachment_deploy_failed
        { title: 'Deploy status', value: "Deployment of #{fetch(:application_name)} has failed.", short: false}
      end

    end
  end
end
extend Mina::Helpers::Internal
