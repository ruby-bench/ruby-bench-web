module ChartsHelper
  # Generate an HTML string representing `version`, with each pair on a new line
  #
  # `version` will usually look like:
  # {
  #   commit: "b6589fc",
  #   commit_date: "2017-02-23T16:20:13.338Z",
  #   commit_message: "fix something",
  #   environment: "ruby 2.2.0dev"
  # }
  #
  # and this function turns it into:
  # Commit: b6589fc
  # Commit Date: 2017-02-23T16:20:13.338Z
  # Commit Message: fix something
  # ruby 2.2.0dev
  def chart_version_to_html(version)
    version.map do |k, v|
      if k == :environment
        v
      else
        new_key = k.to_s.split('_').map(&:capitalize).join(' ')
        "#{new_key}: #{v}" 
      end
    end.join("<br>")
  end
end
