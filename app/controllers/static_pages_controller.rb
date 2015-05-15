class StaticPagesController < ApplicationController
  def homepage
    @repos = Repo.all
  end

  def sponsors
    @sponsors = Sponsors.all
  end
end
