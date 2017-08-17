namespace :repos do
  desc 'Create ruby-pg repo within ged organization'
  task create_ruby_pg: :environment do
    ActiveRecord::Base.transaction do
      organization = Organization.create(name: 'ged', url: 'https://github.com/ged/')
      repo = Repo.create(name: 'ruby-pg', url: 'https://github.com/ged/ruby-pg', organization_id: organization.id)
    end

    puts ' All done now!'
  end
end
