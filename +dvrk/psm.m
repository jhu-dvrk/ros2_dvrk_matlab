classdef psm < dvrk.arm
    % Class for PSM specific features
    % only this class methods can view/modify
    properties (Access = protected)
        % publishers
        set_tool_present_publisher;
        trajectory_j_set_ratio_publisher;
        % subscribers
        trajectory_j_ratio_subscriber;
    end

    properties (SetAccess = immutable)
        jaw;
    end

    methods

        function self = psm(name, ral)
            self@dvrk.arm(name, ral);
            self.jaw = dvrk.psm_jaw(strcat(name, '/jaw'), self, ral);
            % ----------- publishers
            topic = strcat(self.ros_namespace, '/set_tool_present');
            self.set_tool_present_publisher = self.ral.publisher(topic, rostype.std_msgs_Bool);
            topic = strcat(self.ros_namespace, '/trajectory_j/set_ratio');
            self.trajectory_j_set_ratio_publisher = self.ral.publisher(topic, rostype.std_msgs_Float64);
            % ----------- subscribers
            topic = strcat(self.ros_namespace, '/trajectory_j/ratio');
            self.trajectory_j_ratio_subscriber = self.ral.subscriber(topic, rostype.std_msgs_Float64);
        end

        function delete(self)
            delete(self.jaw);
            delete(self.trajectory_j_ratio_subscriber);
        end

        function [time] = insert_jp(self, depth)
            p = self.setpoint_js();
            p(3) = depth;
            time =  self.move_jp(p);
        end

        function set_tool_present(self, tp)
            tp_message = self.ral.message(self.set_tool_present_publisher);
            tp_message.data = tp;
            % send message
            send(self.tool_present_publisher, ...
                 tp_message);
        end

        function trajectory_j_set_ratio(self, ratio)
            ratio_message = self.ral.message(self.trajectory_j_set_ratio_publisher);
            ratio_message.data = ratio;
            % send message
            send(self.trajectory_j_set_ratio_publisher, ...
                 ratio_message);
        end

        function ratio = trajectory_j_ratio(self)
            ratio = self.trajectory_j_ratio_subscriber.LatestMessage.data;
        end

    end

end
