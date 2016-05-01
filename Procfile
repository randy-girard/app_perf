web: bundle exec puma
db: postgres -D db/development -p 5443 -N 30
#nginx: nginx -p `pwd` -c config/nginx/development.conf
worker: bundle exec sidekiq
