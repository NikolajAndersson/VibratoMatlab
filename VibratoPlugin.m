classdef VibratoPlugin < audioPlugin
    
    properties
        width = 0.0001
        rate = 9
        Mix = 0.5
    end
    
    properties (Dependent)
    end
    
    properties

        
    end
    
    properties (Constant)
        % audioPluginInterface manages the number of input/output channels
        % and uses audioPluginParameter to generate plugin UI parameters.
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('width','DisplayName','width','Label','','Mapping',{'lin',0.00001 0.001}),...
            audioPluginParameter('rate','DisplayName','Modulation Rate','Label','','Mapping',{'lin',1 14}),...
            audioPluginParameter('Mix','DisplayName','Dry/Wet','Label','%','Mapping',{'lin',0 1}));
    end
    
    properties (Access = private)
        vibrato
    end
    
    methods
        function obj = VibratoPlugin()
           obj.vibrato = Vibrato(obj.rate, obj.width, getSampleRate(obj));         
        end
        
        function set.rate(obj,rate)
            obj.rate = rate;
           % obj.vibrato.rate = obj.rate; 
           setRate(obj.vibrato,rate);
        end
        
        function set.width(obj,width)
            obj.width = width;
           % obj.vibrato.width = obj.width;
            setWidth(obj.vibrato,width);
        end
        
        function reset(obj)
            reset(obj.vibrato, getSampleRate(obj));
        end
        
        function out = process(obj, x)
            y = zeros(size(x));
            y = process(obj.vibrato, x);
            
            % Calculate output by adding wet and dry signal in appropriate
            % ratio
            mix = obj.Mix;
            out = (1-mix)*x + (mix)*y;
        end
    end
end
