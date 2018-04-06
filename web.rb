get '/' do
  haml :index, layout: :layout
end

post '/step1' do
  redirect_uri = URI.parse(params[:instance])
  redirect_uri.path = '/oauth/authorize'

  s = []
  s << 'read' if params[:scope_read]
  s << 'write' if params[:scope_write]
  s << 'follow' if params[:scope_follow]

  q = { response_type: 'code',
        client_id: params[:client_key],
        redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
        scope: s.join(' ')
      }
  redirect_uri.query = q.map do |k, v|
    "#{CGI.escape k.to_s}=#{CGI.escape v}"
  end.join('&')

  haml :step1,
       layout: :layout,
       locals: {
         instance_base: params[:instance],
         redirect_uri: redirect_uri,
         client_key: params[:client_key],
         client_secret: params[:client_secret]
       }
end

post '/step2' do
  token_uri = URI.parse(params[:instance])
  token_uri.path = '/oauth/token'

  q = {
    client_id: params[:client_key],
    client_secret: params[:client_secret],
    redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
    grant_type: 'authorization_code',
    code: params[:auth_code]
  }

  req_body = q.map do |k, v|
    "#{CGI.escape k.to_s}=#{CGI.escape v}"
  end.join('&')


  resp = Net::HTTP.post token_uri, req_body

  j = JSON.parse resp.body

  haml :step2, layout: :layout, locals: {
         raw_body: resp.body,
         parsed_json: j
       }
end


get '/css' do
  sass :css
end
