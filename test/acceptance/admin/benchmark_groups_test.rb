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

  test 'Admin should be able to update benchmark group' do
    benchmark_types = create_list(:benchmark_type, 5)
    group = create(:group)
    group.benchmark_types << benchmark_types.first(3)

    visit edit_admin_group_path(group)

    assert_equal page.find('#group_name').value, group.name
    assert_equal page.find('#group_description').value, group.description
    group.benchmark_types.each do |benchmark_type|
      assert page.has_checked_field?("group_benchmark_type_ids_#{benchmark_type.id}")
    end

    group_name = 'New awesome group name'
    group_description = 'This is not chat group'
    fill_in('Name', with: group_name)
    fill_in('Description', with: group_description)
    group.benchmark_types.each do |benchmark_type|
      uncheck(benchmark_type.category)
    end
    benchmark_types.last(2).each do |benchmark_type|
      check(benchmark_type.category)
    end

    click_on('Update Group')

    group = Group.find(group.id)
    assert_equal group.name, group_name
    assert_equal group.description, group_description
    assert_equal group.benchmark_types.to_a.sort, benchmark_types.last(2).sort
  end

  test 'Admin should be able to destroy benchmark groups' do
    group = create(:group)

    visit admin_groups_path

    assert_difference('Group.count', -1) do
      find("#destroy_#{group.id}").click
    end
  end
end
