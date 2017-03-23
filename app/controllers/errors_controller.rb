class ErrorsController < ApplicationController
	def show
	  errors = { '400' => 'Bad Request', '404' => 'Not Found', '403' => 'Forbidden', '422' => 'Unprocessable Entity',
	             '502' => 'Bad Gateway', '503' => 'Service Unavailable', '500' => 'internal error' }
	  respond_to do |format|
	  	@error_code = params[:error_code] || '999'
	  	@error = errors[@error_code] || 'Something went wrong'
	    format.html { render template: 'errors/error', layout: 'layouts/application', status: @error_code }
	  end
	end

end