class ReposController < ApplicationController
  def show
    @organization = find_organization_by_name(params[:organization_name])
    @repo = find_organization_repos_by_name(@organization, params[:repo_name])

    if @form_result_type = params[:result_type]
      @benchmark_type = find_repo_benchmark_type_by_category(@form_result_type)

      chart_builder = ChartBuilder.new(
        fetch_benchmark_runs(@repo.commits, 'Commit', @form_result_type).sort_by do |benchmark_run|
          benchmark_run.initiator.created_at
        end
      )

      @chart_columns = chart_builder.build_columns do |benchmark_run|
        environment = YAML.load(benchmark_run.environment)

        if environment.is_a?(Hash)
          temp = ""

          environment.each do |key, value|
            temp << "#{key}: #{value}<br>"
          end

          environment = temp
        end

        "
          Commit: #{benchmark_run.initiator.sha1[0..6]}<br>
          Commit Date: #{benchmark_run.initiator.created_at}<br>
          #{environment}
        ".squish
      end
    end

    respond_to do |format|
      format.html do
        @result_types = fetch_categories('Commit')
      end

      format.js
    end
  end

  def show_releases
    @organization = find_organization_by_name(params[:organization_name])
    @repo = find_organization_repos_by_name(@organization, params[:repo_name])
    releases = @repo.releases

    if @form_result_type = params[:result_type]
      @charts =
        [@form_result_type, "#{@form_result_type}_memory"].each_with_index.map do |result_type, index|
          instance_variable_name = index == 0 ? :@benchmark_type : :@benchmark_type_memory

          self.instance_variable_set(
            instance_variable_name, find_repo_benchmark_type_by_category(result_type)
          )

          benchmark_runs = fetch_benchmark_runs(@repo.releases, 'Release', result_type)
          next if benchmark_runs.empty?

          chart_builder = ChartBuilder.new(
            benchmark_runs.sort_by do |benchmark_run|
              benchmark_run.initiator.version
            end
          )

          chart_builder.build_columns do |benchmark_run|
            environment = YAML.load(benchmark_run.environment)

            if environment.is_a?(Hash)
              temp = ""

              environment.each do |key, value|
                temp << "#{key}: #{value}<br>"
              end

              environment = temp
            end

            "Version: #{benchmark_run.initiator.version}<br> #{environment}"
          end
        end.compact
    end

    respond_to do |format|
      format.html do
        @result_types = fetch_categories('Release')
      end

      format.js
    end
  end

  private

  def find_organization_by_name(name)
    Organization.find_by_name(params[:organization_name]) || not_found
  end

  def find_organization_repos_by_name(organization, name)
    organization.repos.find_by_name(name)
  end

  def find_repo_benchmark_type_by_category(category)
    @repo.benchmark_types.find_by_category(category)
  end

  def fetch_benchmark_runs(initiators, initiator_type, form_result_type)
    BenchmarkRun
      .initiators(initiators.map(&:id), initiator_type)
      .preload(:initiator)
      .joins(:benchmark_type)
      .where('benchmark_types.category = ?', form_result_type)
  end

  def fetch_categories(initiator_type)
    BenchmarkType
      .where(repo: @repo)
      .joins(:benchmark_runs)
      .where(benchmark_runs: { initiator_type: initiator_type })
      .uniq
      .pluck(:category)
      .select { |category| category if !category.match(/memory\Z/) }
      .group_by { |category| category =~ /\A([^_]+)_/; $1 }
  end
end
