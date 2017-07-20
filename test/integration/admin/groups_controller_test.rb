require 'test_helper'

class Admin::GroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group = create(:group)
  end

  test "should get index" do
    get admin_groups_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_group_url
    assert_response :success
  end

  test "should create group" do
    assert_difference('Group.count') do
      post admin_groups_url, params: { group: { name: 'Group' } }
    end

    assert_redirected_to admin_groups_url
  end

  test "should get edit" do
    get edit_admin_group_url(@group)
    assert_response :success
  end

  test "should update group" do
    patch admin_group_url(@group), params: { group: { name: 'Renamed group' } }
    assert_redirected_to admin_groups_url
  end

  test "should destroy group" do
    assert_difference('Group.count', -1) do
      delete admin_group_url(@group)
    end

    assert_redirected_to admin_groups_url
  end
end
