set :stages, %w(staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "search-and-employ"
set :repository,  "git://github.com/recruitmilitary/nesta.git"

set :deploy_to, "/home/deploy/public_html/#{application}"

set :port, 4242

set :user, "deploy"
set :use_sudo, false

set :scm, :git
set :deploy_via, :remote_cache
set :git_enable_submodules, true

role :web, "web1.recruitmilitary.com"
role :app, "web1.recruitmilitary.com"
role :db,  "web1.recruitmilitary.com", :primary => true

ssh_options[:keys] = [File.expand_path("~/.ssh/id_dsa"), File.expand_path("~/.ssh/id_rsa")]
ssh_options[:forward_agent] = true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Symlinks the database.yml"
  task :symlink_config, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/config.yml #{release_path}/config/config.yml"
  end
end

after 'deploy:update_code', 'deploy:symlink_config'
