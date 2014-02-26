require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params = route_params
              .merge(parse_www_encoded_form(req.body))
              .merge(parse_www_encoded_form(req.query_string))
    @permitted_keys = []
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    keys.each do |key|
      @permitted_keys << key
    end
  end

  def require(key)
    raise Params::AttributeNotFoundError if @params[key].nil?
  end

  def permitted?(key)
    @permitted_keys.include?(key)
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    return {} if www_encoded_form.blank?
    args = URI.decode_www_form(www_encoded_form)
    main_hash = {}
    
    args.each do |keys_val|
      keys_list = parse_key(keys_val.first)
      first_key = keys_list.shift
      
      if keys_list.empty?
        main_hash[first_key] = keys_val.last.chomp
        next
      end
      
      main_hash[first_key] ||= {}
      subhash = main_hash[first_key]
      
      until keys_list.empty?
        key = keys_list.shift
        
        if keys_list.empty?
          subhash[key] = keys_val.last.chomp
        else
          subhash[key] ||= {}
          subhash = subhash[key]
        end
      end
      
    end
    main_hash
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.scan(/\w+/)
  end
end
