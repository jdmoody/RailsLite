require 'json'
require 'webrick'

class Session
  # find the flash cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    my_flash_cookie = req.cookies.select do |cookie|
      cookie.name == '_rails_lite_app'
    end
    @flash_cookie_hash = (my_flash_cookie.empty? ? {} :
                          JSON.parse(my_flash_cookie.first.value))
  end

  def [](key)
    @flash_cookie_hash[key]
  end

  def []=(key, val)
    @flash_cookie_hash[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_flash(res)
    new_flash_cookie = WEBrick::Cookie.new('_rails_lite_app', @flash_cookie_hash.to_json)
    res.cookies << new_flash_cookie
  end
end
