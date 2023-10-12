classdef arm < dynamicprops & handle
    % Class used to interface with ROS dVRK arm topics and convert to useful
    % Matlab commands and properties.  To create a robot interface:
    %   r = arm('PSM1');
    %   r
    %
    % To home and check current state:
    %   r.home();
    %
    % Naming convention follows CRTK conventions

    % values set by this class, can be read by others
    properties (Access = protected)
        crtk_utils;
        ros_12;
        ros_namespace;
        % publishers
        wrench_body_orientation_absolute_publisher;
        gravity_compensation_publisher;
        % message placeholders
        std_msgs_Bool;
        cleanup;
    end

    properties (SetAccess = immutable)
        body;
        spatial;
        local;
    end

    methods

        function [name] = name(self)
            name = self.ros_namespace;
        end

        function self = arm(name, ros_12)
            self.ros_namespace = name;
            self.crtk_utils = crtk.utils(self, name, ros_12);
            self.ros_12 = ros_12;
            self.body = dvrk.arm_cf(strcat(name, '/body'), ros_12);
            self.spatial = dvrk.arm_cf(strcat(name, '/spatial'), ros_12);
            self.local = dvrk.arm_local(strcat(name, '/local'), ros_12);
            % operating state
            self.crtk_utils.add_operating_state();
            % joint space
            self.crtk_utils.add_measured_js();
            self.crtk_utils.add_setpoint_js();
            self.crtk_utils.add_servo_jp();
            self.crtk_utils.add_servo_jr();
            self.crtk_utils.add_servo_jf();
            self.crtk_utils.add_move_jp();
            self.crtk_utils.add_move_jr();
            % cartesian space
            self.crtk_utils.add_measured_cp();
            self.crtk_utils.add_measured_cv();
            self.crtk_utils.add_measured_cf();
            self.crtk_utils.add_setpoint_cp();
            self.crtk_utils.add_setpoint_cf();
            self.crtk_utils.add_servo_cp();
            self.crtk_utils.add_servo_cf();
            self.crtk_utils.add_move_cp();
            % custom publishers
            topic = strcat(self.ros_namespace, '/body_set_cf_orientation_absolute');
            self.wrench_body_orientation_absolute_publisher = ...
                self.ros_12.publisher(topic, rostype.std_msgs_Bool);
            topic = strcat(self.ros_namespace, '/use_gravity_compensation');
            self.gravity_compensation_publisher = ...
                self.ros_12.publisher(topic, rostype.std_msgs_Bool);
            % one time creation of messages to prevent lookup and creation at each call
            self.std_msgs_Bool = self.ros_12.message(rostype.std_msgs_Bool);

            self.cleanup = onCleanup(@()delete(self));
        end

        function delete(self)
            disp('deleting arm');
            delete(self.crtk_utils);
            delete(self.body);
            delete(self.spatial);
            delete(self.local);
        end

        function result = body_set_cf_orientation_absolute(self, absolute)
            self.std_msgs_Bool.Data = absolute;
            % send message
            send(self.wrench_body_orientation_absolute_publisher, ...
                 self.std_msgs_Bool);
            result = true;
        end

        function result = use_gravity_compensation(self, gravity)
            self.std_msgs_Bool.Data = gravity;
            % send message
            send(self.gravity_compensation_publisher, ...
                 self.std_msgs_Bool);
            result = true;
        end

    end

end
