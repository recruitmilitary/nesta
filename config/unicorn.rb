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

before_exec do |server|
  paths = (ENV["PATH"] || "").split(File::PATH_SEPARATOR)
  paths.unshift "#{shared_bundler_gems_path}/bin"
  ENV["PATH"] = paths.uniq.join(File::PATH_SEPARATOR)

  ENV['GEM_HOME'] = ENV['GEM_PATH'] = shared_bundler_gems_path
  ENV['BUNDLE_GEMFILE'] = "#{working_directory}/Gemfile"
end
