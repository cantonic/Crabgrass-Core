require File.dirname(__FILE__) + '/../../test_helper'

class Groups::GroupsControllerTest < ActionController::TestCase

  def setup
    @user = User.make
  end

  def test_new_group_requires_login
    get :new
    assert_login_required
  end

  def test_new_group
    login_as @user
    assert_permission :may_create_group? do
      get :new
    end
    assert_response :success
  end

  def test_create_group
    login_as @user
    assert_difference 'Group.count' do
      assert_permission :may_create_group? do
        post :create, :group => {:name => 'test-create-group', :full_name => "Group for Testing Group Creation!"}
      end
      assert_response :redirect
      group = Group.find_by_name 'test-create-group'
      assert_redirected_to group_url(group)
    end
  end

  def test_create_no_group_without_name
    login_as @user
    assert_no_difference 'Group.count' do
      post :create, :group => {:name => ''}
      assert_error_message
    end
  end

  def test_create_no_group_with_duplicate_name
    Group.make(:name => 'flowers')
    login_as @user
    assert_no_difference 'Group.count' do
      post :create, :group => {:name => 'flowers'}
      assert_error_message
    end
  end

#  def test_destroy_group
#    user = User.make
#    group = Group.make
#    group.add_user!(user)
#    login_as user
#    assert_difference 'Group.count', -1 do
#      assert_permission :may_destroy_group? do
#        delete :destroy, :id => group.name
#      end
#    end
#  end

end

