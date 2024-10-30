start:
	localstack start -d

run-rm:
	docker run --rm -t -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack

freeze:
	pip freeze > requirements.txt

install:
	pip install -r requirements.txt


ls-buckets:
	awslocal s3api list-buckets

mk-bucket:
	awslocal s3 mb s3://test-bucket


tf-init:
	tflocal -chdir=infra init

tf-plan:
	tflocal -chdir=infra plan

tf-apply:
	tflocal -chdir=infra apply
