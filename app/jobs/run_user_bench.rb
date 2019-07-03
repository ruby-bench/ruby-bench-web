class RunUserBench < ActiveJob::Base
  queue_as :default

  def perform(name, script_url, start_date, stop_sha)
    commits = fetch_commits(start_date, stop_sha)

    repo = Repo.find_or_create_by!(
      name: "ruby",
      url: "https://github.com/tgxworld/ruby",
      organization: Organization.find_or_create_by!(
        name: "ruby",
        url: "https://github.com/tgxworld/",
      )
    )

    CommitsRunner.run(:api, commits, repo, '', smart: true, name: name, script_url: script_url, initiator_type: "user_scripts")
  end

  private

  def fetch_commits(start_date, stop_sha)
    client = Octokit::Client.new(access_token: Rails.application.secrets.github_api_token, per_page: 100)
    commits = []
    done = false
    batch = client.commits("ruby/ruby", { until: start_date })
    response = client.last_response
    while batch.size > 0 && !done
      index = -1
      batch.each_with_index do |c, ind|
        if c.sha == stop_sha
          done = true
          index = ind
        end
      end
      if done
        commits.push(*batch[0..index])
        break
      else
        commits.push(*batch)
        response = response.rels[:next]&.get
        batch = response&.data || []
      end
    end
    commits
  end
end
