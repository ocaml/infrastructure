serve:
	bundle exec -- jekyll serve --host 0.0.0.0

build:
	bundle exec -- jekyll build

push: build
	git push -v origin

