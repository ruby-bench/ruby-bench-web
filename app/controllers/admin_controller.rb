class AdminController < ApplicationController
  http_basic_authenticate_with(
    name: 'admin',
    password: Rails.application.secrets.admin_password
  )

  def index
    @organizations = Organization.includes(repos: [:commits, :releases]).all
  end

   def next
     if params[:result_type] && params[:admin][:releases_type]
       @output = `sudo docker run --rm \
         -e "RUBY_BENCHMARKS=true" \
         -e "RUBY_MEMORY_BENCHMARKS=true" \
         -e "RUBY_VERSION= #{params[:admin][:releases_type]}" \
         -e "API_NAME=#{Rails.application.secrets.api_name}" \
         -e "API_PASSWORD=#{Rails.application.secrets.api_password}" \
         -e "INCLUDE_PATTERNS= #{params[:result_type]}"  rubybench/ruby_releases`
     end
   end

  def show_releases
   @organization = Organization.find_by_name(params[:organization_name]) || not_found
   @repo = @organization.repos.find_by_name(params[:repo_name]) || not_found

    respond_to do |format|
      format.html do
        @result_types = fetch_categories
        @releases_types = fetch_releases
      end

      format.js
    end
  end

  private

  def fetch_categories
    @repo.benchmark_types.pluck(:category)
  end

  def fetch_releases
    @repo.releases.pluck(:version)
  end
end
