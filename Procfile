web: bundle exec passenger start -p $PORT -a 0.0.0.0
worker: bundle exec sidekiq --queue app_perf --verbose
agent: sleep 10 && bundle exec app_perf_agent --license 30b5805c-25d8-4fcd-875e-4fd9be32993e --host localhost:5000
