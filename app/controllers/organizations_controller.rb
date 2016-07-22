class OrganizationsController < ApplicationController
  def index
    @organizations = Organization.includes(repos: [:commits, :releases]).all
  end
end
