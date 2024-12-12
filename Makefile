serve:
	bundle exec -- jekyll serve --host 0.0.0.0 --port 8080

build:
	bundle exec -- jekyll build

push: build
	git push -v origin

