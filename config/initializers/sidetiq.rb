Dir["#{Rails.root}/app/jobs/scheduled/*"].each {|file| require_dependency file }
