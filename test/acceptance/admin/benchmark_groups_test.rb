require 'acceptance/test_helper'

class BenchmarkGroupsTest < AcceptanceTest
  test 'Admin should be able to see all benchmark groups' do
    group_count = 5
    create_list(:group, group_count)

    visit admin_groups_path

    assert page.has_css?('.panel', count: group_count)
  end

  test 'Admin should be able to create benchmark groups' do
    benchmark_types = create_list(:benchmark_type, 5)
    group_name = 'scope_all'

    visit admin_groups_path

    click_on('New group')

    fill_in('Name', with: group_name)
    fill_in('Description', with: 'This group is intended to compare scope_all across all flavors')
    benchmark_types.first(3).each do |benchmark_type|
      check(benchmark_type.category)
    end

    assert_difference('Group.count') do
      click_on('Create')
    end
    assert_equal Group.last.benchmark_types, benchmark_types.first(3)
    assert page.has_content?("#{group_name} group was successfully created.")
  end

  test 'Admin should be able to update benchmark groups' do

  end

  test 'Admin should be able to destroy benchmark groups' do

  end
end
