class StaticPagesController < ApplicationController
  def sponsors
    @sponsors = Sponsors.all
  end
end
