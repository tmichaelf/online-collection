namespace :users do
  desc "Give an account admin access: bin/rails \"users:grant_admin[username or email]\""
  task :grant_admin, [ :login ] => :environment do |_task, args|
    user = find_user!(args[:login])
    user.update!(admin: true)
    puts "#{user.username} (#{user.email_address}) is now an admin."
  end

  desc "Take admin access away from an account: bin/rails \"users:revoke_admin[username or email]\""
  task :revoke_admin, [ :login ] => :environment do |_task, args|
    user = find_user!(args[:login])
    user.update!(admin: false)
    puts "#{user.username} (#{user.email_address}) is no longer an admin."
  end

  def find_user!(login)
    abort "Give a username or email address, for example: bin/rails \"users:grant_admin[michael]\"" if login.blank?

    User.find_by(username: login.strip.downcase) || User.find_by(email_address: login.strip.downcase) ||
      abort("No account with the username or email address #{login.inspect}.")
  end
end
