classdef suj < dynamicprops
    % Class used to interface with ROS dVRK SUJ topics and convert to useful
    % Matlab commands and properties.  To create a robot interface:
    %   s = suj();
    %   s
    %
    % To home and check current state:
    %   s.home();
    %
    % Naming follows CRTK convention

    % values set by this class, can be read by others
    properties (Access = protected)
         ros_namespace;
         ral;
    end

    properties (SetAccess = immutable)
        PSM1;
        PSM2;
        PSM3;
        ECM;
    end

    methods

        function [name] = name(self)
            name = self.ros_namespace;
        end

        function self = suj(name, ral)
            if strcmp(name, '')
                name = 'SUJ';
            end
            self.ros_namespace = name;
            self.ral = ral;
            self.PSM1 = dvrk.suj_arm(strcat(self.ros_namespace, '/PSM1'), ral);
            self.PSM2 = dvrk.suj_arm(strcat(self.ros_namespace, '/PSM2'), ral);
            self.PSM3 = dvrk.suj_arm(strcat(self.ros_namespace, '/PSM3'), ral);
            self.ECM = dvrk.suj_arm(strcat(self.ros_namespace, '/ECM'), ral);
        end

        function delete(self)
           delete(self.PSM1);
           delete(self.PSM2);
           delete(self.PSM3);
           delete(self.ECM);
           delete(self.ral);
        end

    end

end
