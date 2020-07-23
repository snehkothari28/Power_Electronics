%created by Sneh Kothari
%Enrollment: 180283109012


classdef on_off_controller < matlab.apps.AppBase
    
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        UIAxes                       matlab.ui.control.UIAxes
        SupplyVoltageEditFieldLabel  matlab.ui.control.Label
        SupplyVoltageEditField       matlab.ui.control.NumericEditField
        FrequencyEditFieldLabel      matlab.ui.control.Label
        FrequencyEditField           matlab.ui.control.NumericEditField
        ONCyclesSliderLabel          matlab.ui.control.Label
        ONCyclesSlider               matlab.ui.control.Slider
        OutputVoltageTextAreaLabel   matlab.ui.control.Label
        OutputVoltageTextArea        matlab.ui.control.TextArea
        OFFCyclesSliderLabel         matlab.ui.control.Label
        OFFCyclesSlider              matlab.ui.control.Slider
        ONOFFVoltagecontrollerLabel  matlab.ui.control.Label
    end
    
    % Callbacks that handle component events
    methods (Access = private)
        
        % Value changing function: ONCyclesSlider
        function ONCyclesSliderValueChanging(app, event)
            on = round(event.Value);
            off = round(double(app.OFFCyclesSlider.Value));
            vr = app.SupplyVoltageEditField.Value;
            vm = vr*sqrt(2); %calcuatigng the maximum voltage
            f = app.FrequencyEditField.Value; %frequency
            total = on + off ;
            tf = linspace(0,1/f,1000);
            vf = vm*sin(2*pi*f*tf);
            vout_on = repmat(vf,1,on);
            vout_off = repmat(zeros(size(vf)),1,off);
            v_out = [vout_on, vout_off];
            
            tp = linspace(0,total/f,length(v_out));
            plot(app.UIAxes,tp,v_out)
            app.UIAxes.YLim = [-1.1*(vm) 1.1*(vm)];
            app.UIAxes.XLim = [0 total/(f)];
            vorms = rms(v_out);
            app.OutputVoltageTextArea.Value = num2str(vorms);
        end
        
        % Value changing function: OFFCyclesSlider
        function OFFCyclesSliderValueChanging(app, event)
            off = round(event.Value);
            on = round(double(app.ONCyclesSlider.Value));
            vr = app.SupplyVoltageEditField.Value;
            vm = vr*sqrt(2); %calculating the maximum voltage
            f = app.FrequencyEditField.Value; %frequency
            total = on + off ;
            tf = linspace(0,1/f,1000);
            vf = vm*sin(2*pi*f*tf);
            vout_on = repmat(vf,1,on);
            vout_off = repmat(zeros(size(vf)),1,off);
            v_out = [vout_on, vout_off];
            
            tp = linspace(0,total/f,length(v_out));
            plot(app.UIAxes,tp,v_out)
            app.UIAxes.YLim = [-1.1*(vm) 1.1*(vm)];
            app.UIAxes.XLim = [0 total/(f)];
            vorms = rms(v_out);
            app.OutputVoltageTextArea.Value = num2str(vorms);
        end
    end
    
    % Component initialization
    methods (Access = private)
        
        % Create UIFigure and components
        function createComponents(app)
            
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 782 462];
            app.UIFigure.Name = 'UI Figure';
            
            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Voltage')
            xlabel(app.UIAxes, 'Time')
            ylabel(app.UIAxes, 'Voltage')
            app.UIAxes.XLim = [0 0.02];
            app.UIAxes.XGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.Position = [1 185 782 245];
            
            % Create SupplyVoltageEditFieldLabel
            app.SupplyVoltageEditFieldLabel = uilabel(app.UIFigure);
            app.SupplyVoltageEditFieldLabel.HorizontalAlignment = 'right';
            app.SupplyVoltageEditFieldLabel.Position = [13 133 86 22];
            app.SupplyVoltageEditFieldLabel.Text = 'Supply Voltage';
            
            % Create SupplyVoltageEditField
            app.SupplyVoltageEditField = uieditfield(app.UIFigure, 'numeric');
            app.SupplyVoltageEditField.Limits = [0 Inf];
            app.SupplyVoltageEditField.Position = [103 133 39 22];
            app.SupplyVoltageEditField.Value = 230;
            
            % Create FrequencyEditFieldLabel
            app.FrequencyEditFieldLabel = uilabel(app.UIFigure);
            app.FrequencyEditFieldLabel.HorizontalAlignment = 'right';
            app.FrequencyEditFieldLabel.Position = [241 133 62 22];
            app.FrequencyEditFieldLabel.Text = 'Frequency';
            
            % Create FrequencyEditField
            app.FrequencyEditField = uieditfield(app.UIFigure, 'numeric');
            app.FrequencyEditField.Position = [307 133 39 22];
            app.FrequencyEditField.Value = 50;
            
            % Create ONCyclesSliderLabel
            app.ONCyclesSliderLabel = uilabel(app.UIFigure);
            app.ONCyclesSliderLabel.HorizontalAlignment = 'right';
            app.ONCyclesSliderLabel.Position = [23 94 63 22];
            app.ONCyclesSliderLabel.Text = 'ON Cycles';
            
            % Create ONCyclesSlider
            app.ONCyclesSlider = uislider(app.UIFigure);
            app.ONCyclesSlider.Limits = [0 50];
            app.ONCyclesSlider.ValueChangingFcn = createCallbackFcn(app, @ONCyclesSliderValueChanging, true);
            app.ONCyclesSlider.Position = [94 103 672 3];
            app.ONCyclesSlider.Value = 3;
            
            % Create OutputVoltageTextAreaLabel
            app.OutputVoltageTextAreaLabel = uilabel(app.UIFigure);
            app.OutputVoltageTextAreaLabel.HorizontalAlignment = 'right';
            app.OutputVoltageTextAreaLabel.Position = [573 131 85 22];
            app.OutputVoltageTextAreaLabel.Text = 'Output Voltage';
            
            % Create OutputVoltageTextArea
            app.OutputVoltageTextArea = uitextarea(app.UIFigure);
            app.OutputVoltageTextArea.Position = [665 126 73 29];
            
            % Create ONOFFVoltagecontrollerLabel
            app.ONOFFVoltagecontrollerLabel = uilabel(app.UIFigure);
            app.ONOFFVoltagecontrollerLabel.HorizontalAlignment = 'center';
            app.ONOFFVoltagecontrollerLabel.FontSize = 18;
            app.ONOFFVoltagecontrollerLabel.FontWeight = 'bold';
            app.ONOFFVoltagecontrollerLabel.Position = [275 429 233 22];
            app.ONOFFVoltagecontrollerLabel.Text = 'ON-OFF Voltage controller';
            
            % Create OFFCyclesSliderLabel
            app.OFFCyclesSliderLabel = uilabel(app.UIFigure);
            app.OFFCyclesSliderLabel.HorizontalAlignment = 'right';
            app.OFFCyclesSliderLabel.Position = [17 35 69 22];
            app.OFFCyclesSliderLabel.Text = 'OFF Cycles';
            
            % Create OFFCyclesSlider
            app.OFFCyclesSlider = uislider(app.UIFigure);
            app.OFFCyclesSlider.Limits = [0 50];
            app.OFFCyclesSlider.ValueChangingFcn = createCallbackFcn(app, @OFFCyclesSliderValueChanging, true);
            app.OFFCyclesSlider.Position = [94 44 672 3];
            app.OFFCyclesSlider.Value = 5;
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end
    
    % App creation and deletion
    methods (Access = public)
        
        % Construct app
        function app = on_off_control
            
            % Create UIFigure and components
            createComponents(app)
            
            % Register the app with App Designer
            registerApp(app, app.UIFigure)
            
            if nargout == 0
                clear app
            end
        end
        
        % Code that executes before app deletion
        function delete(app)
            
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end