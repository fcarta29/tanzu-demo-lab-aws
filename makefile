build:
	TAG=`git rev-parse --short=8 HEAD`; \
	docker build --rm -f build-tanzu-demo-lab-aws.dockerfile -t fcarta29/build-tanzu-demo-lab-aws:$$TAG .; \
	docker tag fcarta29/build-tanzu-demo-lab-aws:$$TAG fcarta29/build-tanzu-demo-lab-aws:latest

clean:
	docker stop build-tanzu-demo-lab-aws
	docker rm build-tanzu-demo-lab-aws

rebuild: clean build

run:
# Re-enable this when adding jupyter notebooks back in
	docker run --name build-tanzu-demo-lab-aws -v $$PWD/deploy:/deploy -v $$PWD/config/kube.conf:/root/.kube/config -td fcarta29/build-tanzu-demo-lab-aws:latest
	docker exec -it build-tanzu-demo-lab-aws bash -l

#run-jupyter:
# Re-enable this when adding jupyter notebooks back in
#	docker run -p 8888:8888 --name build-tanzu-demo-lab-aws -td fcarta29/build-tanzu-demo-lab-aws:latest
#	docker exec -it build-tanzu-demo-lab-aws bash -l

join:
	docker exec -it build-tanzu-demo-lab-aws bash -l
start:
	docker start build-tanzu-demo-lab-aws
stop:
	docker stop build-tanzu-demo-lab-aws

default: build
