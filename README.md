<h1>🤖 MATLAB 机器人数据可视化分析工具</h1>

<p><strong>一个专业的机器人运动数据分析工具</strong>，能够从CSV数据文件生成多种专业图表，用于机器人性能分析和算法验证。</p>

<div class="note">
<strong>📋 功能特色：</strong> 高度与速度分析 | 关节运动分析 | 轮毂性能分析 | 姿态角分析 | 腿长监测
</div>

<h2>🚀 快速开始</h2>

<h3>数据文件准备</h3>
<ul>
<li><strong>格式要求：</strong> CSV格式数据文件</li>
<li><strong>必需列：</strong> 时间戳、高度、速度、关节数据、轮毂数据、姿态角等</li>
<li><strong>位置：</strong> 文件应放置在脚本同目录下</li>
</ul>

<h3>基本使用步骤</h3>
<ol>
<li>修改配置区域的文件名：
<pre><code class="language-matlab">data_raw_name = 'your_data_file_name'; % 修改为实际文件名（不含.csv后缀）</code></pre>
</li>
<li>运行脚本，自动生成综合可视化图表</li>
</ol>

<h2>📊 图表配置系统</h2>

<p>脚本采用灵活的配置结构，支持主图布局和单独图表输出：</p>

<h3>主图布局</h3>
<ul>
<li>4×3网格布局显示11个关键指标图表</li>
<li>统一配色方案和字体设置</li>
<li>自动极值标注功能</li>
</ul>

<h3>单独图表输出</h3>
<p>特定重要图表（如关节扭矩）可单独显示和保存：</p>
<pre><code class="language-matlab">plot_configs(4).save_separate = true; % 关节扭矩图单独显示</code></pre>

<h2>🎨 核心功能模块</h2>

<h3>数据加载与处理</h3>
<ul>
<li><strong>自动路径定位</strong>和时间戳转换</li>
<li>多数据类型提取（关节、轮毂、姿态等）</li>
<li><strong>功率计算：</strong> <code>P = ω × τ</code></li>
</ul>

<h3>可视化特性</h3>
<ul>
<li>目标值 vs 实际值对比显示</li>
<li>极值自动标注（最大值/最小值）</li>
<li><strong>专业配色方案：</strong>
    <ul>
    <li>🔵 深蓝色：左关节/轮毂</li>
    <li>🔷 浅蓝色：右关节/轮毂</li>
    <li>🟠 橙色：目标值</li>
    <li>🟣 紫色：实际值</li>
    </ul>
</li>
</ul>

<h3>📈 图表类型总览</h3>
<table>
<tr><th>编号</th><th>图表名称</th><th>描述</th><th>关键指标</th></tr>
<tr><td>1</td><td><strong>高度对比</strong></td><td>机器人高度跟踪性能</td><td>目标vs实际高度</td></tr>
<tr><td>2</td><td><strong>速度对比</strong></td><td>运动速度响应分析</td><td>目标vs实际速度</td></tr>
<tr><td>3</td><td><strong>关节速度</strong></td><td>左右关节角速度</td><td>速度跟踪性能</td></tr>
<tr><td>4</td><td><strong>关节扭矩</strong></td><td>关节输出力矩分析</td><td>扭矩响应特性</td></tr>
<tr><td>5</td><td><strong>轮毂速度</strong></td><td>轮子旋转速度监测</td><td>轮速控制精度</td></tr>
<tr><td>6</td><td><strong>轮毂扭矩</strong></td><td>轮子输出扭矩分析</td><td>扭矩分配效果</td></tr>
<tr><td>7</td><td><strong>横滚角</strong></td><td>机器人横滚姿态</td><td>侧倾稳定性</td></tr>
<tr><td>8</td><td><strong>俯仰角</strong></td><td>机器人俯仰姿态</td><td>俯仰控制性能</td></tr>
<tr><td>9</td><td><strong>偏航角</strong></td><td>机器人偏航姿态</td><td>航向稳定性</td></tr>
<tr><td>10</td><td><strong>实际腿长</strong></td><td>左右腿长度变化</td><td>腿长控制精度</td></tr>
<tr><td>11</td><td><strong>轮毂功率</strong></td><td>左右轮功率消耗</td><td>能量效率分析</td></tr>
</table>

<h2>⚙️ 自定义配置</h2>

<h3>修改图表显示设置</h3>
<p>在<code>plot_configs</code>结构中调整子图位置和保存设置：</p>
<pre><code class="language-matlab">plot_configs(1).subplot_pos = [4,3,1]; % 主图位置
plot_configs(1).save_separate = false; % 是否单独保存</code></pre>

<h3>颜色方案定制</h3>
<p>修改全局颜色顺序以满足个性化需求：</p>
<pre><code class="language-matlab">global_color_order = [0 0.4470 0.7410;   % 深蓝色
                      0.3010 0.7450 0.9330; % 浅蓝色
                      0.8500 0.3250 0.0980; % 橙色
                      0.4940 0.1840 0.5560]; % 紫色</code></pre>

<h2>💾 输出选项</h2>

<h3>主图保存功能</h3>
<p>取消注释最后几行代码即可保存综合图表：</p>
<pre><code class="language-matlab">% combined_filename = [data_name, '_combined.png'];
% saveas(main_figure, combined_filename);</code></pre>

<h3>单独图表导出</h3>
<p>配置<code>save_separate = true</code>的图表会自动创建单独窗口，便于详细分析和导出。</p>

<h2>🔧 兼容性说明</h2>
<ul>
<li><strong>MATLAB版本：</strong> R2018b及以上</li>
<li><strong>数据兼容：</strong> 自动处理Yaw角数据兼容性</li>
<li><strong>列名适配：</strong> 灵活的数据列名匹配</li>
</ul>

<h2>🌟 技术特点</h2>
<ul>
<li><strong>模块化设计</strong> - <code>draw_plot</code>函数统一处理所有图表绘制</li>
<li><strong>自动化标注</strong> - 极值点自动识别和标注</li>
<li><strong>专业可视化</strong> - 学术论文级别的图表质量</li>
<li><strong>易于扩展</strong> - 可轻松添加新的分析图表</li>
</ul>

<div class="note">
<strong>💡 应用场景：</strong> 机器人研究、运动控制算法验证、性能分析、学术论文数据可视化
</div>

</body>
</html>
