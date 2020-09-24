build:
	TAG=`git rev-parse --short=8 HEAD`; \
	docker build --rm -f deploy-vcenter-event-broker.dockerfile -t fcarta29/deploy-vcenter-event-broker:$$TAG .; \
	docker tag fcarta29/deploy-vcenter-event-broker:$$TAG fcarta29/deploy-vcenter-event-broker:latest

clean:
	docker stop deploy-vcenter-event-broker
	docker rm deploy-vcenter-event-broker

rebuild: clean build

push:
	TAG=`git rev-parse --short=8 HEAD`; \
	docker push fcarta29/deploy-vcenter-event-broker:$$TAG; \
	docker push fcarta29/deploy-vcenter-event-broker:latest

run:
	docker run --name deploy-vcenter-event-broker -td fcarta29/deploy-vcenter-event-broker:latest
	docker exec -it deploy-vcenter-event-broker bash -l
join:
	docker exec -it deploy-vcenter-event-broker bash -l

default: build
