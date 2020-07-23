%created by Sneh Kothari


classdef cyclo_rl < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        UIAxes                          matlab.ui.control.UIAxes
        SupplyVoltageEditFieldLabel     matlab.ui.control.Label
        SupplyVoltageEditField          matlab.ui.control.NumericEditField
        FrequencyEditFieldLabel         matlab.ui.control.Label
        FrequencyEditField              matlab.ui.control.NumericEditField
        FiringAngleSliderLabel          matlab.ui.control.Label
        FiringAngleSlider               matlab.ui.control.Slider
        OutputVoltageTextAreaLabel      matlab.ui.control.Label
        OutputVoltageTextArea           matlab.ui.control.TextArea
        ValueofExtinctionangleTextAreaLabel  matlab.ui.control.Label
        ValueofExtinctionangleTextArea  matlab.ui.control.TextArea
        InductivereactanceohmEditFieldLabel  matlab.ui.control.Label
        InductivereactanceohmEditField  matlab.ui.control.NumericEditField
        ResistanceEditFieldLabel        matlab.ui.control.Label
        ResistanceEditField             matlab.ui.control.NumericEditField
        UIAxes_2                        matlab.ui.control.UIAxes
        OutputCurrentTextAreaLabel      matlab.ui.control.Label
        OutputCurrentTextArea           matlab.ui.control.TextArea
        CycloconverterwithRLLoadDiscontinuousLabel  matlab.ui.control.Label
        MultipleoffundamentalfrequencyLabel  matlab.ui.control.Label
        MultipleoffundamentalfrequencyEditField  matlab.ui.control.NumericEditField
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Value changing function: FiringAngleSlider
        function FiringAngleSliderValueChanging(app, event)
            ad = event.Value; %firing angle in degree
            m = app.MultipleoffundamentalfrequencyEditField.Value;
            vr = app.SupplyVoltageEditField.Value;
            vm = vr*sqrt(2); %calcuatigng the maximum voltage
            f = app.FrequencyEditField.Value; %frequency
            a = ad*pi/180; %conversion of firing angle into radian
            r = app.ResistanceEditField.Value;
            xl = app.InductivereactanceohmEditField.Value;
            l = xl/(2*pi*f); %calculation of inductance
            phi = atan(xl/r); %calculation of power factor angle
            %Here value of b is solved symbolically using vpasolve method
            syms b
            eqn = sin(b-phi) - sin(a - phi)*exp((r/l)*(a-b)/(2*pi*f)) == 0;
            S = vpasolve(eqn,b,pi);
            b = S*180/pi;
            bmin = double(b);
            z = sqrt(r^2+xl^2); %calculation fo impedance
            if (ad>(bmin-180))
                app.ValueofExtinctionangleTextArea.Value = num2str(bmin);
                t = 0:0.00001:1/(2*f); %%take time for first positive cycle only
                t = t(1:end-1); %%to avoid overlapping at zero volatage points
                at = ad/(360*f); %%conversion of firing angle to its equivalent time
                bt = bmin/(360*f);
                ta = [];
                for k = 1:length(t)
                    if (t(k) > (bt-(1/(2*f))))
                        if (t(k) < at) %%if time is less than firing time, consider it as zero
                            ta = [ta 0];
                        else
                            ta = [ta t(k)];
                        end
                    else
                        ta = [ta -t(k)];
                    end
                end
                vo = vm*sin(2*pi*f*ta);
                i = zeros(1,(length(t)));
                %here current value is calculated for postive cycle and it
                %is converted into negative cycle by shifting it by half cycle
                for o = 1:length(t)
                    if (t(o) > at)
                        i(o) = (vm/z)*(sin(2*pi*f*t(o)-phi) - sin(a-phi)*exp((r/l)*(((a/(2*pi*f))-t(o)))));
                    end
                    if (t(o) < (bt-(1/(2*f))))
                        ts = t(o) + 1/(2*f);
                        i(o) = (vm/z)*(sin(2*pi*f*ts-phi) - sin(a-phi)*exp((r/l)*(((a/(2*pi*f))-ts))));
                    end
                end
                vout = [];
                iout = [];
                p = 0;
                for y = 1:2*m
                    if mod(p,2)==0
                        vout = [vout vo];
                        iout = [iout i];
                    else
                        vout = [vout -vo];
                        iout = [iout -i];
                    end
                    if mod(y,m)==0
                        p = p+1;
                    end
                end
                
                tp = linspace(0,m/f,length(vout));
                for u = 1:length(vout)
                    if and((tp(u) > m/(2*f)),(tp(u) < 1.001*((m-1)/(2*f) + bt)))
                        vout(u) = -vout(u);
                        iout(u) = -iout(u);
                    end
                    if (tp(u) < at)
                        iout(u) = -iout(u);
                    end
                end
                plot(app.UIAxes,tp,vout)
                app.UIAxes.YLim = [-1.1*(vm) 1.1*(vm)];
                app.UIAxes.XLim = [0 m/(f)];
                vorms = rms(vout);
                app.OutputVoltageTextArea.Value = num2str(vorms);
                
                plot(app.UIAxes_2,tp,iout)
                app.UIAxes_2.YLim = [-1.1*(vm/z) 1.1*(vm/z)];
                app.UIAxes_2.XLim = [0 m/f];
                app.OutputCurrentTextArea.Value = num2str(rms(iout));
                %}
            else
                app.ValueofExtinctionangleTextArea.Value = 'enter new alpha';
                app.OutputCurrentTextArea.Value = 'error';
                app.OutputVoltageTextArea.Value = 'error';
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 782 678];
            app.UIFigure.Name = 'UI Figure';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Voltage')
            xlabel(app.UIAxes, 'Time')
            ylabel(app.UIAxes, 'Voltage')
            app.UIAxes.XLim = [0 0.02];
            app.UIAxes.XGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.Position = [1 401 782 245];

            % Create SupplyVoltageEditFieldLabel
            app.SupplyVoltageEditFieldLabel = uilabel(app.UIFigure);
            app.SupplyVoltageEditFieldLabel.HorizontalAlignment = 'right';
            app.SupplyVoltageEditFieldLabel.Position = [13 131 86 22];
            app.SupplyVoltageEditFieldLabel.Text = 'Supply Voltage';

            % Create SupplyVoltageEditField
            app.SupplyVoltageEditField = uieditfield(app.UIFigure, 'numeric');
            app.SupplyVoltageEditField.Limits = [0 Inf];
            app.SupplyVoltageEditField.Position = [103 131 39 22];
            app.SupplyVoltageEditField.Value = 230;

            % Create FrequencyEditFieldLabel
            app.FrequencyEditFieldLabel = uilabel(app.UIFigure);
            app.FrequencyEditFieldLabel.HorizontalAlignment = 'right';
            app.FrequencyEditFieldLabel.Position = [153 131 62 22];
            app.FrequencyEditFieldLabel.Text = 'Frequency';

            % Create FrequencyEditField
            app.FrequencyEditField = uieditfield(app.UIFigure, 'numeric');
            app.FrequencyEditField.Position = [219 131 39 22];
            app.FrequencyEditField.Value = 50;

            % Create FiringAngleSliderLabel
            app.FiringAngleSliderLabel = uilabel(app.UIFigure);
            app.FiringAngleSliderLabel.HorizontalAlignment = 'right';
            app.FiringAngleSliderLabel.Position = [13 98 70 22];
            app.FiringAngleSliderLabel.Text = 'Firing Angle';

            % Create FiringAngleSlider
            app.FiringAngleSlider = uislider(app.UIFigure);
            app.FiringAngleSlider.Limits = [0 180];
            app.FiringAngleSlider.ValueChangingFcn = createCallbackFcn(app, @FiringAngleSliderValueChanging, true);
            app.FiringAngleSlider.Position = [91 107 672 3];
            app.FiringAngleSlider.Value = 30;

            % Create OutputVoltageTextAreaLabel
            app.OutputVoltageTextAreaLabel = uilabel(app.UIFigure);
            app.OutputVoltageTextAreaLabel.HorizontalAlignment = 'right';
            app.OutputVoltageTextAreaLabel.Position = [378 29 85 22];
            app.OutputVoltageTextAreaLabel.Text = 'Output Voltage';

            % Create OutputVoltageTextArea
            app.OutputVoltageTextArea = uitextarea(app.UIFigure);
            app.OutputVoltageTextArea.Position = [470 24 73 29];

            % Create ValueofExtinctionangleTextAreaLabel
            app.ValueofExtinctionangleTextAreaLabel = uilabel(app.UIFigure);
            app.ValueofExtinctionangleTextAreaLabel.HorizontalAlignment = 'right';
            app.ValueofExtinctionangleTextAreaLabel.Position = [90 31 137 22];
            app.ValueofExtinctionangleTextAreaLabel.Text = 'Value of Extinction angle';

            % Create ValueofExtinctionangleTextArea
            app.ValueofExtinctionangleTextArea = uitextarea(app.UIFigure);
            app.ValueofExtinctionangleTextArea.Position = [232 26 123 29];

            % Create InductivereactanceohmEditFieldLabel
            app.InductivereactanceohmEditFieldLabel = uilabel(app.UIFigure);
            app.InductivereactanceohmEditFieldLabel.HorizontalAlignment = 'right';
            app.InductivereactanceohmEditFieldLabel.Position = [269 131 144 22];
            app.InductivereactanceohmEditFieldLabel.Text = 'Inductive reactance (ohm)';

            % Create InductivereactanceohmEditField
            app.InductivereactanceohmEditField = uieditfield(app.UIFigure, 'numeric');
            app.InductivereactanceohmEditField.Limits = [0 Inf];
            app.InductivereactanceohmEditField.Position = [417 131 34 22];
            app.InductivereactanceohmEditField.Value = 5;

            % Create ResistanceEditFieldLabel
            app.ResistanceEditFieldLabel = uilabel(app.UIFigure);
            app.ResistanceEditFieldLabel.HorizontalAlignment = 'right';
            app.ResistanceEditFieldLabel.Position = [462 131 65 22];
            app.ResistanceEditFieldLabel.Text = 'Resistance';

            % Create ResistanceEditField
            app.ResistanceEditField = uieditfield(app.UIFigure, 'numeric');
            app.ResistanceEditField.Limits = [0 Inf];
            app.ResistanceEditField.Position = [542 131 47 22];
            app.ResistanceEditField.Value = 15;

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.UIFigure);
            title(app.UIAxes_2, 'current')
            xlabel(app.UIAxes_2, 'Time')
            ylabel(app.UIAxes_2, 'Current')
            app.UIAxes_2.XLim = [0 0.02];
            app.UIAxes_2.XGrid = 'on';
            app.UIAxes_2.YGrid = 'on';
            app.UIAxes_2.Position = [1 155 782 236];

            % Create OutputCurrentTextAreaLabel
            app.OutputCurrentTextAreaLabel = uilabel(app.UIFigure);
            app.OutputCurrentTextAreaLabel.HorizontalAlignment = 'right';
            app.OutputCurrentTextAreaLabel.Position = [560 28 85 22];
            app.OutputCurrentTextAreaLabel.Text = 'Output Current';

            % Create OutputCurrentTextArea
            app.OutputCurrentTextArea = uitextarea(app.UIFigure);
            app.OutputCurrentTextArea.Position = [652 23 69 29];

            % Create CycloconverterwithRLLoadDiscontinuousLabel
            app.CycloconverterwithRLLoadDiscontinuousLabel = uilabel(app.UIFigure);
            app.CycloconverterwithRLLoadDiscontinuousLabel.HorizontalAlignment = 'center';
            app.CycloconverterwithRLLoadDiscontinuousLabel.FontSize = 18;
            app.CycloconverterwithRLLoadDiscontinuousLabel.FontWeight = 'bold';
            app.CycloconverterwithRLLoadDiscontinuousLabel.Position = [192 645 404 22];
            app.CycloconverterwithRLLoadDiscontinuousLabel.Text = 'Cycloconverter with RL Load (Discontinuous)';

            % Create MultipleoffundamentalfrequencyLabel
            app.MultipleoffundamentalfrequencyLabel = uilabel(app.UIFigure);
            app.MultipleoffundamentalfrequencyLabel.HorizontalAlignment = 'right';
            app.MultipleoffundamentalfrequencyLabel.Position = [591 119 133 47];
            app.MultipleoffundamentalfrequencyLabel.Text = {'Multiple of fundamental'; 'frequency'};

            % Create MultipleoffundamentalfrequencyEditField
            app.MultipleoffundamentalfrequencyEditField = uieditfield(app.UIFigure, 'numeric');
            app.MultipleoffundamentalfrequencyEditField.Position = [735 131 39 22];
            app.MultipleoffundamentalfrequencyEditField.Value = 3;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = cyclo_rl

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