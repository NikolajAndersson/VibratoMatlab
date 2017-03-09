classdef VibratoPlugin < audioPlugin
    
    properties
        Width = 0.0001
        Modrate = 9
        Mix = 0.5
    end
    
    properties (Dependent)
    end
    
    properties
        DELAY
        
        WIDTH
        
        MODFREQ
        
    end
    
    properties (Constant)
        % audioPluginInterface manages the number of input/output channels
        % and uses audioPluginParameter to generate plugin UI parameters.
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('Width','DisplayName','Width','Label','','Mapping',{'lin',0.00001 0.001}),...
            audioPluginParameter('Modrate','DisplayName','Modulation Rate','Label','','Mapping',{'lin',1 14}),...
            audioPluginParameter('Mix','DisplayName','Dry/Wet','Label','%','Mapping',{'lin',0 1}));
    end
    
    properties (Access = private)
        pSR
        
        Buffer = zeros(192001,2);
        BufferIndex = 1;
%         NSamples = 1;
        phase = 0;
    end
    
    methods
        function obj = Vibrato()
            obj.pSR = getSampleRate(obj);
            obj.DELAY = round(obj.Width * obj.pSR);
            obj.WIDTH = round(obj.Width * obj.pSR);
            obj.MODFREQ = obj.Modrate / obj.pSR;
            obj.Buffer = zeros(192001,2);
            obj.BufferIndex = 1;
%             obj.NSamples = 1;
        end
        
        function set.Modrate(obj,Modrate)
            obj.Modrate = Modrate;
            fs = getSampleRate(obj);
            obj.MODFREQ = Modrate / fs;
        end
        
        function set.Width(obj,Width)
            obj.Width = Width;
            fs = getSampleRate(obj);
            obj.DELAY = round(Width * fs);
            obj.WIDTH = round(Width * fs);
        end
        
        function reset(obj)
            obj.pSR = getSampleRate(obj);
%             obj.NSamples = 1;
            obj.BufferIndex = 1;
            obj.Buffer = zeros(192001,2);
        end
        
        function out = process(obj, x)
            y = zeros(size(x));
            writeIndex = obj.BufferIndex;
            
            for i = 1:size(x,1)
                obj.Buffer(writeIndex,:) = x(i,:); % Store buffer
                
                MOD = sin(obj.phase);
                
                delta = obj.MODFREQ * 2 * pi;
                obj.phase = obj.phase + delta;
                if obj.phase > 2 * pi
                    obj.phase = obj.phase - 2*pi;
                end
                
%                 obj.NSamples = obj.NSamples + 1;
%                 if obj.NSamples > 192001
%                     obj.NSamples = 1;
%                 end
                
                TAP=1+obj.DELAY+obj.WIDTH*MOD;
                n=floor(TAP);
                frac = TAP - n;
                readIndex = floor(writeIndex - n);
                
                if readIndex <= 0
                    readIndex = readIndex + 192001;
                end
                if readIndex == 1
                    y(i,:) = frac*obj.Buffer(192001) + (1-frac)*obj.Buffer(readIndex);
                else
                    y(i,:) = frac*obj.Buffer(readIndex - 1) + (1-frac)*obj.Buffer(readIndex);
                end
                writeIndex = writeIndex + 1;
                if writeIndex > 192001
                    writeIndex =  1;
                end
            end
            obj.BufferIndex = writeIndex;
            
            % Calculate output by adding wet and dry signal in appropriate
            % ratio
            mix = obj.Mix;
            out = (1-mix)*x + (mix)*y;
        end
    end
end
