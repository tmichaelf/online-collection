class Admin::NavComponent < ApplicationComponent
  LINKS = {
    "Dashboard" => :admin_root_path,
    "Titles" => :admin_titles_path,
    "Users" => :admin_users_path
  }.freeze

  def call
    tag.nav class: "admin-nav", aria: { label: "Admin" } do
      safe_join(LINKS.map { |label, path| nav_link(label, helpers.public_send(path)) })
    end
  end

  private
    def nav_link(label, path)
      current = path == helpers.admin_root_path ? helpers.current_page?(path) : request.path.start_with?(path)
      link_to label, path, aria: { current: (current ? "page" : nil) }
    end
end
