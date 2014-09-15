# Copyright (c) 2008-2014 by Afilias Technologies Limited (dotMobi). All rights reserved.
# Author: dotMobi

# Gem to serialize URIs
require 'cgi'
# Gem to connect with Cloud server
require 'socket'
# Gem to get the operating system's temp directory
require 'tmpdir'
# Gem to encode cache content
require 'json'
# Gem to encode MD5
require 'digest/md5'

##
# Copyright::
# * Copyright (c) 2008-2014 by Afilias Technologies Limited (dotMobi). All rights reserved.
# Author::
# * dotMobi
#
# Class to create multiple instances to connect to the Cloud service.
#
module DeviceAtlasCloudClient
  class Client

  # Class to define the client instance settings.
  class Settings

    # Class to handle the cached server list and device properties from previous
    # requests.
    class Cache

      # Cache expire (for both file and cookie) 2592000 = 30 days in seconds.
      attr_accessor :item_expiry_sec

      # Leave as true to put cache in systems default temp directory.
      attr_accessor :use_system_temp_dir

      # This is only used if :use_system_temp_dir is false.
      attr_accessor :custom_cache_directory

      # Cache name
      attr_accessor :name

      def initialize
        @item_expiry_sec = 2592000
        @use_system_temp_dir = true
        @custom_cache_directory = '/path/to/your/cache/'
        @name = 'deviceatlas_cache'
      end
      
    end

    ########################## BASIC SETUP ##############################

    # Your licence key.
    attr_accessor :licence_key

    # Mode.
    # If true, raise exceptions with errors.
    # Otherwise, just add the exception message to the error field.
    attr_accessor :debug_mode

    # Auto host ranking.
    # If true then server preference is decided by the API
    # (faster server is preferred)
    # If false then server preference is :servers sort order
    # (top server is preferred)
    attr_accessor :auto_server_ranking

    # List of cloud service provider end points.
    # Server preference is decided from this list.
    attr_accessor :servers

    ########################## ADVANCED SETUP ##############################
    # Edit these if you want to tweak API behaviour.

    # Build in test user agent.
    attr_accessor :test_useragent

    # User agent for latency checking.
    attr_accessor :latency_useragent

    # Time (seconds) to wait for each cloud server to give service.
    attr_accessor :cloud_service_timeout

    # Use device data which is created by the DeviceAtlas JS library if exists.
    attr_accessor :use_client_cookie

    # Name of the cookie created by DeviceAtlas Client Side component.
    attr_accessor :client_cookie_name

    # Send extra headers.
    # If true then extra headers are sent with each request to the service.
    # If false then only select headers essential for detection are sent.
    attr_accessor :send_extra_headers

    # When ranking servers, if a server fails more than this number phase it
    # out.
    attr_accessor :auto_server_ranking_max_failures

    # Number of requests to use when testing a server latency.
    attr_accessor :auto_server_ranking_num_requests

    # Server preferred list will be updated when older than this amount of
    # minutes.
    attr_accessor :auto_server_ranking_lifetime

    # If auto ranking = false, then if top server fails it will be phased out
    # for this number of minutes.
    attr_accessor :server_phaseout_lifetime

    # If use_cache = true, device properties will be saved in cache to speed up
    # subsequent requests with the same user-agent.
    attr_accessor :use_cache

    attr_reader :cache # Only in Ruby

    ##
    # Constructor. It initializes all settings with the default values.
    #
    def initialize
      @licence_key = 'ENTER-YOUR-LICENCE-KEY'
      @debug_mode = false
      @auto_server_ranking = true
      @servers = [
          {:host => 'region0.deviceatlascloud.com',  :port => 80},
          {:host => 'region1.deviceatlascloud.com',  :port => 80},
          {:host => 'region2.deviceatlascloud.com',  :port => 80},
          {:host => 'region3.deviceatlascloud.com',  :port => 80}
      ]
      @test_useragent = 'Mozilla/5.0 (Linux; U; Android 2.3.3; en-gb; GT-I9100 Build/GINGERBREAD) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'
      @latency_useragent = 'Ruby'
      @cloud_service_timeout = 3
      @use_client_cookie = true
      @use_cache = true
      @send_extra_headers = false
      @client_cookie_name = 'DAPROPS'
      @auto_server_ranking_max_failures = 1
      @auto_server_ranking_num_requests = 3
      @auto_server_ranking_lifetime = 1440
      @server_phaseout_lifetime = 1440
      @cache = Cache.new # Only exists in Ruby API
    end

  end

  API_VERSION = '1.4'

	# Keys of the array returned by get_device_data()
	KEY_USERAGENT = 'useragent'
	KEY_SOURCE = 'source'
	KEY_ERROR = 'error'
	KEY_PROPERTIES = 'properties'

	# Device data source
	SOURCE_CACHE = 'cache'
	SOURCE_CLOUD = 'cloud'
	SOURCE_NONE = 'none'

	# Headers.
	DA_HEADER_PREFIX = 'X-DA-'
	CLIENT_COOKIE_HEADER = 'Client-Properties'

	# Cloud service.
	CLOUD_PATH = '/v1/detect/properties?licencekey=%s&useragent=%s'

  # Action to be taken after an end-point responds: If an-endpoint response was
  # fine
  FAILOVER_NOT_REQUIRED = 0

  # Action to be taken after an end-point responds: If the error controller
  # returns this the fail-over mechanism must stop trying the next end-point
  FAILOVER_STOP = 1

  # Action to be taken after an end-point responds: If the error controller
  # returns this the fail-over mechanism must try the next end-point
  FAILOVER_CONTINUE = 2

	# A list of headers from the end user to pass to DeviceAtlas Cloud. These
	# help with detection, especially if a third party browser or a proxy
	# changes the original user-agent.
	ESSENTIAL_HEADERS = [
    "x-profile",
    "x-wap-profile",
    "x-att-deviceid",
    "accept",
    "accept-language"
  ]

	# A list of headers which may contain the original user agent.
	# These headers are sent to cloud server beside ESSENTIAL_HEADERS.
	ESSENTIAL_USER_AGENT_HEADERS = [
    "x-device-user-agent",
    "x-original-user-agent",
    "x-operamini-phone-ua",
    "x-skyfire-phone",
    "x-bolt-phone-ua",
    "device-stock-ua",
    "x-ucbrowser-ua",
    "x-ucbrowser-device-ua",
    "x-ucbrowser-device",
    "x-puffin-ua"
  ]

	# A list of additional headers to send to DeviceAtlas. These are not sent by
	# default. These headers can be used for carrier detection and geoip.
	EXTRA_HEADERS = [
    "client-ip",
    "x-forwarded-for",
    "x-forwarded",
    "forwarded-for",
    "forwarded",
    "proxy-client-ip",
    "wl-proxy-client-ip"
  ]

  attr_reader(
    :ranking_status,
    :called_servers,
    :last_used_cloud_url,
    :self_auto_ranking,
    :fatal_errors,
    :settings # Only exists in Ruby API
  )

  attr_accessor(
    :headers,
    :cookies # Only exists in Ruby API
  )

	##
	# Store the request details: headers and cookie content.
	#
	# +headers+:: Hash of headers from the request.
  # +cookies+:: Hash of cookies from the request.
	#
  def initialize(headers = nil, cookies = nil) # Particular Ruby API version
    @headers = headers
    @cookies = cookies
    @settings = Settings.new
    @called_servers = []
	end

	##
	# Get device data from DeviceAtlas Cloud. Once data has been returned from
	# DeviceAtlas Cloud it can be cached locally to speed up subsequent
	# requests.
	# If device data provided by the DeviceAtlas JavaScript library exists in a
	# cookie then cloud data will be merged with the cookie data.
	#
	# +param+:: Browser headers or boolean value to use a fake UserAgent to test
  # the API.
	# +return+:: Hash of properties, source, user-agent and error message if any
	# happens.
	#
  def get_device_data(param = false)

    # get the user-agent
    if param == false
      user_agent = ''
      if !@headers.nil?
        user_agent = @headers['HTTP_USER_AGENT']
      end
    elsif param == true
			user_agent = @settings.test_useragent
    else
      if @request.nil?
        @request = {}
      end
      @headers = get_normalised_headers param # normalize the given header hash
      user_agent = (@headers.has_key?'user-agent')?@headers['user-agent']:''
		end

    # get the DeviceAtlas Client Side Component cookie if usage=on and exists
    cookie = nil
		if @settings.use_client_cookie && !@cookies.nil? &&
        !@cookies[@settings.client_cookie_name].nil?
			cookie = @cookies[@settings.client_cookie_name]
    elsif @settings.use_client_cookie && 
        !@headers.nil? &&
        @headers.has_key?('cookie')
      @headers['cookie'].gsub!(" ", "")
      cookie_items = @headers['cookie'].split ';'
      cookie_items.each do |cookie_item|
        cookie_name_value = cookie_item.split '='
        if @settings.client_cookie_name == cookie_name_value[0]
          cookie = cookie_name_value[1].gsub(" ", "")
        end
      end
		end

    # get device data from cache or cloud
    @last_used_cloud_url = nil
    @self_auto_ranking = 'n' # 'y' = the API called the ranking
    @ranking_status = nil # for debugging
    @called_servers = [] # for debugging

		begin
			# check cache for cached data
			if @settings.use_cache
        source = SOURCE_CACHE
        results = get_cache user_agent, cookie
			end
			# use cloud service to get data
			if results.nil?
        source = SOURCE_CLOUD
				results = get_cloud_service user_agent, cookie
        # set the caches for future queries
        if @settings.use_cache && source === SOURCE_CLOUD
          set_cache user_agent, cookie, results[KEY_PROPERTIES]
        end
			end	
		# handle errors
		rescue Exception => e
      if results.nil?
        results = {}
      end
      results[KEY_ERROR] = e.message
      if @settings.debug_mode
        raise Exception, e.message
      end
		end

    # In Ruby, we return properties as symbols
    if results.has_key?KEY_PROPERTIES
      results[KEY_PROPERTIES] = results[KEY_PROPERTIES].inject({}){
        |memo,(k,v)| memo[k.to_sym] = v; memo
      }
    end

    results[KEY_SOURCE] = source
    results[KEY_USERAGENT] = user_agent
    return results

  end

  ##
  # Get the URL of the latest DeviceAtlas cloud end-point that returned device
  # properties successfully.
  #
  # There are three cases where this function will return nil:
  # 1) If device properties come from cache.
  # 2) If licence is wrong, expired or exceeded quota.
  # 3) None end-point were reached or could return device properties.
  #
  # +return+:: String with the used end-point URL.
  #
  def get_cloud_url
    @last_used_cloud_url
  end

  ##
  # Get the end-point list.
  #
  # +return+:: Array of hashes with end-point info.
  #
  def get_servers

    if @settings.auto_server_ranking

      @self_auto_ranking = 'y'

      # if possible fetch server ranked list from cache
      path = get_cache_base_path() + File::SEPARATOR + 'servers'

      if File.readable?(path) &&
          (@settings.auto_server_ranking_lifetime == 0 ||
            File.mtime(path) > (Time.now() -
              (60 + [-5,5].sample)*@settings.auto_server_ranking_lifetime))

        servers = JSON.parse(File.read(path), :symbolize_names => true)

        if !servers.nil?
          @ranking_status = 'A'
          return servers
        end

      end

      # no or expired server ranked list - rank servers
      servers = rank_servers()

      if !servers.nil?
        return servers
      end

    end

    # check if manual list is cached or not
    # manual list is cached and used for some time when top server fails
    path = get_cache_base_path() + File::SEPARATOR + 'servers-manual'
    if File.readable?(path) &&
       @settings.server_phaseout_lifetime > 0 &&
       File.mtime(path) >
        (Time.now() - (60 + [-5,5].sample)*@settings.server_phaseout_lifetime)

      servers = JSON.parse(File.read(path), :symbolize_names => true)

      if !servers.nil?
        @ranking_status = 'M'
        return servers
      end

    end

    # default list
    @ranking_status = 'D'
    return @settings.servers

  end

  ##
	# Set the server list based on a hash of server details.
	#
	# +server_hash+:: Array of hashes with server information.
	#
	def servers=(server_hash) # Only in Ruby API (1.3 compatible)
		@settings.servers = server_hash
	end

	##
	# Get the current server list.
	#
	# +return+:: Array of hashes with server details.
	#
	def servers # Only in Ruby API (1.3 compatible)
		@settings.servers
	end

  ##
  # Get a list of cloud end-points and their service latencies.
  #
  # +num_requests+:: Number of times to send requests to an end-point per test
  # +return+:: Array of end-point info {{avg:, latencies:, host:, port:},}
  #
  def get_servers_latencies(num_requests =
      @settings.auto_server_ranking_num_requests)
    @ranking_status = 'L'
    # test servers in a randomly order
    servers = @settings.servers

    seed = (0..servers.length-1).to_a
    seed.shuffle!

    seed.each do |i|

      latencies = get_server_latency(servers[i], num_requests)

      if !@fatal_errors.nil?
        return nil
      end
      servers[i][:latencies] = latencies
      latency_sym = servers[i][:latencies].inject{|sum,x| sum + x }

      servers[i][:avg] = (latencies.include?(-1))?-1:(latency_sym/num_requests)

    end

    return servers
  end

	##
	# Sort servers by availability and latency to save them in cache.
  #
  # +servers+:: If servers are provided, they are used to be ranked.
	# +return+:: Boolean value. True if servers could be ranked. Else, False.
  #
  def rank_servers(servers = nil)

    # proceed only if cache directory exists or is writable
    cache_path = get_cache_base_path()
    if !File.exists?cache_path
      begin
        FileUtils.mkpath cache_path
      rescue
        raise Exception, "Unable to create cache directory #{cache_path}"
      end
    end

    cache_file = (@settings.auto_server_ranking)?
      cache_path+File::SEPARATOR+'servers':
      cache_path+File::SEPARATOR+'servers-manual'

    # get the ranked servers and pick the healthy items
    if servers.nil?

      if !@settings.auto_server_ranking
        return nil
      end

      # proceed only if cache file is writable
      if (!File.exists?cache_file) || (File.writable?cache_file)

        server_latencies = get_servers_latencies()

        if server_latencies.nil?
          return nil
        end

        server_latencies.each do |server|
          if server[:avg] != -1
            servers = [server]
          end
        end

      else

        raise Exception, "Unable to write cache file #{cache_file}"
      end

      # if server list is empty then extend the cache timeout
      if servers.nil? && (File.exists?cache_file) #Second condition only in Ruby
        FileUtils.touch(cache_file)
        return nil
      end

      # sort by latency ASC
      if !servers.nil? # Condition only in Ruby
        servers.sort_by{ |server| -server[:avg]}
      end

    end

    # write to cache
    ok = true
    if !servers.nil?
      ok = write_cache_to_file(cache_file, servers.to_json)
    end

    # return list only if ranked
    return ok && ((@settings.auto_server_ranking)?servers:nil)

  end

  ##
  # Get the directory path in which the DeviceAtlas CloudApi puts cache files
  # in (device data cache and server fail-over list).
  #
  # +return+:: String with the cache directory
  #
  def get_cache_base_path
    if @settings.cache.use_system_temp_dir
      path = Dir::tmpdir
    else
      path = @settings.cache.custom_cache_dir
    end
    return File.join(path, @settings.cache.name)
  end

  private

  ##
  # Normalize HTTP header keys.
  # +headers+:: Hash of headers.
  # +return+:: Hash of headers with normalised keys.
  #
  def get_normalised_headers(headers = nil)
    normalised_keys = {}
    if !headers.nil?
      if headers.kind_of?Hash
        headers.each do |key,value|
          normalised_key = key.to_s.downcase.gsub('_','-').sub(/http-/,'')
          normalised_keys[normalised_key] = value
        end
      elsif headers.kind_of?String
        normalised_keys = {'user-agent' => headers}
      end
    elsif !@headers.nil?
      @headers.each do |key,value|
        normalised_key = key.to_s.downcase.gsub('_','-').sub(/http-/,'')
        normalised_keys[normalised_key] = value
      end
    end
    return normalised_keys
  end

  ##
  # Send request(s) to a DA cloud server and return the latencies
  #
  def get_server_latency(server, num_requests)

    failures = 0
    latencies = []
    @fatal_errors = nil
    # common header parts
    headers = "GET " +
      (CLOUD_PATH % [@settings.licence_key, '']).gsub(/\s+/, "") + " HTTP/1.0\r\n" +
      "Host: " + server[:host] + ":" + server[:port].to_s + "\r\n" +
      "Accept: application/json\r\n" +
      "User-Agent: ruby/" + API_VERSION + "\r\n" +
      DA_HEADER_PREFIX + "Latency-Checker: "
    # only the first request will send the settings
    configs = ((@self_auto_ranking.nil?)?'y':@self_auto_ranking) + ';' +
            ((@settings.auto_server_ranking)?'y':'n') + ';' +
            @settings.cloud_service_timeout.to_s + ';' +
            @settings.auto_server_ranking_max_failures.to_s + ';' +
            @settings.auto_server_ranking_num_requests.to_s + ';' +
            @settings.auto_server_ranking_lifetime.to_s + ';' +
            @settings.server_phaseout_lifetime.to_s + ';' + "\r\n"
    # ignore the first call because it can take an unreal long time

    i = 0

    while i < num_requests+1 &&
        failures < @settings.auto_server_ranking_max_failures

      start = Time.now
      begin

        errors = []

        response = connect_cloud(server, headers + ((i==0)?configs:"#{i}\r\n") +
            "Connection: Close\r\n\r\n", errors)

        if response[0] == FAILOVER_NOT_REQUIRED
          if i > 0            
            latencies.push((Time.now - start)*1000)            
          end
          i += 1
          next
        elsif response[0] == FAILOVER_STOP
          # licence errors which are found at ranking,
          # to stop any further cloud call
          @fatal_errors = errors
          break
        end
      rescue
        # Keep checking servers
      end
      failures += 1
      
      latencies.push(-1)
      
    end

    return latencies
  end

  def get_cache(user_agent, cookie)
    
    path = get_device_cache_path(user_agent, cookie)

    # check file modification time
    if File.exists?(path) && File.readable?(path) && 
				Time.now < File.mtime(path) + @settings.cache.item_expiry_sec

      content = File.read(path)
			data = JSON.parse(content) #, :symbolize_names => true)
      data.delete(:generation)
      # check if cache is healthy
      if data.has_key?KEY_PROPERTIES # Only exists in Ruby API
        return data
      end     
    end
    return nil
    
  end

  def get_device_cache_path(user_agent, cookie = nil)

    # 1- headers which are used for device detection
    headers = get_normalised_headers()
    ESSENTIAL_USER_AGENT_HEADERS.each do |header|
      if headers.has_key?header
        user_agent = user_agent + headers[header]
        break
      end
    end

    if cookie.nil? # Only in Ruby
      cookie = ''
    end

    # 2, 3 - the user-agent, the DeviceAtlas client side component cookie
    key = Digest::MD5.hexdigest(user_agent + cookie)

    return File.join(get_cache_base_path() + File::SEPARATOR,
      key[0..2], # first dir
      key[2..4], # second dir
      key[4..key.length]) # filename

  end

  def get_cloud_service(user_agent, cookie)
    errors = []

    servers = get_servers()

    if @fatal_errors
      raise Exception, @fatal_errors.join("\n")
    end

    headers = prepare_headers()

    # add the client side component cookie
    if !cookie.nil?
      headers = headers + DA_HEADER_PREFIX + CLIENT_COOKIE_HEADER + ': ' +
        cookie + "\r\n"
    end

    # request cloud
    i = 0

    servers.each do |server|

      response = connect_cloud(
        server,
        "GET " +
        (CLOUD_PATH % [@settings.licence_key, CGI.escape(user_agent)]) +
        " HTTP/1.0\r\n" +
        "Host: " + server[:host] + ":" + server[:port].to_s + "\r\n" +
        "Accept: application/json\r\n" +
        "User-Agent: ruby/" + API_VERSION + "\r\n" +
        headers +
        "Connection: Close\r\n\r\n",
        errors
      )

      @last_used_cloud_url = server[:host]

      if response[0] == FAILOVER_NOT_REQUIRED

        if i > 0
          # i = index of the healthy server, all servers with index less than
          # i have failed, move them to the end of the list:
          for j in 0..(i-1)
            
            servers.push((servers.shift)[0])
            
          end
        end

        # save the list to cache
        # if servers is passed, it means only cache server list without ranking
        rank_servers(servers) # Moved one level backward (only in Ruby)

        return response[1]

      elsif response[0] == FAILOVER_STOP
        break
      end

      i += 1

    end

    raise Exception, (!errors.empty?)?
      errors.join("\n"):
      "No server has been defined."

  end

  def prepare_headers

    headers_new = ''
    headers = get_normalised_headers()
    # add headers which are required for detection
    ESSENTIAL_USER_AGENT_HEADERS.each do |k|
      if headers.has_key?k
        headers_new += DA_HEADER_PREFIX + k + ': ' + headers[k] + "\r\n"
      end
    end
    ESSENTIAL_HEADERS.each do |k|
      if headers.has_key?k
        headers_new += DA_HEADER_PREFIX + k + ': ' + headers[k] + "\r\n"
      end
    end
    # opera headers
    headers.each do |k,val|
      if k.include?'opera'
        headers_new += DA_HEADER_PREFIX + k + ': ' + headers[k] + "\r\n"
      end
    end
    # add headers which are optional
    if @settings.send_extra_headers
      EXTRA_HEADERS.each do |k|
        if headers.has_key?k
          headers_new += DA_HEADER_PREFIX + k + ': ' + headers[k] + "\r\n"
        end
      end
    end

    return headers_new
  end

  def connect_cloud(server, headers, errors = [])

    @called_servers.push(server[:host])   

    socket_error = ""
    fp = get_socket(server[:host], server[:port],
      @settings.cloud_service_timeout, socket_error)

    if !fp.nil?

      # write the request headers and get response
      fp.write headers
      results = ""
      while response = fp.gets
        results += response
      end
      fp.close

      # extract response headers and body...
      parts = results.split("\r\n\r\n")

      if parts.length > 1

        status = parts[0].split(' ')

        if status.length > 1 &&  status[1].to_i/100 == 2

          props = nil
          if body = parts[1]
            props = JSON.parse(body)
            if props.has_key?KEY_PROPERTIES
              return [FAILOVER_NOT_REQUIRED, props]
            end
            error_msg = "Returned invalid data '#{body}'"
          else
            error_msg = "Returned empty!"
          end
          
        else
          error_msg = parts[1]
        end
      else
        error_msg = "Cant parse response '#{results}'"
      end

    else
      error_msg = socket_error
    end

    e = error_controller(server, (!status.nil?)?status[1]:nil, error_msg)
    
    errors.push(e[1])
    

    return [e[0], nil]

  end

  def error_controller(server, status, msg)
    action = FAILOVER_CONTINUE

    # Invalid licence key, Licence monthly quota exceeded
    if msg.include?'orbidden'
      action = FAILOVER_STOP
    end

    msg.gsub!("\n", " ")
    msg.gsub!("\r", " ")

    return [
      action,
      'Error getting data from DeviceAtlas Cloud end-point "' + server[:host] +
      '" Reason: ' +  msg.gsub(/<\/?[^>]*>/, "")
    ]

  end

  def set_cache(user_agent, cookie, device_data)
    path = get_device_cache_path(user_agent, cookie)
    dir_name = File.dirname(path)
    dir_exists = File.exists?dir_name
    # if expected dir is a file
    if dir_exists
      dir_exists = false
      File.unlink(path)
    end
    # if directory not exists make it
    if !dir_exists
      begin
        FileUtils.mkpath dir_name
			rescue SystemCallError => e
				raise(Exception, "Unable to create cache directory #{dir_name}")
				return false
			end
    end
    # write cache
    write_cache_to_file(path, {KEY_PROPERTIES=>device_data}.to_json)
  end

  def write_cache_to_file(path, data)
    begin
      file = File.open(path, "w")
      file.write(data)
      file.close
      return true
    rescue Exception
      raise Exception, "Unable to write cache to cache to file #{path}"
    end
  end

	##
	# Low-level method to connect through a new socket.
	#
	# We use the low-level operations, Socket.new and connect rather than just
	# TCPSocket.new(host, port) because otherwise we cannot set the socket
	# options before the connection is attempted; we want to ensure the
	# connection attempt itself is timed out also.
	#
	# +host+:: String with the server host.
	# +port+:: Integer with the server port.
	# +timeout+:: Integer with the timeout to be connected.
	# +return+:: Connected socket.
	#
	def get_socket(host, port, timeout, error)

    begin

      addr = Socket.getaddrinfo(host, nil)

      if addr.nil?
        return
      end

      sock = Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0)

      if timeout
        secs = Integer(timeout)
        usecs = Integer((timeout - secs) * 1_000_000)
        optval = [secs, usecs].pack("l_2")
        sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, optval)
        sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_SNDTIMEO, optval)
      end

      sock.connect(Socket.pack_sockaddr_in(port, addr[0][3]))
      return sock

    rescue Exception => e
      error = e.message
      return nil
    end

	end

  end
end

