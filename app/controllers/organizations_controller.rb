class OrganizationsController < ApplicationController
  def index
    @organizations = Organization.all
  end

  def show
    @organization = Organization.find_by(name: params[:name])
    @repos = @organization.repos
  end
end
