classdef arm_local < dynamicprops
    properties (Access = protected)
        crtk_utils;
        ros_namespace;
    end

    methods

        function self = arm_local(name, ral)
            self.ros_namespace = name;
            self.crtk_utils = crtk.utils(self, name, ral);
            self.crtk_utils.add_measured_cp();
            self.crtk_utils.add_setpoint_cp();
        end

        function delete(self)
            delete(self.crtk_utils);
        end

    end

end
