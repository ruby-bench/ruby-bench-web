module Admin::GroupsHelper
  def description_for(group)
    if group.description.present?
      group.description
    else
      'No description provided'
    end
  end
end
