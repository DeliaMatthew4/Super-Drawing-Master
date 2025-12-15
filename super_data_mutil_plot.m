%% 初始化环境
clc; clear; close all;
set(groot, 'defaultAxesFontName', 'Arial');
set(groot, 'defaultTextFontName', 'Arial');
% =================【自动定位路径】=================
script_fullpath = mfilename('fullpath');
[script_folder, ~, ~] = fileparts(script_fullpath);
if ~isempty(script_folder)
    cd(script_folder);
    fprintf('Working directory changed to: %s\n', script_folder);
end
% 定义全局颜色顺序
global_color_order = [0 0.4470 0.7410;   % 深蓝色 (左)
                      0.3010 0.7450 0.9330; % 浅蓝色 (右)
                      0.8500 0.3250 0.0980; % 橙色 (目标)
                      0.4940 0.1840 0.5560]; % 紫色 (实际)

%% 【配置区域】在这里修改文件名
% 请输入文件名（不包含 .csv 后缀）
data_raw_name = 'motor_data_20251126_220501'; %这里修改文件
data_name = data_raw_name;

%% 数据加载
% 拼接 .csv 后缀
data_path = [data_name, '.csv']; 
fprintf('Loading data from: %s\n', data_path);
if ~isfile(data_path)
    error('文件 %s 不存在，请检查文件名或路径。', data_path);
end
data = readtable(data_path, 'Delimiter', ',');
% 时间转换（毫秒 -> 秒）
time = (data.Timestamp - data.Timestamp(1)) / 1000; % 相对时间

%% 数据提取 - 使用实际列名
% 高度数据
target_height = data.TargetHeight;
actual_height = data.ActualHeight;

% 速度数据 (m/s)
target_speed = data.TargetSpeed;
actual_speed = data.ActualSpeed;

% 关节数据
% 左关节
joint_left = struct(...
    'target_vel', data.LJoint_TargetVel, ...
    'actual_vel', data.LJoint_ActualVel, ...
    'target_torque', data.LJoint_TargetTorque, ...
    'actual_torque', data.LJoint_ActualTorque);

% 右关节
joint_right = struct(...
    'target_vel', data.RJoint_TargetVel, ...
    'actual_vel', data.RJoint_ActualVel, ...
    'target_torque', data.RJoint_TargetTorque, ...
    'actual_torque', data.RJoint_ActualTorque);

% 轮毂数据
% 左轮毂
wheel_left = struct(...
    'target_vel', data.LWheel_TargetVel, ...
    'actual_vel', data.LWheel_ActualVel, ...
    'target_torque', data.LWheel_TargetTorque, ...
    'actual_torque', data.LWheel_ActualTorque);

% 右轮毂
wheel_right = struct(...
    'target_vel', data.RWheel_TargetVel, ...
    'actual_vel', data.RWheel_ActualVel, ...
    'target_torque', data.RWheel_TargetTorque, ...
    'actual_torque', data.RWheel_ActualTorque);

% 姿态数据
target_roll = data.TargetRoll;
actual_roll = data.ActualRoll;
target_pitch = data.TargetPitch;
actual_pitch = data.ActualPitch;
% 兼容性处理：如果TargetYaw不存在，尝试只取Yaw
if ismember('TargetYaw', data.Properties.VariableNames)
    target_yaw = data.TargetYaw;
    actual_yaw = data.ActualYaw;
else
    % 假设 Yaw 列存在且代表实际值
    target_yaw = zeros(size(data.Yaw)); % 或者是 data.Yaw 的初始值
    actual_yaw = data.Yaw; 
end

% 腿长数据
leg_left = struct(...
    'target_len', data.LLeg_TargetLen, ...
    'actual_len', data.LLeg_ActualLen);

leg_right = struct(...
    'target_len', data.RLeg_TargetLen, ...
    'actual_len', data.RLeg_ActualLen);

% 计算轮毂功率 (P = ω * τ)
wheel_left.power = wheel_left.actual_vel .* wheel_left.actual_torque;
wheel_right.power = wheel_right.actual_vel .* wheel_right.actual_torque;

label_style = {'FontSize', 8, 'BackgroundColor', 'w', 'EdgeColor', 'k', 'Margin', 1};

%% 定义图表配置
% 每个图表都可以配置是否在总图中显示 (subplot_pos) 和是否单独保存 (save_separate)
plot_configs = struct();

plot_configs(1).name = 'Height Comparison';
plot_configs(1).subplot_pos = [4,3,1];
plot_configs(1).save_separate = false;

plot_configs(2).name = 'Speed Comparison';
plot_configs(2).subplot_pos = [4,3,2];
plot_configs(2).save_separate = false;

plot_configs(3).name = 'Joint Velocity';
plot_configs(3).subplot_pos = [4,3,4];
plot_configs(3).save_separate = false;

plot_configs(4).name = 'Joint Torque';
plot_configs(4).subplot_pos = [4,3,5];
plot_configs(4).save_separate = true; % 单独窗口 关节扭矩图

plot_configs(5).name = 'Wheel Velocity';
plot_configs(5).subplot_pos = [4,3,7];
plot_configs(5).save_separate = false;

plot_configs(6).name = 'Wheel Torque';
plot_configs(6).subplot_pos = [4,3,8];
plot_configs(6).save_separate = true;

plot_configs(7).name = 'Roll Angle';
plot_configs(7).subplot_pos = [4,3,3];
plot_configs(7).save_separate = false;

plot_configs(8).name = 'Pitch Angle';
plot_configs(8).subplot_pos = [4,3,6];
plot_configs(8).save_separate = false;

plot_configs(9).name = 'Yaw Angle';
plot_configs(9).subplot_pos = [4,3,9];
plot_configs(9).save_separate = false;

plot_configs(10).name = 'Actual Leg Lengths';
plot_configs(10).subplot_pos = [4,3,10];
plot_configs(10).save_separate = false;

plot_configs(11).name = 'Wheel Power';
plot_configs(11).subplot_pos = [4,3,11];
plot_configs(11).save_separate = false;

%% 创建所有图表的主窗口
main_figure = figure('Name', ['Metrics: ' data_name], 'Position', [100 100 1400 900], 'Color', 'w');

for i = 1:length(plot_configs)
    config = plot_configs(i);

    % 在主图中绘制子图
    figure(main_figure);
    subplot(config.subplot_pos(1), config.subplot_pos(2), config.subplot_pos(3));
    draw_plot(config.name, time, global_color_order, label_style, ...
              target_height, actual_height, target_speed, actual_speed, ...
              joint_left, joint_right, wheel_left, wheel_right, ...
              target_roll, actual_roll, target_pitch, actual_pitch, ...
              target_yaw, actual_yaw, leg_left, leg_right);

    % 如果配置了单独窗口显示，则单独创建一个图
    if config.save_separate
        f_single = figure('Name', ['Single - ' config.name], ...
                          'Position', [100 100 800 600], 'Color', 'w');
        draw_plot(config.name, time, global_color_order, label_style, ...
                  target_height, actual_height, target_speed, actual_speed, ...
                  joint_left, joint_right, wheel_left, wheel_right, ...
                  target_roll, actual_roll, target_pitch, actual_pitch, ...
                  target_yaw, actual_yaw, leg_left, leg_right);
        ax_single = gca;
        set(ax_single, 'FontSize', 12, 'LineWidth', 1.5);
        legend_obj = findobj(ax_single, 'Type', 'Legend');
        if ~isempty(legend_obj)
            set(legend_obj, 'Location', 'best');
        end
        % 切回主窗口，确保下次循环操作的还是主窗口
        figure(main_figure);
    end
end

% 调整主图的子图间距
figure(main_figure);
set(gcf, 'Units', 'normalized');
set(gcf, 'Position', [0.05 0.05 0.9 0.9]);
h_axes = findobj(gcf, 'type', 'axes');
set(h_axes, 'FontSize', 10, 'LineWidth', 1.2);

%% 是否保存总图？ ctrl+R
% 总图文件名：[原文件名]_combined.png
% combined_filename = [data_name, '_combined.png'];
% saveas(main_figure, combined_filename);
% fprintf('Combined visualization completed. Saved as: %s\n', combined_filename);

%% 通用绘图函数
function draw_plot(plot_name, time, colors, label_style, ...
                   target_height, actual_height, target_speed, actual_speed, ...
                   joint_left, joint_right, wheel_left, wheel_right, ...
                   target_roll, actual_roll, target_pitch, actual_pitch, target_yaw, actual_yaw, ...
                   leg_left, leg_right)
hold off;
cla;
            
switch plot_name
    case 'Height Comparison'
        plot(time, target_height, '--', 'Color', colors(3,:), 'LineWidth', 1.5); hold on;
        plot(time, actual_height, '-', 'Color', colors(4,:), 'LineWidth', 1.5);
        title('Height Comparison'); ylabel('Height (m)');
        legend('Target', 'Actual', 'Location', 'best'); grid on; box off;
        [val_max, idx_max] = max(actual_height); [val_min, idx_min] = min(actual_height);
        text(time(idx_max), val_max, sprintf('Max: %.3f', val_max), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', label_style{:});
        text(time(idx_min), val_min, sprintf('Min: %.3f', val_min), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', label_style{:});

    case 'Speed Comparison'
        plot(time, target_speed, '--', 'Color', colors(3,:), 'LineWidth', 1.5); hold on;
        plot(time, actual_speed, '-', 'Color', colors(4,:), 'LineWidth', 1.5);
        title('Speed Comparison'); ylabel('Speed (m/s)'); grid on; box off;
        [val_max, idx_max] = max(actual_speed); [val_min, idx_min] = min(actual_speed);
        text(time(idx_max), val_max, sprintf('Max: %.3f', val_max), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', label_style{:});
        text(time(idx_min), val_min, sprintf('Min: %.3f', val_min), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', label_style{:});

    case 'Joint Velocity'
        plot(time, joint_left.target_vel, '--', 'Color', colors(1,:), 'LineWidth', 1.5); hold on;
        plot(time, joint_left.actual_vel, '-', 'Color', colors(1,:), 'LineWidth', 1.5);
        plot(time, joint_right.target_vel, '--', 'Color', colors(2,:), 'LineWidth', 1.5);
        plot(time, joint_right.actual_vel, '-', 'Color', colors(2,:), 'LineWidth', 1.5);
        title('Joint Velocity'); ylabel('Velocity (rad/s)');
        legend('Left Target', 'Left Actual', 'Right Target', 'Right Actual', 'Location', 'best'); grid on; box off;
        [val_max, idx_max] = max(joint_left.actual_vel); [val_min, idx_min] = min(joint_left.actual_vel);
        text(time(idx_max), val_max, sprintf('L Max: %.3f', val_max), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', label_style{:});
        text(time(idx_min), val_min, sprintf('L Min: %.3f', val_min), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', label_style{:});
        [val_max, idx_max] = max(joint_right.actual_vel); [val_min, idx_min] = min(joint_right.actual_vel);
        text(time(idx_max), val_max, sprintf('R Max: %.3f', val_max), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', label_style{:});
        text(time(idx_min), val_min, sprintf('R Min: %.3f', val_min), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', label_style{:});

    case 'Joint Torque'
        plot(time, joint_left.target_torque, '--', 'Color', colors(1,:), 'LineWidth', 1.5); hold on;
        plot(time, joint_left.actual_torque, '-', 'Color', colors(1,:), 'LineWidth', 1.5);
        plot(time, joint_right.target_torque, '--', 'Color', colors(2,:), 'LineWidth', 1.5);
        plot(time, joint_right.actual_torque, '-', 'Color', colors(2,:), 'LineWidth', 1.5);
        title('Joint Torque'); ylabel('Torque (Nm)'); grid on; box off;
        [val_max, idx_max] = max(joint_left.actual_torque); [val_min, idx_min] = min(joint_left.actual_torque);
        text(time(idx_max), val_max, sprintf('L Max: %.3f', val_max), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', label_style{:});
        text(time(idx_min), val_min, sprintf('L Min: %.3f', val_min), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', label_style{:});
        [val_max, idx_max] = max(joint_right.actual_torque); [val_min, idx_min] = min(joint_right.actual_torque);
        text(time(idx_max), val_max, sprintf('R Max: %.3f', val_max), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', label_style{:});
        text(time(idx_min), val_min, sprintf('R Min: %.3f', val_min), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', label_style{:});

    case 'Wheel Velocity'
        plot(time, wheel_left.target_vel, '--', 'Color', colors(1,:), 'LineWidth', 1.5); hold on;
        plot(time, wheel_left.actual_vel, '-', 'Color', colors(1,:), 'LineWidth', 1.5);
        plot(time, wheel_right.target_vel, '--', 'Color', colors(2,:), 'LineWidth', 1.5);
        plot(time, wheel_right.actual_vel, '-', 'Color', colors(2,:), 'LineWidth', 1.5);
        title('Wheel Velocity'); ylabel('Velocity (rad/s)'); grid on; box off;
        [val_max, idx_max] = max(wheel_left.actual_vel); [val_min, idx_min] = min(wheel_left.actual_vel);
        text(time(idx_max), val_max, sprintf('L Max: %.3f', val_max), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', label_style{:});
        text(time(idx_min), val_min, sprintf('L Min: %.3f', val_min), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', label_style{:});
        [val_max, idx_max] = max(wheel_right.actual_vel); [val_min, idx_min] = min(wheel_right.actual_vel);
        text(time(idx_max), val_max, sprintf('R Max: %.3f', val_max), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', label_style{:});
        text(time(idx_min), val_min, sprintf('R Min: %.3f', val_min), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', label_style{:});

    case 'Wheel Torque'
        plot(time, wheel_left.target_torque, '--', 'Color', colors(1,:), 'LineWidth', 1.5); hold on;
        plot(time, wheel_left.actual_torque, '-', 'Color', colors(1,:), 'LineWidth', 1.5);
        plot(time, wheel_right.target_torque, '--', 'Color', colors(2,:), 'LineWidth', 1.5);
        plot(time, wheel_right.actual_torque, '-', 'Color', colors(2,:), 'LineWidth', 1.5);
        title('Wheel Torque'); ylabel('Torque (Nm)'); grid on; box off;
        [val_max, idx_max] = max(wheel_left.actual_torque); [val_min, idx_min] = min(wheel_left.actual_torque);
        text(time(idx_max), val_max, sprintf('L Max: %.3f', val_max), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', label_style{:});
        text(time(idx_min), val_min, sprintf('L Min: %.3f', val_min), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', label_style{:});
        [val_max, idx_max] = max(wheel_right.actual_torque); [val_min, idx_min] = min(wheel_right.actual_torque);
        text(time(idx_max), val_max, sprintf('R Max: %.3f', val_max), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', label_style{:});
        text(time(idx_min), val_min, sprintf('R Min: %.3f', val_min), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', label_style{:});

    case 'Roll Angle'
        plot(time, target_roll, '--', 'Color', colors(3,:), 'LineWidth', 1.5); hold on;
        plot(time, actual_roll, '-', 'Color', colors(4,:), 'LineWidth', 1.5);
        title('Roll Angle'); ylabel('Angle (rad)'); legend('Target', 'Actual', 'Location', 'best'); grid on; box off;
        [val_max, idx_max] = max(actual_roll); [val_min, idx_min] = min(actual_roll);
        text(time(idx_max), val_max, sprintf('Max: %.3f', val_max), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', label_style{:});
        text(time(idx_min), val_min, sprintf('Min: %.3f', val_min), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', label_style{:});

    case 'Pitch Angle'
        plot(time, target_pitch, '--', 'Color', colors(3,:), 'LineWidth', 1.5); hold on;
        plot(time, actual_pitch, '-', 'Color', colors(4,:), 'LineWidth', 1.5);
        title('Pitch Angle'); ylabel('Angle (rad)'); grid on; box off;
        [val_max, idx_max] = max(actual_pitch); [val_min, idx_min] = min(actual_pitch);
        text(time(idx_max), val_max, sprintf('Max: %.3f', val_max), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', label_style{:});
        text(time(idx_min), val_min, sprintf('Min: %.3f', val_min), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', label_style{:});

    case 'Yaw Angle'
        if all(target_yaw == target_yaw(1)) && target_yaw(1) == 0 && ~all(actual_yaw == actual_yaw(1))
            plot(time, actual_yaw, '-', 'Color', colors(4,:), 'LineWidth', 1.5); legend('Actual', 'Location', 'best');
        else
            plot(time, target_yaw, '--', 'Color', colors(3,:), 'LineWidth', 1.5); hold on;
            plot(time, actual_yaw, '-', 'Color', colors(4,:), 'LineWidth', 1.5); legend('Target', 'Actual', 'Location', 'best');
        end
        title('Yaw Angle'); ylabel('Angle (rad)'); grid on; box off;
        [val_max, idx_max] = max(actual_yaw); [val_min, idx_min] = min(actual_yaw);
        text(time(idx_max), val_max, sprintf('Max: %.3f', val_max), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', label_style{:});
        text(time(idx_min), val_min, sprintf('Min: %.3f', val_min), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', label_style{:});

    case 'Actual Leg Lengths'
        plot(time, leg_left.actual_len, '-', 'Color', colors(1,:), 'LineWidth', 1.5); hold on;
        plot(time, leg_right.actual_len, '-', 'Color', colors(2,:), 'LineWidth', 1.5);
        title('Actual Leg Lengths'); xlabel('Time (s)'); ylabel('Length (m)');
        legend('Left Actual', 'Right Actual', 'Location', 'best'); grid on; box off;
        [val_max, idx_max] = max(leg_left.actual_len); [val_min, idx_min] = min(leg_left.actual_len);
        text(time(idx_max), val_max, sprintf('L Max: %.3f', val_max), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', label_style{:});
        text(time(idx_min), val_min, sprintf('L Min: %.3f', val_min), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', label_style{:});
        [val_max, idx_max] = max(leg_right.actual_len); [val_min, idx_min] = min(leg_right.actual_len);
        text(time(idx_max), val_max, sprintf('R Max: %.3f', val_max), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', label_style{:});
        text(time(idx_min), val_min, sprintf('R Min: %.3f', val_min), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', label_style{:});

    case 'Wheel Power'
        plot(time, wheel_left.power, '-', 'Color', colors(1,:), 'LineWidth', 1.5); hold on;
        plot(time, wheel_right.power, '-', 'Color', colors(2,:), 'LineWidth', 1.5);
        plot([min(time) max(time)], [0 0], 'k--', 'LineWidth', 0.5);
        title('Wheel Power'); xlabel('Time (s)'); ylabel('Power (W)');
        legend('Left Wheel', 'Right Wheel', 'Location', 'best'); grid on; box off;
        [max_power, idx] = max(wheel_left.power); text(time(idx), max_power, sprintf('L Max:%.1f', max_power), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', label_style{:});
        [min_power, idx] = min(wheel_left.power); text(time(idx), min_power, sprintf('L Min:%.1f', min_power), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', label_style{:});
        [max_power, idx] = max(wheel_right.power); text(time(idx), max_power, sprintf('R Max:%.1f', max_power), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', label_style{:});
        [min_power, idx] = min(wheel_right.power); text(time(idx), min_power, sprintf('R Min:%.1f', min_power), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', label_style{:});

    otherwise
        warning('Unknown plot name: %s', plot_name);
end
end
