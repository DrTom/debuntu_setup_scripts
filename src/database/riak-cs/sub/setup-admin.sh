apt-get install -y ruby1.9.3 

/etc/init.d/stanchion restart
/etc/init.d/riak-cs restart

sleep 5

ruby <<'EOF' 

require 'json'
require 'net/http'
require 'rubygems'


req = Net::HTTP::Post.new('/riak-cs/user', initheader = {'Content-Type' =>'application/json'})
req.body = {email:"#{rand}@example.com", name:"admin user #{rand}"}.to_json 
response = Net::HTTP.new('localhost', '8282').start {|http| http.request(req) }
puts "Response #{response.code} #{response.message}: #{response.body}"

data= JSON.parse response.body

access_key= data["key_id"]
secret_key= data["key_secret"]


%w(/etc/riak-cs/app.config /etc/stanchion/app.config).each do |filepath|
  puts "processing #{filepath}"
  s = IO.read(filepath) \
    .gsub(/{admin_key\s*,\s*"\S*"\s*}/, %<{admin_key,"#{access_key}"}>) \
    .gsub(/{admin_secret\s*,\s*"\S*"\s*}/, %<{admin_secret,"#{secret_key}"}>)
  IO.write(filepath,s)
end

IO.write("/etc/profile.d/riak_cs_cred.sh", %<
export RIAK_CS_ACCESS_KEY='#{access_key}'
export RIAK_CS_SECRET_KEY='#{secret_key}'
export RIAK_CS_PORT=8282
>)

puts "Access-Key: #{access_key}"
puts "Secret-Key: #{secret_key}"

EOF

/etc/init.d/stanchion restart
/etc/init.d/riak-cs restart

cat <<'EOF'
Riak cs admin is configured. See and source '/etc/profile.d/riak_cs_cred.sh'.
EOF
