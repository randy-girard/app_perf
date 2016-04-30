# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

@@server_already_running = false

if Rails.env.development?
  task :start_database_if_not_running do
    running = `pg_ctl status -D #{Rails.root}/db/development -o '-p 5443'`
    if running.to_s =~ /server is running/
      @@server_already_running = true
    else
      system("pg_ctl -D #{Rails.root}/db/development -o '-p 5443' start")
      sleep 3
    end
  end

  task :stop_database_if_running do
    at_exit {
      unless @@server_already_running
        running = `pg_ctl status -D #{Rails.root}/db/development -o '-p 5443'`
        if running.to_s =~ /server is running/
          `pg_ctl -D #{Rails.root}/db/development -m fast -o '-p 5443' stop`
        end
      end
    }
  end

  Rake::Task["environment"].enhance [:start_database_if_not_running, :stop_database_if_running]
end
