#!/usr/bin/ruby

require 'rubygems'
require 'awesome_print'
require 'active_support/time'
require 'whenever'
require 'json'
require 'time'
require 'digest/md5'

h = Hash.new

loop do
  t  = Time.now
  t2 = Time.now + 7*60*60 


  i_time = t2.strftime("%Y.%m.%d.%H")

  url    =  "http://logs.blurb.com:9200/logstash-#{i_time}/_search?pretty"
  output = `curl -s -XGET #{url} -d @request.http`

  data   = JSON.parse(output)

  data['hits']['hits'].each do |child|

      client = child['_source']['client']
      h_time = child['_source']['timestamp']
      server = child['_source']['logsource']
      path   = child['_source']['URI']
      status = child['_source']['status_code']
      bytes  = child['_source']['bytes']

      time   = Time.parse(h_time).to_i

      unless bytes.nil?
        line   = "#{time}|#{client}|#{path}|#{status}|#{bytes}"
	secret  = Digest::MD5.hexdigest(line)
        if ! h.has_key?(line) 
          h[line] = Time.now.to_i
        end
 #       puts line
      end
  end


#ap h

#puts h.size

  h.each do |key,value| 

    delete_time = Time.now.to_i - 30
    if value < delete_time
      puts key
      h.delete(key)
    end

  end


  sleep(t + 4 - Time.now)

end
