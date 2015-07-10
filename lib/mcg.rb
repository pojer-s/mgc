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

    def start
        Server.run!({:bind => @config["bind"], :port => @config["port"], :mcg => self})
    end
end
