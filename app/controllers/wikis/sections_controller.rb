class Wikis::SectionsController < Wikis::BaseController

=begin
  # we want to use the update method from app/controllers/common/wiki.rb PUT
  # plain - clicked save/cancel/break lock on edit tab, section = nil. redirect
  # to show on save, render edit on break lock
  # xhr - clicked save/cancel on inline editor, section = 'somesection'.  rjs
  # replace #wiki_html with wiki.body_html
  def update
    # no RESTful routing for now unfortunately
    if request.get?
      redirect_to_show
      return
    end

    @editing_section = desired_locked_section

    # setup the updated data from visual editor if needed
    if params[:wiki]
      params[:wiki][:body] = html_to_greencloth(params[:wiki][:body_html]) if params[:wiki][:body_html].any?
    end

    if params[:break_lock]
      @wiki.unlock!(desired_locked_section, current_user, :break => true) if params[:break_lock]
      acquire_desired_locked_section!
    elsif params[:cancel]
      release_current_locked_section!
      @update_completed = true
    else
      # update wiki body data
      # get the lock we need if we don't have it
      acquire_desired_locked_section!

      # no version checking for sections
      version = (current_locked_section == :document) ? params[:wiki][:version] : nil

      # do the update (will either create a new version or will update the latest version with new data)
      @wiki.update_section!(current_locked_section, current_user, version, params[:wiki][:body])

      current_user.updated(@page)

      # everything went well
      # drop whatever lock we have
      release_current_locked_section!
      # no errors
      @update_completed = true
    end

  rescue WikiLockError => exc
  rescue ActiveRecord::StaleObjectError => exc
    # this exception is created by optimistic locking.
    # it means that wiki or wiki locks has change since we fetched it from the database
    error :locking_error.t
  ensure
    render_update_outcome unless request.get?
  end
=end

=begin
  # if the user has a section locked, redirect them to edit
  def force_save_or_cancel
    if current_locked_section == :document
      info save_or_cancel_edit_lock_wiki_error_text
      redirect_to_edit
    end
  end

  def ensure_desired_locked_section_exists
    begin
      @wiki.get_body_for_section(desired_locked_section)
    rescue Exception => exc
      error exc.to_s
      @editing_section = nil
      @update_completed = true
      render_or_redirect_to_updated_wiki_html
      return false
    end
  end

  ### LOCKS
  # if we're trying to update some section, but we have a lock for a different
  # section so we should drop the different section
  def release_old_locked_section!
    release_current_locked_section! if has_wrong_locked_section?
  end

  # unlock the current section we have locked  (if we have something locked)
  def release_current_locked_section!
    @wiki.unlock!(current_locked_section, current_user) if current_locked_section
  end

  # if we're trying to edit or update a particular section, this will try to gain the lock
  # unless we already have it
  def acquire_desired_locked_section!
    @wiki.lock!(desired_locked_section, current_user) unless has_desired_locked_section?
  end

  # returns the section for which which the current_user has a lock (or nil)
  def current_locked_section
    @wiki.section_edited_by(current_user) if logged_in? && @wiki
  end

  # returns the section the current user needs to acquire (trying to update or edit)
  def desired_locked_section
    params[:section] || :document
  end

  # returns true if user has the lock they need to modify the section they want to modify
  def has_desired_locked_section?
    current_locked_section == desired_locked_section
  end

  # returns true only if user has some lock, which happens to be the wrong lock
  def has_wrong_locked_section?
    current_locked_section && (current_locked_section != desired_locked_section)
  end

  # returns true if the user desires to edit some section
  # which is not :document
  def show_inline_editor?
    @editing_section && @editing_section != :document
  end

  ### HELPER METHODS
  def save_or_cancel_edit_lock_wiki_error_text
    I18n.t(:save_or_cancel_edit_lock_wiki_error, {:save_button => I18n.t(:save_button), :cancel_button => I18n.t(:cancel_button)})
  end
=end
end