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
    dataTop = [];
    dataBottom = [];
    timestamps = [];

    % 플롯 초기화
    fig = figure('Position', [100, 100, 1200, 600]);
    axTop = subplot(2, 1, 1);
    plotHandleTop = plot(axTop, NaN, NaN, 'b');
    title(axTop, 'Top Graph - Val1');
    xlabel(axTop, 'Sample');
    ylabel(axTop, 'Value');
    grid(axTop, 'on');

    axBottom = subplot(2, 1, 2);
    plotHandleBottom = plot(axBottom, NaN, NaN, 'r');
    title(axBottom, 'Bottom Graph - Val2');
    xlabel(axBottom, 'Sample');
    ylabel(axBottom, 'Value');
    grid(axBottom, 'on');


    % 타이머 객체 생성
    t = timer('ExecutionMode', 'fixedRate', 'Period', 1, ...
              'TimerFcn', @(~, ~) updatePlot());

    function startPlotting()
        configureCallback(ser, "terminator", @readSerialData);
        start(t);
    end

    function stopPlotting()
        configureCallback(ser, "off");
        stop(t);
    end

    function readSerialData(~, ~)
        while ser.NumBytesAvailable > 0
            line = readline(ser);
            splitData = strsplit(line, ',');
            if numel(splitData) >= 2
                valueTop = str2double(splitData{1});
                valueBottom = str2double(splitData{2});
                dataTop = [dataTop valueTop];
                dataBottom = [dataBottom valueBottom];
                appendData(valueTop, valueBottom);
            end
        end
    end

    function appendData(valueTop, valueBottom)
        dataTop = [dataTop valueTop];
        dataBottom = [dataBottom valueBottom];
        if length(dataTop) > 1000
            dataTop = dataTop(2:end);
            dataBottom = dataBottom(2:end);
        end
    end

    function updatePlot()
        set(plotHandleTop, 'YData', dataTop, 'XData', 1:length(dataTop));
        set(plotHandleBottom, 'YData', dataBottom, 'XData', 1:length(dataBottom));
        drawnow;
    end

    function closeFig()
        stop(t);
        delete(t);
        delete(fig);
    end

    fig.CloseRequestFcn = @(src, event) closeFig();

    % UI 컨트롤 추가
    uicontrol('Style', 'pushbutton', 'String', 'Start', ...
              'Position', [100, 10, 60, 20], 'Callback', @(src, event) startPlotting());
    uicontrol('Style', 'pushbutton', 'String', 'Stop', ...
              'Position', [170, 10, 60, 20], 'Callback', @(src, event) stopPlotting());
    uicontrol('Style', 'pushbutton', 'String', 'Save', ...
              'Position', [240, 10, 60, 20], 'Callback', @(src, event) saveData());
    end
    
    function saveData()
    [file, path] = uiputfile('*.txt', 'Save Data As');
    if file
        fullPath = fullfile(path, file);
        T = table(timestamps, dataTop, dataBottom);
        writetable(T, fullPath);
        disp(['Data saved to ', fullPath]);
    else
        disp('User canceled save operation.');
    end
end