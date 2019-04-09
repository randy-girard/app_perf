web: bundle exec rails s -p $PORT
worker: bundle exec sidekiq -C config/sidekiq.yml
agent: sleep 10 && bundle exec app_perf_agent --license 30b5805c-25d8-4fcd-875e-4fd9be32993e --host localhost:5000
