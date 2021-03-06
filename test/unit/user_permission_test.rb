require File.dirname(__FILE__) + '/test_helper'

class UserPermissionTest < ActiveSupport::TestCase

  def setup
    @me = User.make
  end

  def test_defaults
    assert @me.has_access? :view, @me.friends
    assert @me.has_access? :request_contact, @me.peers
    assert !@me.has_access?(:see_groups, :public)
    assert !@me.has_access?(:see_groups, @me.peers)
    assert @me.has_access?(:see_groups, @me.friends)
  end

  def test_setting_defaults
    original_permissions = Conf.default_user_permissions
    Conf.default_user_permissions['peers'] = ['see_contacts']
    @you = User.make
    assert @you.has_access? :see_contacts, @you.peers
    assert !@me.has_access?(:see_contacts, @me.peers)
    assert !@you.has_access?(:request_contact, @you.peers)
    assert @me.has_access?(:request_contact, @me.peers)
    Conf.default_user_permissions = original_permissions
  end

  def test_dependencies
    @me.revoke! @me.friends, :view
    assert !@me.has_access?(:view, @me.friends)
    @me.grant! :public, :view
    assert @me.has_access? :view, @me.friends
    assert @me.has_access? :view, @me.peers
    @me.revoke! @me.friends, :view
    assert !@me.has_access?(:view, :public)
    assert @me.has_access? :view, @me.peers
  end
end
