require 'json'
require 'net/http'

require "mcg/version"
require "mcg/action"
require "mcg/data"
require "mcg/server"

class MCG

    def initialize(config=nil)
        @config = {
            "bind"     => "127.0.0.1",
            "port"     => 8000,
            "marathon" => "http://localhost:8080",
            "actions"  => {}
        }
        @config.merge! config
        @data = Data.new(@config["marathon"])
        @actions = {}
        @config["actions"].each do |action_name, action_value|
            add_action(action_name,
                       action_value["template"],
                       action_value["output"],
                       action_value["reload_command"])
        end
    end

    def add_action(name, template, output, reload_command)
        @actions[name] = Action.new(template, output, reload_command)
    end

    def generate
        @data.get
        @actions.each do |name, action|
            action.render(@data)
        end
    end

    def subscribe
        uri = URI.parse(@config["marathon"] + '/v2/eventSubscriptions')
        http = Net::HTTP.new(uri.host, uri.port)
        req = Net::HTTP::Get.new(uri.path, initheader = {'Accept' =>'application/json'})
        resp = http.request(req)
        data = JSON.parse(resp.body)
        if resp.code.to_i == 200
            unless data["callbackUrls"].include?(@config["host"])
                request = Net::HTTP::Post.new(uri.path + "?callbackUrl=#{@config["host"]}")
                request.add_field('Content-Type', 'application/json')
                resp = http.request(request)
                data = JSON.parse(resp.body)
                unless resp.code.to_i == 200
                    raise "Cannot subscribe to #{@config["marathon"]}. Error: #{data["message"]}"
                end
            end
        else
            raise "Error: #{data["message"]}"
        end
    end

    def unsubscribe
        uri = URI.parse(@config["marathon"] + '/v2/eventSubscriptions')
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Delete.new(uri.path + "?callbackUrl=#{@config["host"]}")
        request.add_field('Content-Type', 'application/json')
        resp = http.request(request)
        data = JSON.parse(resp.body)
        unless resp.code.to_i == 200
            raise "Cannot unsubscribe to #{@config["marathon"]}. Error: #{data["message"]}"
        end
    end

    def start
        Server.run!({:bind => @config["bind"], :port => @config["port"], :mcg => self})
    end
end
