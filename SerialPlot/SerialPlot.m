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
    data = [];
    timestamps = [];
    sample_interval = 1;  % 샘플링 간격 (초)
    xScale = 1000; % 초기 X 축 스케일 값
    maxDataLength = 15000; % 최대 데이터 길이
    Fs = 50; % 샘플링 속도

    % 플롯 초기화
    fig = figure('Position', [100, 100, 1200, 800]); % Figure 크기 조정
    ax = subplot('Position', [0.05, 0.3, 0.65, 0.65]); % 그래프를 왼쪽에 크게 배치
    plotHandle = plot(NaN, NaN);
    xlabel('Sample');
    ylabel('Value');
    title('Real-time Serial Data Plot');
    grid on;

    % 실시간 출력값 표시 창 추가
    outputPanel = uipanel('Title', 'Output', 'Position', [0.75, 0.5, 0.2, 0.45], 'Units', 'normalized'); % 오른쪽에 세로 직사각형 창 추가
    outputBox = uicontrol('Parent', outputPanel, 'Style', 'listbox', 'Position', [10, 10, 290, 390], 'Units', 'normalized'); % 여백 포함

    % 통계 및 주파수 특징 표시 창 추가
    featurePanel = uipanel('Title', 'Features', 'Position', [0.75, 0.05, 0.2, 0.4], 'Units', 'normalized'); % 오른쪽 아래쪽 창 추가
    featureBox = uicontrol('Parent', featurePanel, 'Style', 'text', 'Position', [1, -110, 270, 350], 'Units', 'normalized', 'HorizontalAlignment', 'left'); % 여백 포함

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

    % 타이머 객체 생성
    t = timer('ExecutionMode', 'fixedRate', 'Period', 1, ... % 1초 주기로 변경
              'TimerFcn', @(~, ~) updatePlot());

    % 버퍼 초기화
    buffer_data = [];
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
            value = str2double(readline(ser));
            if ~isnan(value)
                timestamp = datetime('now');
                buffer_data = [buffer_data; value];
                buffer_timestamps = [buffer_timestamps; timestamp];
            end
        end
    end

    function updatePlot()
        % 이 함수는 타이머에 의해 주기적으로 호출되어 그래프를 업데이트합니다.
        if ~isempty(buffer_data)
            % 그래프 업데이트
            data = [data; buffer_data];
            timestamps = [timestamps; buffer_timestamps];
            buffer_data = [];
            buffer_timestamps = [];

            % 데이터가 최대 길이를 초과하면 초과된 부분을 제거
            if length(data) > maxDataLength
                data = data(end-maxDataLength+1:end);
                timestamps = timestamps(end-maxDataLength+1:end);
            end

            set(plotHandle, 'XData', 1:length(data), 'YData', data);
            if length(data) > xScale
                xlim([length(data)-xScale+1, length(data)]);
            else
                xlim([1, xScale]);
            end
            drawnow;

            % 출력값을 실시간으로 텍스트 상자에 추가
            currentOutput = get(outputBox, 'String');
            if ischar(currentOutput)
                currentOutput = {currentOutput};
            end
            for i = 1:length(buffer_timestamps)
                currentOutput = [currentOutput; {sprintf('%s: %f', buffer_timestamps(i), buffer_data(i))}];
            end
            set(outputBox, 'String', currentOutput);
            set(outputBox, 'Value', length(currentOutput)); % 자동 스크롤

            % 특징 계산 및 표시
            calculateAndDisplayFeatures(data);
        end
    end

    function calculateAndDisplayFeatures(data)
        % 통계적 특징 계산
        meanValue = mean(data);
        stdValue = std(data);
        minValue = min(data);
        maxValue = max(data);

        % 주파수 도메인 특징 계산
        L = length(data);
        Y = fft(data);
        P2 = abs(Y/L);
        P1 = P2(1:L/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        f = Fs*(0:(L/2))/L;

        % 스트레스 관련 주파수 특징 계산 (예: 저주파, 고주파 비율)
        lowFreqPower = bandpower(data, Fs, [0.04 0.15]);
        highFreqPower = bandpower(data, Fs, [0.15 0.4]);
        lfHfRatio = lowFreqPower / highFreqPower;

        % 특징 표시
        featureText = sprintf('Mean: %.4f\nSTD: %.4f\nMin: %.4f\nMax: %.4f\nLF/HF Ratio: %.4f', ...
                              meanValue, stdValue, minValue, maxValue, lfHfRatio);
        set(featureBox, 'String', featureText);
    end
    function saveData()
        [file, path] = uiputfile('*.txt', 'Save Data As');
        if isequal(file, 0) || isequal(path, 0)
            disp('User canceled save operation.');
        else
            fullPath = fullfile(path, file);
            T = table(timestamps, data);
            writetable(T, fullPath);
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
        % X 축 스케일 적용 함수
        newXScale = str2double(get(xScaleBox, 'String'));
        if isnan(newXScale) || newXScale <= 0
            disp('Invalid X-axis scale.');
        else
            xScale = newXScale;
            if length(data) > xScale
                xlim([length(data)-xScale+1, length(data)]);
            else
                xlim([1, xScale]);
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
end

   