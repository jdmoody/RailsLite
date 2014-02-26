require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    my_cookie = req.cookies.select do |cookie|
      cookie.name == '_rails_lite_app'
    end
    # debugger
    @cookie_hash = (my_cookie.empty? ? {} : JSON.parse(my_cookie.first.value))
  end

  def [](key)
    @cookie_hash[key]
  end

  def []=(key, val)
    @cookie_hash[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    new_cookie = WEBrick::Cookie.new('_rails_lite_app', @cookie_hash.to_json)
    res.cookies << new_cookie
  end
end
