## Introduction

GDS-SSO provides everything needed to integrate an application with the sign-on-o-tron single-sign-on
(https://github.com/alphagov/sign-on-o-tron) as used by the Government Digital Service, though it
will probably also work with a range of other oauth2 providers.

It is a wrapper around omniauth that adds a 'strategy' for oAuth2 integration against sign-on-o-tron,
and the necessary controller to support that request flow.

For more details on OmniAuth and oAuth2 integration see https://github.com/intridea/omniauth


## Integration with a Rails 3+ app

To use gds-sso tou will need an oauth client ID and secret for sign-on-o-tron or a compatible system.
These can be provided by one of the team with admin access to sign-on-o-tron.

Then include the gem in your Gemfile:

gem 'gds-sso', :git => 'https://github.com/alphagov/gds-sso.git'

Create a `config/initializers/gds-sso.rb` that looks like:

    GDS::SSO.config do |config|
      config.user_model   = 'User'

      # set up ID and Secret in a way which doesn't require it to be checked in to source control...
      config.oauth_id     = ENV['OAUTH_ID']
      config.oauth_secret = ENV['OAUTH_SECRET']

      # optional config for location of sign-on-o-tron
      config.oauth_root_url = "http://localhost:3001"

      # optional config for API Access (requests which accept application/json)
      config.basic_auth_user = 'api'
      config.basic_auth_password = 'secret'
    end

The user model needs to respond to klass.find_by_uid(uid), and must include the GDS::SSO::User module.

You also need to include `GDS::SSO::ControllerMethods` in your ApplicationController

## Use in development mode

In development, you generally want to be able to run an application without needing to run your own SSO server to be running as well. GDS-SSO facilitates this by using a 'mock' mode in development. Mock mode loads an arbitrary user from the local application's user tables:

    GDS::SSO.test_user || GDS::SSO::Config.user_klass.first

To make it use a real strategy (e.g. if you're testing an app against the signon server), set an environment variable when you run your app:

    GDS_SSO_STRATEGY=real bundle exec rails s 

