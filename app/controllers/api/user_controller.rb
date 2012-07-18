class Api::UserController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_user_update_permission

  def update
    user_json = JSON.parse(request.body.read)['user']
    oauth_hash = build_gds_oauth_hash(user_json)
    GDS::SSO::Config.user_klass.find_for_gds_oauth(oauth_hash)
    head :success
  end

  private
    # This should mirror the object created by the omniauth-gds strategy/gem
    # By doing this, we can reuse the code for creating/updating the user
    def build_gds_oauth_hash(user_json)
      OmniAuth::AuthHash.new(
          uid: user_json['uid'], 
          provider: 'gds', 
          info: { 
            name: user_json['name'], 
            email: user_json['email']
          }, 
          extra: { 
            user: { permissions: user_json['permissions'] }
          })
    end

    def require_user_update_permission
      authorise_user!(GDS::SSO::Config.default_scope, "user_update_permission")
    end
end
