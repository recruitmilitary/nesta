set :stages, %w(staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set :application, "search-and-employ"
set :repository,  "git://github.com/recruitmilitary/nesta.git"

set :deploy_to, "/home/deploy/public_html/#{application}"

set :port, 4242

set :user, "deploy"
set :use_sudo, false

set :scm, :git
set :deploy_via, :remote_cache
set :git_enable_submodules, true

role :web, "web3.recruitmilitary.com"
role :app, "web3.recruitmilitary.com"
role :db,  "web3.recruitmilitary.com", :primary => true

ssh_options[:keys] = [File.expand_path("~/.ssh/id_dsa"), File.expand_path("~/.ssh/id_rsa")]
ssh_options[:forward_agent] = true

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do
    run "/etc/init.d/search-and-employ start"
  end

  task :stop, :roles => :app, :except => { :no_release => true } do
    run "/etc/init.d/search-and-employ stop"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "/etc/init.d/search-and-employ upgrade"
  end

  desc "symlink sockets"
  task :symlink_sockets, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/sockets #{latest_release}/tmp/sockets"
  end
end

after "deploy:update_code", "deploy:symlink_sockets"
