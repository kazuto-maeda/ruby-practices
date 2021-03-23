class ApiClient
  attr_accessor :connection, :url

  def initialize(url:)
    self.connection = Faraday.new(url: url)
  end

  def do_request(method, path, params = {}, response_head_parse)
    unparsed_response = connection.public_send(
      method,
      path,
      params
    )

    parse_response(unparsed_response.body)
  end

  def get(path, params, response_head_parse = false)
    do_request('get', path, params, response_head_parse)
  end

  def post(path, params, response_head_parse = false)
    do_request('post', path, params, response_head_parse)
  end

  def patch(path, params, response_head_parse = false)
    do_request('patch', path, params, response_head_parse)
  end

  def delete(path, response_head_parse = false)
    do_request('delete', path, response_head_parse)
  end

  def parse_response(body)
    JSON.parse(body, {symbolize_names: true})
  end
end
