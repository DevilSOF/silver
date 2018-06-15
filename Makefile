RAILS_ENV ?= development
PROJECT_NAME := silver
RUN := run --rm
DOCKER_COMPOSE := docker-compose --project-name $(PROJECT_NAME)
DOCKER_COMPOSE_RUN := $(DOCKER_COMPOSE) $(RUN)
WEB_CONCURRENCY := 0

default: bin-rspec

bin-rspec:
	bin/rspec

provision: bundle db-migrate

up:
	rm -f tmp/pids/server.pid && ${DOCKER_COMPOSE} up

api:
	${DOCKER_COMPOSE_RUN} --service-ports -e "WEB_CONCURRENCY=${WEB_CONCURRENCY}" api

db-prepare: db-create db-migrate

db-create:
	${DOCKER_COMPOSE_RUN} -e "RAILS_ENV=${RAILS_ENV}" app bundle exec rake db:create

db-drop:
	${DOCKER_COMPOSE_RUN} -e "RAILS_ENV=${RAILS_ENV}" app bundle exec rake db:drop

db-migrate:
	${DOCKER_COMPOSE_RUN} -e "RAILS_ENV=${RAILS_ENV}" app bundle exec rake db:migrate

db-seed:
	${DOCKER_COMPOSE_RUN} -e "RAILS_ENV=${RAILS_ENV}" app bundle exec rake db:seed

db-rollback:
	${DOCKER_COMPOSE_RUN} -e "RAILS_ENV=${RAILS_ENV}" app bundle exec rake db:rollback

db-console:
	${DOCKER_COMPOSE_RUN} -e "RAILS_ENV=${RAILS_ENV}" app bundle exec rails dbconsole

rails-console:
	${DOCKER_COMPOSE_RUN} -e "RAILS_ENV=${RAILS_ENV}" app bundle exec rails c

bash:
	${DOCKER_COMPOSE_RUN} -e "RAILS_ENV=${RAILS_ENV}" app bash

compose:
	${DOCKER_COMPOSE} ${CMD}

down:
	${DOCKER_COMPOSE} down

down-v:
	${DOCKER_COMPOSE} down -v

rails-generate:
	${DOCKER_COMPOSE_RUN} app bundle exec rails g ${CMD}

bundle:
	${DOCKER_COMPOSE_RUN} app bundle ${CMD}

test:
	${DOCKER_COMPOSE_RUN} -e "RAILS_ENV=test" app bundle exec rspec ${T}

psql:
	${DOCKER_COMPOSE} exec db psql --user postgres -d silver_${RAILS_ENV}

psql2:
	${DOCKER_COMPOSE_RUN} app psql postgresql://postgres@db/silver_${RAILS_ENV}

build:
	${DOCKER_COMPOSE} build

rebuild:
	${DOCKER_COMPOSE} build --force-rm

rubocop:
	${DOCKER_COMPOSE_RUN} app rubocop

docs:
	RAILS_ENV=test make provision
	${DOCKER_COMPOSE_RUN} -e "RAILS_ENV=test" app bundle exec rake docs:generate
