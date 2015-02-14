class StaticPagesController < ApplicationController
  def homepage
    @repos = Repo.all
  end

  def sponsors
    @sponsors = %i(jolly_good_code discourse rubytune)
  end
end
