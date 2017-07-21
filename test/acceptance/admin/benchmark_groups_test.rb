require 'acceptance/test_helper'

class BenchmarkGroupsTest < AcceptanceTest
  test 'Admin should be able to see all benchmark groups' do
    group_count = 5
    create_list(:group, group_count)

    visit admin_groups_path

    assert page.has_css?('.panel', count: group_count)
  end
end
