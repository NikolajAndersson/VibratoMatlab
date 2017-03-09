classdef Vibrato < handle
    properties
        rate
        width
    end
    properties (Access=private)
        delay
        fs
        Buffer = zeros(192001,2);
        BufferIndex = 1;
        phase = 0;
        freq
    end
    
    methods
        function obj = Vibrato(r_, w_, fs_)
            obj.rate = r_;
            obj.width = w_;
            obj.fs = fs_;
            
            obj.delay = round(obj.width * obj.fs);
            obj.freq = obj.rate / obj.fs;
        end
        function setRate(obj,rate)
            obj.rate = rate;
            obj.freq = rate / obj.fs;        
        end
        function setWidth(obj,width)
            obj.width = width;
            obj.delay = round(width * obj.fs);
        end
        function out = process(obj, x)
            y = zeros(size(x));
            writeIndex = obj.BufferIndex;
            
            delta = obj.freq * 2 * pi;
            
            for i = 1:size(x,1)
                obj.Buffer(writeIndex,:) = x(i,:); % Store buffer
                
                MOD = sin(obj.phase);
                
                obj.phase = obj.phase + delta;
                if obj.phase > 2 * pi
                    obj.phase = obj.phase - 2*pi;
                end
                
                TAP=1+obj.delay+obj.delay*MOD;
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
            out = y;
        end
        function reset(obj, fs)
            obj.fs = fs;
            obj.BufferIndex = 1;
            obj.Buffer = zeros(192001,2);
        end
        
    end    
end