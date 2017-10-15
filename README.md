# new-project-template
Rails 5 template based on http://guides.rubyonrails.org/rails_application_templates.html

### usage

first, ensure that you're using the right ruby version:

```
rbenv shell 2.4.2
```

next, build the project:

```
rails new myapp -m ~/new-project-template/template.rb -d postgresql -T --skip-turbolinks --webpack=react
```

### prod setup

- Install postgres, redis, newrelic, rollbar, papertrail
- If needed: sendgrid
- Set ENV:
  - `APP_ENV`: production
  - `CANONICAL_HOST`: www.yoursite.com
  - `ROLLBAR_ENABLED`: true
