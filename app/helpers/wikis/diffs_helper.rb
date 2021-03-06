module Wikis::DiffsHelper

  # some translations still have the %{user} and %{when} key.
  # TODO clean them up and remove params here.
  def comparing_changes_header
    :comparing_changes_header.t :old_version => old_version_tag,
      :new_version => new_version_tag,
      :user => content_tag(:b, link_to_user(@new.user)),
      :when => content_tag(:i, full_time(@new.updated_at))
  end

  def old_version_tag
    content_tag :del, short_description(@old, true),
      :class => 'diffmod', :style => 'padding: 1px 4px;'
  end

  def new_version_tag
    content_tag :ins, short_description(@new, true),
      :class => 'diffins', :style => 'padding: 1px 4px;'
  end

  def diff_previous_link
    if previous = @old.previous
      link_to_remote LARROW + :prev_change.t,
        :url => wiki_diff_path(@wiki, @old.diff_id),
        :method => :get
    else
      content_tag :span, LARROW + :prev_change.t, :class => 'disabled'
    end
  end

  def diff_next_link
    if next_version = @new.next
      link_to_remote :next_change.t + RARROW,
        :url => wiki_diff_path(@wiki, next_version.diff_id),
        :method => :get
    else
      content_tag :span, :next_change.t + RARROW, :class => 'disabled'
    end
  end
end
