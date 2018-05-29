web: bundle exec passenger start -p $PORT -a 0.0.0.0
worker: bundle exec sidekiq --queue app_perf --verbose
agent: sleep 10 && bundle exec app_perf_agent --license e47a7331-77cd-4ea0-8be1-b4130255a3a8 --host localhost:5000
