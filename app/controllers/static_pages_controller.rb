class StaticPagesController < ApplicationController
  def homepage
    @repos = Repo.all
  end

  def sponsors
    @sponsors = %i(ruby_together jolly_good_code discourse rubytune bugsnag)
  end
end
