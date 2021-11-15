name: CI 
on:
  push:
    branches:
    - main
  pull_request:
    branches:
    - main

jobs:
  rails-rspec:
    runs-on: ubuntu-latest
    
    env:
      RAILS_ENV: test
      DATABASE_URL: "postgres://postgres:postgres@localhost/test_app_test"
    
    services:
      postgres:
        image: postgres:11.6-alpine
        ports:
          - 5432:5432
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        # needed because the postgres container does not provide a healthcheck
        options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5

    steps:
      - name: Checkout Code
        uses: actions/checkout@v1

      - name: Install PostgreSQL 11 client
        run: |
          sudo apt-get -yqq install libpq-dev

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.0.2"
      
      - name: Build App
        run: |
          yarn install
          bundle install
          cp config/database.yml.sample config/database.yml
          bundle exec rails db:setup

      - name: Run RSpec
        run: |
          bundle exec rspec
