require 'erb'

class MCG

    class Action

        def initialize(template, output, reload_command)
            @template = IO.read(template)
            @output = output
            @reload_command = reload_command
        end

        def render(data)
            @data = data
            b = binding
            renderer = ERB.new(@template)
            IO.write(@output, renderer.result(b))
            puts @reload_command
        end

    end
end
