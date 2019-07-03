class UserScriptsController < ApplicationController
  before_action :ensure_trusted, except: :index

  def index
    if !current_user
      session[:destination_url] = request.fullpath
    elsif !current_user.trusted
      render status: 403
    end
  end

  def create
    bench = UserBench.new(
      params[:name],
      params[:url],
      params[:sha],
      params[:sha2]
    )
    bench.validate!
    if bench.valid?
      bench.run

      render plain: t('.index.successful_submit', path: "/ruby/ruby/commits?result_type=#{bench.name}")
    else
      render plain: bench.errors.join("\n"), status: 422
    end
  end

  private

  def ensure_trusted
    if !current_user || !current_user.trusted
      render plain: "Not allowed to post scripts", status: 403
    end
  end
end
