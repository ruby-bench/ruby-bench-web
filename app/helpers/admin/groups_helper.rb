module Admin::GroupsHelper
  def group_panel_html(group)
    "
    <div class='col-lg-6'>
      <div class='panel panel-default'>
        <div class='panel-heading'>
          #{group.name}
        </div>
        <div class='panel-body'>
          <p><i>#{description_for(group)}</i></p>
          <ul>
            #{benchmark_types_from(group)}
          </ul>
        </div>
        <div class='panel-footer'>
          #{edit_link(group)}
          #{destroy_link(group)}
        </div>
      </div>
    </div>
    ".html_safe if group.present?
  end

  private

  def description_for(group)
    if group.description.present?
      group.description
    else
      'No description provided'
    end
  end

  def benchmark_types_from(group)
    benchmark_list = ''
    group.benchmark_types.each do |benchmark_type|
      benchmark_list << "<li>#{benchmark_type.category}</li>\n"
    end

    benchmark_list
  end

  def edit_link(group)
    link_to(edit_admin_group_path(group), class: 'btn btn-default btn-circle') do
      '<i class="fa fa-pencil"></i>'
    end
  end

  def destroy_link
    link_to(destroy_admin_group_path(group), class: 'btn btn-danger btn-circle') do
      '<i class="fa fa-times"></i>'
    end
  end

  def destroy_link(group)

  end
end
