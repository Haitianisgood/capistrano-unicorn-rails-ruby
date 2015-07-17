# config valid only for Capistrano 3.1
lock '3.4.0'

set :application, 'cap-test'
set :repo_url, 'git@github.com/haitian/cap-test.git'
#'git@github.com:haitian/test.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app

set :deploy_to, '/data/cap-test'

# Default value for :scm is :git
set :scm, :git

set :unicorn_rack_env, fetch(:rails_env)

# whenever
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml config/env.yml}

# Default value for linked_dirs is []
set :bundle_binstubs, nil
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads vendor/chatroom/node_modules}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke :'unicorn:duplicate'
    end
  end


  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end

  # after "deploy:updated", "newrelic:notice_deployment"

  #

  task :monit do
    # on roles(:app) do |host|
    #   execute "cp #{shared_path}/config/deploy/templates/puma /etc/monit/conf.d/puma"
    # end
    on roles(:web) do |host|
      execute "cp #{deploy_to}/current/config/deploy/templates/nginx /etc/monit/conf.d/nginx"
    end
  end
  task :get_manifest do
    on roles(:web).first do
      within("#{release_path}/public/assets") do
        $manifest_filename = capture :find, "manifest*"
        IO.write(File.join('/tmp', $manifest_filename), capture(:cat, $manifest_filename))
      end
    end
  end

  task :upload_manifest do
    manifest_path = File.join('/tmp/', $manifest_filename)
    if $manifest_filename && File.exists?(manifest_path)
      on roles(:app) do
        execute :mkdir, "-p", "#{release_path}/public/assets"
        upload! manifest_path, File.join("#{release_path}/public/assets", $manifest_filename)
      end
      File.unlink manifest_path
    else
      puts 'no manifest'
    end

  end

  after 'deploy:assets:precompile', 'deploy:get_manifest'
  after 'deploy:get_manifest', 'deploy:upload_manifest'
end
