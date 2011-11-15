# unicorn_rails -c /home/deploy/public_html/board/current/config/unicorn.rb -E production -D

ENV['HOME'] ||= '/home/deploy'

rails_env = ENV['RAILS_ENV'] || 'production'
deploy_to = '/home/deploy/public_html/search-and-employ'
working_directory = "#{deploy_to}/current"
shared_path = "#{deploy_to}/shared"
shared_bundler_gems_path = "#{shared_path}/bundle"

worker_processes 1

# Restart any workers that haven't responded in 60 seconds
timeout 30

# Listen on a Unix data socket
listen "#{working_directory}/tmp/sockets/unicorn.sock", :backlog => 2048

stdout_path "#{working_directory}/log/unicorn.log"
stderr_path "#{working_directory}/log/unicorn-error.log"

##
# REE
# http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.

  old_pid = Rails.root.join('tmp/pids/unicorn.pid.oldbin')
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  addr = "127.0.0.1:#{9293 + worker.nr}"
  server.listen(addr, :tries => -1, :delay => 5, :tcp_nopush => true)

  ##
  # Unicorn master is started as root, which is fine, but let's
  # drop the workers to deploy:deploy

  begin
    uid, gid = Process.euid, Process.egid
    user, group = 'deploy', 'deploy'
    target_uid = Etc.getpwnam(user).uid
    target_gid = Etc.getgrnam(group).gid
    worker.tmp.chown(target_uid, target_gid)
    if uid != target_uid || gid != target_gid
      Process.initgroups(user, target_gid)
      Process::GID.change_privilege(target_gid)
      Process::UID.change_privilege(target_uid)
    end
  rescue => e
    if rails_env == 'development'
      STDERR.puts "couldn't change user, oh well"
    else
      raise e
    end
  end
end

before_exec do |server|
  paths = (ENV["PATH"] || "").split(File::PATH_SEPARATOR)
  paths.unshift "#{shared_bundler_gems_path}/bin"
  ENV["PATH"] = paths.uniq.join(File::PATH_SEPARATOR)

  ENV['GEM_HOME'] = ENV['GEM_PATH'] = shared_bundler_gems_path
  ENV['BUNDLE_GEMFILE'] = "#{working_directory}/Gemfile"
end
