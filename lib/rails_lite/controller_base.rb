require 'erb'
require 'active_support/inflector'
require 'active_support/core_ext'
require_relative 'params'
require_relative 'session'
require 'debugger'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise Exception if already_rendered?
    @res.body = content
    @res.content_type = type
    @already_rendered = true
    session.store_session(@res)
    flash.store_flash(@res)
  end

  # helper method to alias @already_rendered
  def already_rendered?
    @already_rendered ||= false
  end

  # set the response status code and header
  def redirect_to(url)
    raise Exception if already_rendered?
    @res.header["location"] = url
    @res.status = 302
    @already_rendered = true
    session.store_session(@res)
    flash.store_flash(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    text = File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb")
    erb = ERB.new(text)
    
    render_content(erb.result(binding), "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end
  
  def flash
    @flash = Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_rendered? 
  end
end
