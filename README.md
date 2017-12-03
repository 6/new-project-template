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

you can optionally specify the following flags:

- `--api`: if you are building an API-only service
- `--skip-action-cable`, `--skip-action-mailer`: if you don't need certain functionality

### prod setup

- Install postgres, redis, newrelic, rollbar, papertrail
- If needed: sendgrid
- Set ENV:
  - `APP_ENV`: production
  - `CANONICAL_HOST`: www.yoursite.com
  - `FORCE_SSL`: `false` if using Cloudflare Force SSL, `true` otherwise
  - `ROLLBAR_ENABLED`: `true`

### DNS

- SSL: Select `SSL: Full` option
- CNAME: For heroku, use `*.herokuapp.com` instead of provided `herokudns.com`. [See details](https://kb.heroku.com/why-am-i-getting-error-525-ssl-handshake-failed-with-cloudflare-when-using-a-herokudns-com-endpoint)
