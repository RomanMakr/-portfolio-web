.PHONY: help create-platform get run analyze test build clean
API_BASE_URL ?= http://localhost:8080

help:
	@echo "Targets: create-platform get run analyze test build clean"

create-platform:
	flutter create --platforms=web .

get:
	flutter pub get

run:
	flutter run -d chrome --web-port=5000 --dart-define=API_BASE_URL=$(API_BASE_URL)

analyze:
	flutter analyze

test:
	flutter test

build:
	flutter build web --release --dart-define=API_BASE_URL=$(API_BASE_URL)

clean:
	flutter clean
