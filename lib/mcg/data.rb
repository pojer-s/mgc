require 'json'
require 'net/http'

class MCG

    class Data

        attr_reader :data
        attr_reader :tasks

        def initialize(marathon_url)
            @marathon_url = marathon_url
            @data = nil
            @tasks = nil
        end

        def get
            uri = URI.parse(@marathon_url + '/v2/tasks')
            http = Net::HTTP.new(uri.host, uri.port)
            req = Net::HTTP::Get.new(uri.path, initheader = {'Accept' =>'application/json'})
            resp = http.request(req)
            @data = JSON.parse(resp.body)
            order_task
        end

        def order_task
            @tasks = Hash.new { |h, k| h[k] = [] }

            @data["tasks"].each do |task|
                fqdn = task["appId"][/\/([^\/]+)\//, 1]
                task["ports"].each do |port|
                    @tasks[fqdn] << {
                        :host => task["host"],
                        :port => port
                    }
                end
            end
        end

    end
end
