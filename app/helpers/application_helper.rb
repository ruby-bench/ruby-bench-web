module ApplicationHelper
  def current_user
    return @current_user if @current_user
    user = session[:user] || {}
    if user[:external_id].present? || user["external_id"].present?
      @current_user = OpenStruct.new(user)
    end
  end
end
