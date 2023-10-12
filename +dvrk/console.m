classdef console < handle
    % Class used to interface with ROS dVRK console topics and convert to useful
    % Matlab commands and properties.  To create a console interface:
    %   c = console();
    %   c
    %

    % settings that are not supposed to change after constructor
    properties (SetAccess = immutable)
        ros_namespace % namespace for this arm, should contain head/tail / (default is '')
        ral
    end

    % only this class methods can view/modify
    properties (Access = private)
        % subscribers
        teleop_scale_subscriber
        % publishers
        power_off_publisher
        power_on_publisher
        home_publisher
        teleop_enable_publisher
        teleop_set_scale_publisher
    end

    methods

        function self = console(namespace, ral)
            % Create a console interface.  The namespace
            % default is empty.
            self.ros_namespace = namespace;
            self.ral = ral;

            % ----------- subscribers
            % teleop scale
            topic = strcat(self.ros_namespace, 'console/teleop/scale');
            self.teleop_scale_subscriber = ...
                self.ral.subscriber(topic, rostype.std_msgs_Float64);

            % ----------- publishers
            % power off
            topic = strcat(self.ros_namespace, 'console/power_off');
            self.power_off_publisher = self.ral.publisher(topic, rostype.std_msgs_Empty);

            % power on
            topic = strcat(self.ros_namespace, 'console/power_on');
            self.power_on_publisher = self.ral.publisher(topic, rostype.std_msgs_Empty);

            % home
            topic = strcat(self.ros_namespace, 'console/home');
            self.home_publisher = self.ral.publisher(topic, rostype.std_msgs_Empty);

            % teleop enable
            topic = strcat(self.ros_namespace, 'console/teleop/enable');
            self.teleop_enable_publisher = self.ral.publisher(topic, rostype.std_msgs_Bool);

            % teleop set scale
            topic = strcat(self.ros_namespace, 'console/teleop/set_scale');
            self.teleop_set_scale_publisher = self.ral.publisher(topic, rostype.std_msgs_Float64);
        end




        function delete(self)
            delete(self.teleop_scale_subscriber);
        end


        function scale = teleop_get_scale(self)
           % Accessor used to retrieve the last teleop scale
           scale = self.teleop_scale_subscriber.LatestMessage.data;
        end

        function power_off(self)
            message = self.ral.message(self.power_off_publisher);
            send(self.power_off_publisher, message);
        end

        function power_on(self)
            message = self.ral.message(self.power_on_publisher);
            send(self.power_on_publisher, message);
        end

        function home(self)
            message = self.ral.message(self.home_publisher);
            send(self.home_publisher, message);
        end

        function teleop_start(self)
            message = self.ral.message(self.teleop_enable_publisher);
            message.data = true;
            send(self.teleop_enable_publisher, message);
        end

        function teleop_stop(self)
            message = self.ral.message(self.teleop_enable_publisher);
            message.data = false;
            send(self.teleop_enable_publisher, message);
        end

        function teleop_set_scale(self, scale)
            message = self.ral.message(self.teleop_set_scale_publisher);
            message.data = scale;
            message
            send(self.teleop_set_scale_publisher, message);
        end

    end

end
