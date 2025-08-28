function SerialPlot()
    % 시리얼 포트 선택 GUI
    ports = serialportlist("available");
    [port, ok] = listdlg('PromptString', 'Select a serial port:', ...
                         'SelectionMode', 'single', ...
                         'ListString', ports);
    if ~ok
        disp('No port selected. Exiting...');
        return;
    end

    baudrates = {'9600', '14400', '19200', '38400', '57600', '115200'};
    [baudrate, ok] = listdlg('PromptString', 'Select a baud rate:', ...
                             'SelectionMode', 'single', ...
                             'ListString', baudrates);
    if ~ok
        disp('No baud rate selected. Exiting...');
        return;
    end

    % 시리얼 포트 연결
    port_name = ports{port};
    baud_rate = str2double(baudrates{baudrate});
    ser = serialport(port_name, baud_rate);

    % 데이터 저장용 변수 초기화
    data1 = [];
    data2 = [];
    timestamps = [];
    sample_interval = 1;  % 샘플링 간격 (초)
    xScale = 6000; % 초기 X 축 스케일 값
    maxDataLength = 9000; % 최대 데이터 길이
    Fs = 50; % 샘플링 속도

    % 플롯 초기화 및 리사이징 설정
    fig = figure('Position', [50, 150, 1200, 800], 'Name', 'Serial Data Plot', 'NumberTitle', 'off');
    set(fig, 'ResizeFcn', @resizeUI);
    ax1 = subplot(3, 1, 1);
    plotHandle1 = plot(ax1, NaN, NaN, 'r');
    title(ax1, 'Real-time Data Plot 1');
    ylabel('Value');
    
    ax2 = subplot(3, 1, 2);
    plotHandle2 = plot(ax2, NaN, NaN, 'b');
    title(ax2, 'Real-time Data Plot 2');
    ylabel('Value');
    
    ax3 = subplot(3, 1, 3);
    plotHandle3_1 = plot(ax3, NaN, NaN, 'r');
    hold on;
    plotHandle3_2 = plot(ax3, NaN, NaN, 'b');
    hold off;
    title(ax3, 'Combined Data Plot');
    xlabel('Sample');
    ylabel('Value');
    grid on;

    % 실시간 출력값 표시 창 및 특징 표시 창 초기화
    % outputPanel = uipanel('Title', 'Output', 'Position', [90.8, 0.5, 0.18, 0.45], 'Units', 'normalized');
    % outputBox = uicontrol('Parent', outputPanel, 'Style', 'listbox', 'Position', [0.95, 0.05, 0.9, 0.9], 'Units', 'normalized');
    % featurePanel = uipanel('Title', 'Features', 'Position', [90.8, 0.05, 0.18, 0.4], 'Units', 'normalized');
    % featureBox = uicontrol('Parent', featurePanel, 'Style', 'text', 'Position', [0.95, 0.05, 0.9, 0.9], 'Units', 'normalized', 'HorizontalAlignment', 'left');

    % UI 컨트롤 추가
    uicontrol('Style', 'pushbutton', 'String', 'Start', ...
              'Position', [50, 20, 60, 30], 'Units', 'pixels', ...
              'Callback', @(src, event) startPlotting());
    uicontrol('Style', 'pushbutton', 'String', 'Stop', ...
              'Position', [120, 20, 60, 30], 'Units', 'pixels', ...
              'Callback', @(src, event) stopPlotting());
    uicontrol('Style', 'pushbutton', 'String', 'Save', ...
              'Position', [190, 20, 60, 30], 'Units', 'pixels', ...
              'Callback', @(src, event) saveData());
    sampleBox = uicontrol('Style', 'edit', 'String', '1', ...
                          'Position', [260, 20, 60, 30], 'Units', 'pixels', ...
                          'Callback', @(src, event) setSampleInterval());

    % X 축 스케일 입력란과 적용 버튼 추가
    uicontrol('Style', 'text', 'String', 'X-axis Scale:', ...
              'Position', [330, 20, 80, 30], 'Units', 'pixels');
    xScaleBox = uicontrol('Style', 'edit', 'String', '1000', ...
                          'Position', [420, 20, 60, 30], 'Units', 'pixels');
    uicontrol('Style', 'pushbutton', 'String', 'Apply', ...
              'Position', [490, 20, 60, 30], 'Units', 'pixels', ...
              'Callback', @(src, event) applyXScale());

    % 타이머 객체 생성 및 설정
    t = timer('ExecutionMode', 'fixedRate', 'Period', 2, ...
              'TimerFcn', @(~, ~) updatePlot());

    % 버퍼 초기화
    buffer_data1 = [];
    buffer_data2 = [];
    buffer_timestamps = [];

    % 플로팅 중지 플래그
    isRunning = false;

    function startPlotting()
        isRunning = true;
        configureCallback(ser, "terminator", @readSerialData);
        start(t);
    end

    function stopPlotting()
        isRunning = false;
        configureCallback(ser, "off");
        stop(t);
    end

    function readSerialData(~, ~)
        if ser.NumBytesAvailable > 0
            line = readline(ser);
            values = str2double(strsplit(line, ','));
            if length(values) == 2
                timestamp = datetime('now');
                buffer_data1 = [buffer_data1; values(1)];
                buffer_data2 = [buffer_data2; values(2)];
                buffer_timestamps = [buffer_timestamps; timestamp];
            end
        end
    end

    function updatePlot()
        if ~isempty(buffer_data1)
            % 데이터 갱신
            data1 = [data1; buffer_data1];
            data2 = [data2; buffer_data2];
            timestamps = [timestamps; buffer_timestamps];
            buffer_data1 = [];
            buffer_data2 = [];
            buffer_timestamps = [];

            % 시간 기반 데이터 관리 (최근 5분간의 데이터만 유지)
            if ~isempty(timestamps)
                timeThreshold = datetime('now') - minutes(5);
                validIndices = timestamps >= timeThreshold;
                data1 = data1(validIndices);
                data2 = data2(validIndices);
                timestamps = timestamps(validIndices);
            end

            % 그래프 업데이트
            set(plotHandle1, 'XData', 1:length(data1), 'YData', data1);
            set(plotHandle2, 'XData', 1:length(data2), 'YData', data2);
            set(plotHandle3_1, 'XData', 1:length(data1), 'YData', data1);
            set(plotHandle3_2, 'XData', 1:length(data2), 'YData', data2);

            % X축 조정
            currentLength = length(data1);
            xlim(ax1, [max(1, currentLength - xScale) currentLength]);
            xlim(ax2, [max(1, currentLength - xScale) currentLength]);
            xlim(ax3, [max(1, currentLength - xScale) currentLength]);
            drawnow;

            % % 출력값을 실시간으로 텍스트 상자에 추가
            % currentOutput = get(outputBox, 'String');
            % if ischar(currentOutput)
            %     currentOutput = {currentOutput};
            % end
            % for i = 1:length(buffer_timestamps)
            %     currentOutput = [currentOutput; {sprintf('%s: %f, %f', buffer_timestamps(i), buffer_data1(i), buffer_data2(i))}];
            % end
            % set(outputBox, 'String', currentOutput);
            % set(outputBox, 'Value', length(currentOutput)); % 자동 스크롤

            % % 특징 계산 및 표시
            % calculateAndDisplayFeatures(data1, data2);
        end
    end

    % function calculateAndDisplayFeatures(data1, data2)
    %     % 통계적 특징과 주파수 도메인 특징 계산
    %     calculateStatistics(data1, data2);
    %     calculateFrequencyFeatures(data1, data2);
    % end
    % 
    % function calculateStatistics(data1, data2)
    %     meanValue1 = mean(data1);
    %     stdValue1 = std(data1);
    %     minValue1 = min(data1);
    %     maxValue1 = max(data1);
    % 
    %     meanValue2 = mean(data2);
    %     stdValue2 = std(data2);
    %     minValue2 = min(data2);
    %     maxValue2 = max(data2);
    % 
    %     featureText = sprintf('Data1 - Mean: %.4f, STD: %.4f, Min: %.4f, Max: %.4f\nData2 - Mean: %.4f, STD: %.4f, Min: %.4f, Max: %.4f', ...
    %         meanValue1, stdValue1, minValue1, maxValue1, meanValue2, stdValue2, minValue2, maxValue2);
    %     set(featureBox, 'String', featureText);
    % end

    % function calculateFrequencyFeatures(data1, data2)
    %     L = length(data1);
    %     Y1 = fft(data1);
    %     P2_1 = abs(Y1/L);
    %     P1_1 = P2_1(1:L/2+1);
    %     P1_1(2:end-1) = 2*P1_1(2:end-1);
    % 
    %     Y2 = fft(data2);
    %     P2_2 = abs(Y2/L);
    %     P1_2 = P2_2(1:L/2+1);
    %     P1_2(2:end-1) = 2*P1_2(2:end-1);
    % 
    %     f = Fs*(0:(L/2))/L;
    % 
    %     lowFreqPower1 = bandpower(data1, Fs, [0.04 0.15]);
    %     highFreqPower1 = bandpower(data1, Fs, [0.15 0.4]);
    %     lfHfRatio1 = lowFreqPower1 / highFreqPower1;
    % 
    %     lowFreqPower2 = bandpower(data2, Fs, [0.04 0.15]);
    %     highFreqPower2 = bandpower(data2, Fs, [0.15 0.4]);
    %     lfHfRatio2 = lowFreqPower2 / highFreqPower2;
    % 
    %     featureText = sprintf('LF/HF Ratio: Data1 - %.4f, Data2 - %.4f', lfHfRatio1, lfHfRatio2);
    %     set(featureBox, 'String', featureText);
    % end
    
    function saveData()
        [file, path] = uiputfile('*.txt', 'Save Data As');
        if isequal(file, 0) || isequal(path, 0)
            disp('User canceled save operation.');
        else
            fullPath = fullfile(path, file);
            T1 = table(timestamps, data1);
            T2 = table(timestamps, data2);
            writetable(T1, [fullPath, '_data1.txt']);
            writetable(T2, [fullPath, '_data2.txt']);
            disp(['Data saved to ', fullPath]);
        end
    end
    
    function setSampleInterval()
        newInterval = str2double(get(sampleBox, 'String'));
        if isnan(newInterval) || newInterval <= 0
            disp('Invalid sample interval.');
        else
            sample_interval = newInterval;
            disp(['Sample interval set to ', num2str(sample_interval), ' seconds.']);
        end
    end
    
    function applyXScale()
        newXScale = str2double(get(xScaleBox, 'String'));
        if isnan(newXScale) || newXScale <= 0
            disp('Invalid X-axis scale.');
        else
            xScale = newXScale;
            if length(data1) > xScale
                xlim(ax1, [length(data1)-xScale+1, length(data1)]);
                xlim(ax2, [length(data1)-xScale+1, length(data1)]);
                xlim(ax3, [length(data1)-xScale+1, length(data1)]);
            else
                xlim(ax1, [1, xScale]);
                xlim(ax2, [1, xScale]);
                xlim(ax3, [1, xScale]);
            end
            disp(['X-axis scale set to ', num2str(xScale)]);
        end
    end
    
    % Figure 닫힐 때 타이머 정지 및 삭제
    fig.CloseRequestFcn = @(src, event) closeFig();
    
    function closeFig()
        stop(t);
        delete(t);
        delete(fig);
    end
    
    function resizeUI(~, ~)
        % Adjust the positions of UI elements dynamically based on the figure size
        figPos = get(fig, 'Position');
        set(outputPanel, 'Position', [0.8, 0.5, 0.18, 0.45] .* [1, 1, figPos(3)/1200, figPos(4)/800]);
        set(featurePanel, 'Position', [0.8, 0.05, 0.18, 0.4] .* [1, 1, figPos(3)/1200, figPos(4)/800]);
        set(ax1, 'Position', [0.05, 0.68, 0.7, 0.28] .* [1, 1, figPos(3)/1200, figPos(4)/800]);
        set(ax2, 'Position', [0.05, 0.38, 0.7, 0.28] .* [1, 1, figPos(3)/1200, figPos(4)/800]);
        set(ax3, 'Position', [0.05, 0.08, 0.7, 0.28] .* [1, 1, figPos(3)/1200, figPos(4)/800]);
    end
end
