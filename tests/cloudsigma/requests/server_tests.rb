Shindo.tests('Fog::Compute[:cloudsigma] | server requests', ['cloudsigma']) do

  @server_format = {
      'uuid' => String,
      'status' => String,
      'vnc_password' => String,
      'name' => String,
      'cpus_instead_of_cores' => Fog::Boolean,
      'tags' => Array,
      'mem' => Integer,
      'enable_numa' => Fog::Boolean,
      'smp' => Integer,
      'hv_relaxed'  => Fog::Boolean,
      'hv_tsc' => Fog::Boolean,
      'meta' => Fog::Nullable::Hash,
      'owner' => Fog::Nullable::Hash,
      'runtime' => Fog::Nullable::Hash,
      'cpu' => Integer,
      'resource_uri' => Fog::Nullable::String,
      'drives' => Array,
      'nics' => Array
  }

  @server_create_args = {:name => 'fogtest', :cpu => 2000, :mem => 512*1024**2, :vnc_password => 'myrandompass'}

  tests('success') do

    tests("#create_server(#@server_create_args)").formats(@server_format, false) do
      server_def = Fog::Compute[:cloudsigma].create_server(@server_create_args).body['objects'].first
      @server_uuid = server_def['uuid']

      server_def
    end

    tests("#get_server(#@server_uuid)").formats(@server_format, false) do
      @resp_server = Fog::Compute[:cloudsigma].get_server(@server_uuid).body
    end

    tests("#update_server(#@server_uuid)").formats(@server_format, false) do
      @resp_server['cpu'] = 1000
      @resp_server = Fog::Compute[:cloudsigma].update_server(@server_uuid, @resp_server).body

      @resp_server

    end

    tests("#start_server(#@server_uuid)").succeeds do
      response = Fog::Compute[:cloudsigma].start_server(@server_uuid)

      response.body['result'] == "success"
    end

    server = Fog::Compute[:cloudsigma].servers.get(@server_uuid)
    server.wait_for { status == 'running' }

    tests("#stop_server(#@server_uuid)").succeeds do
      response = Fog::Compute[:cloudsigma].stop_server(@server_uuid)

      response.body['result'] == "success"
    end

    server = Fog::Compute[:cloudsigma].servers.get(@server_uuid)
    server.wait_for { status == 'stopped' }

    tests("#delete_server(#@server_uuid)").succeeds do
      resp = Fog::Compute[:cloudsigma].delete_server(@server_uuid)

      resp.body.empty? && resp.status == 204
    end
  end

  tests('failure') do
    tests("#get_server(#@server_uuid)|deleted|").raises(Fog::CloudSigma::Errors::NotFound) do
      Fog::Compute[:cloudsigma].get_server(@server_uuid).body
    end
  end
end
