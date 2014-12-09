class StaticPagesController < ApplicationController
  def homepage
    @repos = Repo.all
  end
end
