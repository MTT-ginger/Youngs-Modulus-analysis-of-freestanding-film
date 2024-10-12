function varargout = ML_bing(varargin)
% ML_BING MATLAB code for ML_bing.fig
%      ML_BING, by itself, creates a new ML_BING or raises the existing
%      singleton*.
%
%      H = ML_BING returns the handle to a new ML_BING or the handle to
%      the existing singleton*.
%
%      ML_BING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ML_BING.M with the given input arguments.
%
%      ML_BING('Property','Value',...) creates a new ML_BING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ML_bing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ML_bing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ML_bing

% Last Modified by GUIDE v2.5 25-Sep-2024 18:14:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ML_bing_OpeningFcn, ...
    'gui_OutputFcn',  @ML_bing_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ML_bing is made visible.
function ML_bing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ML_bing (see VARARGIN)

% Choose default command line output for ML_bing
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ML_bing wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ML_bing_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadDataButton.
function loadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uigetfile('*.xlsx', 'Select Input Excel File');
if isequal(file, 0)
    return;
end
inputFile = fullfile(path, file);
handles.input = xlsread(inputFile);

[file, path] = uigetfile('*.xlsx', 'Select Output Excel File');
if isequal(file, 0)
    return;
end
outputFile = fullfile(path, file);
handles.output = xlsread(outputFile);

% 设置训练集和测试集
N = size(handles.input, 1);
testNum = 68;
trainNum = N - testNum;

handles.input_train = handles.input(1:trainNum, :)';
handles.output_train = handles.output(1:trainNum, :)';
handles.input_test = handles.input(trainNum+1:end, :)';
handles.output_test = handles.output(trainNum+1:end, :)';

% 数据归一化
[handles.inputn, handles.inputps] = mapminmax(handles.input_train, -1, 1);
[handles.outputn, handles.outputps] = mapminmax(handles.output_train);
handles.inputn_test = mapminmax('apply', handles.input_test, handles.inputps);

% 初始化显示第1组实验数据
experimentData = handles.input_test(1:end, :);
axes(handles.dataAxes);
force=0:1e-8:6e-7;
plot(experimentData(:, 1),force(:),'o',  'LineWidth', 1.5);
ylim([0 6e-7]);
xlabel('位移(m)');
ylabel('力(N)');
title('第1组实验数据');

% 初始化显示3nm训练集
simuData = handles.input_train(1:end, :);
axes(handles.dataAxes2);
kt=ones(1,61)*210;
for i=1:41
    Ek(:,i)=kt+i-1;
end

X=rand(61,41,9);
X(:,:,1)=simuData(:,1:41);
X(:,:,2)=simuData(:,42:82);
X(:,:,3)=simuData(:,83:123);
X(:,:,4)=simuData(:,124:164);
X(:,:,5)=simuData(:,165:205);
X(:,:,6)=simuData(:,206:246);
X(:,:,7)=simuData(:,247:287);
X(:,:,8)=simuData(:,288:328);
X(:,:,9)=simuData(:,329:369);

for i=1:41
    forcee(:,i)=force(:);
end
Y=rand(61,41,9);
for i=1:9
    Y(:,:,i)=forcee;
end

Z=rand(61,41,9);
for i=1:9
    Z(:,:,i)=0.7+i*0.1;
end

E=rand(61,41,9);
for i=1:9
    E(:,:,i)=Ek;
end
x=reshape(X,[22509,1]);
y=reshape(Y,[22509,1]);
z=reshape(Z,[22509,1]);
E=reshape(E,[22509,1]);

scatter3(x, z, y, 100, E, 's', 'filled'); % 100表示点的大小，'filled'表示填充颜色
pbaspect([1 0.5 1])
xlim([0 0.6e-7]);
ylim([0.8 1.6]);
zlim([0 6e-7]);
colorbar; % 显示颜色条
shading flat;
caxis([210 250]);
xlabel('w(m)');
ylabel('T(N/m)');
zlabel('F(N)');
title('FEM-训练集：3nm');
view(15,30);

guidata(hObject, handles);


% --- Executes on button press in trainNetworkButton.
function trainNetworkButton_Callback(hObject, eventdata, handles)
% hObject    handle to trainNetworkButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputnum = size(handles.input, 2);
outputnum = size(handles.output, 2);
hiddennum_best = fix(sqrt(inputnum + outputnum)) + 9;
MSE = 1e+5;
transform_func = {'tansig', 'purelin'};
train_func = 'trainlm';

% 获取 Edit Field 的值
epochs = str2double(get(handles.epochsEditField, 'String'));
lr = str2double(get(handles.lrEditField, 'String'));
goal = str2double(get(handles.goalEditField, 'String'));

for hiddennum = hiddennum_best:hiddennum_best+1
    net = newff(handles.inputn, handles.outputn, hiddennum, transform_func, train_func);
    net.trainParam.epochs = epochs;
    net.trainParam.lr = lr;
    net.trainParam.goal = goal;
    net = train(net, handles.inputn, handles.outputn);
    an0 = sim(net, handles.inputn);
    mse0 = mse(handles.outputn, an0);
    
    if mse0 < MSE
        MSE = mse0;
        hiddennum_best = hiddennum;
    end
end
handles.net = newff(handles.inputn, handles.outputn, hiddennum_best, transform_func, train_func);
handles.net.trainParam.epochs = epochs;
handles.net.trainParam.lr = lr;
handles.net.trainParam.goal = goal;
handles.net = train(handles.net, handles.inputn, handles.outputn);
guidata(hObject, handles);



% --- Executes on button press in outputResultsButton.
function outputResultsButton_Callback(hObject, eventdata, handles)
% hObject    handle to outputResultsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
an = sim(handles.net, handles.inputn_test);
test_simu = mapminmax('reverse', an, handles.outputps);

error = test_simu(1, :) - handles.output_test(1, :);
    
    figure('Name', 'BP神经网络分析结果', 'NumberTitle', 'off', 'Position', [100, 100, 1600, 900]);
    subplot(231);
    plot(handles.output_test(1, :), 'bo-', 'LineWidth', 1.5);
    hold on;
    plot(test_simu(1, :), 'rs-', 'LineWidth', 1.5);
    legend('实际值', '预测值');
    xlabel('测试样本');
    ylabel('指标值');
    title(['杨氏模量(GPa)的预测值和实际值对比']);
    set(gca, 'FontSize', 12);
    subplot(234);
    plot(error, 'bo-', 'LineWidth', 1.5);
    xlabel('测试样本');
    ylabel('预测误差');
    title(['杨氏模量(GPa)的预测误差']);
    set(gca, 'FontSize', 12);
    error2 = test_simu(2, :) - handles.output_test(2, :);
    subplot(232);
    plot(handles.output_test(2, :), 'bo-', 'LineWidth', 1.5);
    hold on;
    plot(test_simu(2, :), 'rs-', 'LineWidth', 1.5);
    legend('实际值', '预测值');
    xlabel('测试样本');
    ylabel('指标值');
    title(['预拉伸(N/m)的预测值和实际值对比']);
    set(gca, 'FontSize', 12);
    subplot(235);
    plot(error2, 'bo-', 'LineWidth', 1.5);
    xlabel('测试样本');
    ylabel('预测误差');
    title(['预拉伸(N/m)的预测误差']);
    set(gca, 'FontSize', 12);
    error3 = test_simu(3, :) - handles.output_test(3, :);
    subplot(233);
    plot(handles.output_test(3, :), 'bo-', 'LineWidth', 1.5);
    hold on;
    plot(test_simu(3, :), 'rs-', 'LineWidth', 1.5);
    legend('实际值', '预测值');
    xlabel('测试样本');
    ylabel('指标值');
    title(['厚度(nm)的预测值和实际值对比']);
    set(gca, 'FontSize', 12);
    subplot(236);
    plot(error3, 'bo-', 'LineWidth', 1.5);
    xlabel('测试样本');
    ylabel('预测误差');
    title(['厚度(nm)的预测误差']);
    set(gca, 'FontSize', 12);



% --- Executes on slider movement.
function dataSlider_Callback(hObject, eventdata, handles)
% hObject    handle to dataSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% 获取滑块的值
n = round(get(hObject, 'Value'));

% 获取实验数据
experimentData = handles.input_test(1:end, :);
force=0:1e-8:6e-7;
% 绘制第n组实验数据
axes(handles.dataAxes);
plot(experimentData(:, n),force(:),'o', 'LineWidth', 1.5);
ylim([0 6e-7]);
xlabel('位移(m)');
ylabel('力(N)');
title(['第', num2str(n), '组实验数据']);


% --- Executes during object creation, after setting all properties.
function dataSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
% 获取用户选择的训练集
contents = cellstr(get(hObject, 'String'));
selectedTrainingSet = contents{get(hObject, 'Value')};

% 根据选择的训练集更新scatter3图像
switch selectedTrainingSet
    case '3nm'
        simuData = handles.input_train(:, 1:369);
        
        % 更新dataAxes2中的scatter3图像
        axes(handles.dataAxes2);
        kt = ones(1, 61) * 210;
        for i = 1:41
            Ek(:, i) = kt + i - 1;
        end
        
        X = rand(61, 41, 9);
        X(:, :, 1) = simuData(:, 1:41);
        X(:, :, 2) = simuData(:, 42:82);
        X(:, :, 3) = simuData(:, 83:123);
        X(:, :, 4) = simuData(:, 124:164);
        X(:, :, 5) = simuData(:, 165:205);
        X(:, :, 6) = simuData(:, 206:246);
        X(:, :, 7) = simuData(:, 247:287);
        X(:, :, 8) = simuData(:, 288:328);
        X(:, :, 9) = simuData(:, 329:369);
        
        force=0:1e-8:6e-7;
        for i = 1:41
            forcee(:, i) = force(:);
        end
        Y = rand(61, 41, 9);
        for i = 1:9
            Y(:, :, i) = forcee;
        end
        
        Z = rand(61, 41, 9);
        for i = 1:9
            Z(:, :, i) = 0.7 + i * 0.1;
        end
        
        E = rand(61, 41, 9);
        for i = 1:9
            E(:, :, i) = Ek;
        end
        x = reshape(X, [22509, 1]);
        y = reshape(Y, [22509, 1]);
        z = reshape(Z, [22509, 1]);
        E = reshape(E, [22509, 1]);
        
        scatter3(x, z, y, 100, E, 's', 'filled'); % 100表示点的大小，'filled'表示填充颜色
        pbaspect([1 0.5 1])
        xlim([0 0.6e-7]);
        ylim([0.8 1.6]);
        zlim([0 6e-7]);
        colorbar; % 显示颜色条
        shading flat;
        caxis([210 250]);
        xlabel('w(m)');
        ylabel('T(N/m)');
        zlabel('F(N)');
        title(['FEM-训练集: ', selectedTrainingSet]);
        view(15, 30);
        
    case '13nm'
        simuData = handles.input_train(:, 370:857); % 替换为13nm的数据
        % 更新dataAxes2中的scatter3图像
        axes(handles.dataAxes2);
        kt = ones(1, 61) * 40;
        for i = 1:61
            Ek(:, i) = kt + i - 1;
        end
        
        X = rand(61, 61, 8);
        X(:, :, 1) = simuData(:, 1:61);
        X(:, :, 2) = simuData(:, 62:122);
        X(:, :, 3) = simuData(:, 123:183);
        X(:, :, 4) = simuData(:, 184:244);
        X(:, :, 5) = simuData(:, 245:305);
        X(:, :, 6) = simuData(:, 306:366);
        X(:, :, 7) = simuData(:, 367:427);
        X(:, :, 8) = simuData(:, 428:488);
        
        force=0:1e-8:6e-7;
        for i = 1:61
            forcee(:, i) = force(:);
        end
        Y = rand(61, 61, 8);
        for i = 1:8
            Y(:, :, i) = forcee;
        end
        
        Z = rand(61, 61, 8);
        for i = 1:8
            Z(:, :, i) = i * 0.1;
        end
        
        E = rand(61, 61, 8);
        for i = 1:8
            E(:, :, i) = Ek;
        end
        x = reshape(X, [29768, 1]);
        y = reshape(Y, [29768, 1]);
        z = reshape(Z, [29768, 1]);
        E = reshape(E, [29768, 1]);
        
        scatter3(x, z, y, 100, E, 's', 'filled'); % 100表示点的大小，'filled'表示填充颜色
        pbaspect([1 0.5 1])
        xlim([0 1.0e-7]);
        ylim([0 0.8]);
        zlim([0 6e-7]);
        colorbar; % 显示颜色条
        shading flat;
        xlabel('w(m)');
        ylabel('T(N/m)');
        zlabel('F(N)');
        title(['FEM-训练集: ', selectedTrainingSet]);
        view(15, 30);
        
    case '16nm'
        simuData = handles.input_train(:, 858:1025); % 替换为16nm的数据
        % 更新dataAxes2中的scatter3图像
        axes(handles.dataAxes2);
        kt = ones(1, 61) * 40;
        for i = 1:21
            Ek(:, i) = kt + i - 1;
        end
        
        X = rand(61, 21, 8);
        X(:, :, 1) = simuData(:, 1:21);
        X(:, :, 2) = simuData(:, 22:42);
        X(:, :, 3) = simuData(:, 43:63);
        X(:, :, 4) = simuData(:, 64:84);
        X(:, :, 5) = simuData(:, 85:105);
        X(:, :, 6) = simuData(:, 106:126);
        X(:, :, 7) = simuData(:, 127:147);
        X(:, :, 8) = simuData(:, 148:168);
        
        force=0:1e-8:6e-7;
        for i = 1:21
            forcee(:, i) = force(:);
        end
        Y = rand(61, 21, 8);
        for i = 1:8
            Y(:, :, i) = forcee;
        end
        
        Z = rand(61, 21, 8);
        for i = 1:8
            Z(:, :, i) = i * 0.1;
        end
        
        E = rand(61, 21, 8);
        for i = 1:8
            E(:, :, i) = Ek;
        end
        x = reshape(X, [10248, 1]);
        y = reshape(Y, [10248, 1]);
        z = reshape(Z, [10248, 1]);
        E = reshape(E, [10248, 1]);
        
        scatter3(x, z, y, 100, E, 's', 'filled'); % 100表示点的大小，'filled'表示填充颜色
        pbaspect([1 0.5 1])
        xlim([0 1.5e-7]);
        ylim([0 0.8]);
        zlim([0 6e-7]);
        colorbar; % 显示颜色条
        shading flat;
        xlabel('w(m)');
        ylabel('T(N/m)');
        zlabel('F(N)');
        title(['FEM-训练集: ', selectedTrainingSet]);
        view(15, 30);
        
    case '33nm'
        simuData = handles.input_train(:, 1026:1304); % 替换为33nm的数据
        % 更新dataAxes2中的scatter3图像
        axes(handles.dataAxes2);
        kt = ones(1, 61) * 30;
        for i = 1:31
            Ek(:, i) = kt + i - 1;
        end
        
        X = rand(61, 31, 9);
        X(:, :, 1) = simuData(:, 1:31);
        X(:, :, 2) = simuData(:, 32:62);
        X(:, :, 3) = simuData(:, 63:93);
        X(:, :, 4) = simuData(:, 94:124);
        X(:, :, 5) = simuData(:, 125:155);
        X(:, :, 6) = simuData(:, 156:186);
        X(:, :, 7) = simuData(:, 187:217);
        X(:, :, 8) = simuData(:, 218:248);
        X(:, :, 9) = simuData(:, 249:279);
        
        force=0:1e-8:6e-7;
        for i = 1:31
            forcee(:, i) = force(:);
        end
        Y = rand(61, 31, 9);
        for i = 1:9
            Y(:, :, i) = forcee;
        end
        
        Z = rand(61, 31, 9);
        for i = 1:9
            Z(:, :, i) = 0.5+(i-1) * 0.1;
        end
        
        E = rand(61, 31, 9);
        for i = 1:9
            E(:, :, i) = Ek;
        end
        x = reshape(X, [17019, 1]);
        y = reshape(Y, [17019, 1]);
        z = reshape(Z, [17019, 1]);
        E = reshape(E, [17019, 1]);
        
        scatter3(x, z, y, 100, E, 's', 'filled'); % 100表示点的大小，'filled'表示填充颜色
        pbaspect([1 0.5 1])
        xlim([0 1.1e-7]);
        ylim([0.5 1.3]);
        zlim([0 6e-7]);
        colorbar; % 显示颜色条
        shading flat;
        xlabel('w(m)');
        ylabel('T(N/m)');
        zlabel('F(N)');
        title(['FEM-训练集: ', selectedTrainingSet]);
        view(15, 30);
        
    case '44nm'
        simuData = handles.input_train(:, 1305:1451); % 替换为44nm的数据
        % 更新dataAxes2中的scatter3图像
        axes(handles.dataAxes2);
        kt = ones(1, 61) * 40;
        for i = 1:21
            Ek(:, i) = kt + i - 1;
        end
        
        X = rand(61, 21, 7);
        X(:, :, 1) = simuData(:, 1:21);
        X(:, :, 2) = simuData(:, 22:42);
        X(:, :, 3) = simuData(:, 43:63);
        X(:, :, 4) = simuData(:, 64:84);
        X(:, :, 5) = simuData(:, 85:105);
        X(:, :, 6) = simuData(:, 106:126);
        X(:, :, 7) = simuData(:, 127:147);
        
        force=0:1e-8:6e-7;
        for i = 1:21
            forcee(:, i) = force(:);
        end
        Y = rand(61, 21, 7);
        for i = 1:7
            Y(:, :, i) = forcee;
        end
        
        Z = rand(61, 21, 7);
        for i = 1:7
            Z(:, :, i) = 1.2+(i-1) * 0.1;
        end
        
        E = rand(61, 21, 7);
        for i = 1:7
            E(:, :, i) = Ek;
        end
        x = reshape(X, [8967, 1]);
        y = reshape(Y, [8967, 1]);
        z = reshape(Z, [8967, 1]);
        E = reshape(E, [8967, 1]);
        
        scatter3(x, z, y, 100, E, 's', 'filled'); % 100表示点的大小，'filled'表示填充颜色
        pbaspect([1 0.5 1])
        xlim([0 0.7e-7]);
        ylim([1.2 1.8]);
        zlim([0 6e-7]);
        colorbar; % 显示颜色条
        shading flat;
        xlabel('w(m)');
        ylabel('T(N/m)');
        zlabel('F(N)');
        title(['FEM-训练集: ', selectedTrainingSet]);
        view(15, 30);
end



guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function epochsEditField_Callback(hObject, eventdata, handles)
% hObject    handle to epochsEditField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of epochsEditField as text
%        str2double(get(hObject,'String')) returns contents of epochsEditField as a double


% --- Executes during object creation, after setting all properties.
function epochsEditField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epochsEditField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lrEditField_Callback(hObject, eventdata, handles)
% hObject    handle to lrEditField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lrEditField as text
%        str2double(get(hObject,'String')) returns contents of lrEditField as a double


% --- Executes during object creation, after setting all properties.
function lrEditField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lrEditField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function goalEditField_Callback(hObject, eventdata, handles)
% hObject    handle to goalEditField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of goalEditField as text
%        str2double(get(hObject,'String')) returns contents of goalEditField as a double


% --- Executes during object creation, after setting all properties.
function goalEditField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to goalEditField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
% 获取用户选择的训练集
contents = cellstr(get(hObject, 'String'));
selectedTrainingSet2 = contents{get(hObject, 'Value')};

% 根据选择的训练集更新scatter3图像
switch selectedTrainingSet2
    case '3nm'
        simuData = handles.input_train(:, 1:369);
        
        kt = ones(1, 61) * 210;
        for i = 1:41
            E(:, i) = kt + i - 1;
        end
        
        W1(:, :) = simuData(:, 1:41);
        W2(:, :) = simuData(:, 42:82);
        W3(:, :) = simuData(:, 83:123);
        W4(:, :) = simuData(:, 124:164);
        W5(:, :) = simuData(:, 165:205);
        W6(:, :) = simuData(:, 206:246);
        W7(:, :) = simuData(:, 247:287);
        W8(:, :) = simuData(:, 288:328);
        W9(:, :) = simuData(:, 329:369);
        
        force=0:1e-8:6e-7;
        for i = 1:41
            force0(:, i) = force(:);
        end
        
        figure('Name', '3nm-薄膜力-位移曲线机器学习分类结果', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 800]);
        colormap(parula);
        subplot(331);pcolor(W1,force0,E);
        title('T=0.8 N/m');
        xlim([0 0.6e-7]);
        caxis([180 250]);
        colorbar;
        shading flat;
        hold on;
        f=plot(W1(:,24),force0(:,1),  'k--', 'LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(332);pcolor(W3,force0,E);
        shading flat;
        xlim([0 0.6e-7]);
        caxis([180 250]);
        colorbar;
        hold on;
        f=plot(W3(:,2),force0(:,1),  'k--', 'LineWidth', 1);
        hold off;
        uistack(f);
        title('T=1.0 N/m');
        
        subplot(333);pcolor(W5,force0,E);title('T=1.2 N/m');
        xlim([0 0.6e-7]);
        caxis([180 250]);
        shading flat;
        colorbar;
        hold on;
        f=plot(W5(:,31),force0(:,1), 'k--',W5(:,41),force0(:,1), 'k--', 'LineWidth', 1);
        hold off;
        uistack(f);
        
        
        subplot(334);pcolor(W6,force0,E);title('T=1.3 N/m');
        xlim([0 0.6e-7]);
        caxis([180 250]);
        shading flat;
        colorbar;
        hold on;
        f=plot(W6(:,6),force0(:,1), 'k--', 'LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(335);pcolor(W7,force0,E);title('T=1.4 N/m');
        xlim([0 0.6e-7]);
        caxis([180 250]);
        shading flat;
        colorbar;
        hold on;
        f=plot(W7(:,15),force0(:,1), 'k--', 'LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(336);pcolor(W8,force0,E);title('T=1.5 N/m');
        xlim([0 0.6e-7]);
        caxis([180 250]);
        shading flat;
        colorbar;
        hold on;
        f=plot(W8(:,24),force0(:,1), 'k--',W8(:,32),force0(:,1), 'k--', 'LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(337);pcolor(W9,force0,E);title('T=1.6 N/m');
        xlim([0 0.6e-7]);
        caxis([180 250]);
        shading flat;
        colorbar;
        hold on;
        f=plot(W9(:,21),force0(:,1), 'k--', 'LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(338);
        f1=plot(W1(:,24),force0(:,1),  'k--',...
            W3(:,2),force0(:,1),  'k--',...
            W5(:,31),force0(:,1), 'k--',W5(:,41),force0(:,1), 'k--',...
            W6(:,6),force0(:,1), 'k--',...
            W7(:,15),force0(:,1), 'k--',...
            W8(:,21),force0(:,1), 'k--',...
            W9(:,24),force0(:,1), 'k--',W9(:,32),force0(:,1), 'k--','LineWidth', 1);
        title('Experiment data');
        xlim([0 1.5e-7]);
        ylim([0 6e-7]);
        
    case '13nm'
        simuData = handles.input_train(:, 370:857); % 替换为13nm的数据
        
        kt = ones(1, 61) * 40;
        for i = 1:61
            E(:, i) = kt + i - 1;
        end
        
        W1(:, :) = simuData(:, 1:61);
        W2(:, :) = simuData(:, 62:122);
        W3(:, :) = simuData(:, 123:183);
        W4(:, :) = simuData(:, 184:244);
        W5(:, :) = simuData(:, 245:305);
        W6(:, :) = simuData(:, 306:366);
        W7(:, :) = simuData(:, 367:427);
        W8(:, :) = simuData(:, 428:488);
        
        force=0:1e-8:6e-7;
        for i = 1:61
            force0(:, i) = force(:);
        end
        
        
        figure('Name', '13nm-薄膜力-位移曲线机器学习分类结果', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 800]);
        colormap(parula);
        subplot(331);pcolor(W1,force0,E);
        title('T=0.1 N/m');
        xlim([0 1.0e-7]);
        caxis([40 100]);
        shading flat;
        colorbar;
        hold on;
        f=plot(W1(:,13),force0(:,1),  'w--', 'LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(332);pcolor(W2,force0,E);
        title('T=0.2 N/m');
        xlim([0 1.0e-7]);
        caxis([40 100]);
        shading flat;
        colorbar;
        hold on;
        f=plot(W2(:,32),force0(:,1),  'w--', 'LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(333);pcolor(W3,force0,E);
        title('T=0.3 N/m');
        xlim([0 1.0e-7]);
        caxis([40 100]);
        shading flat;
        colorbar;
        hold on;
        f=plot(W3(:,10),force0(:,1),  'w--', 'LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(334);pcolor(W4,force0,E);
        title('T=0.4 N/m');
        xlim([0 1.0e-7]);
        caxis([40 100]);
        shading flat;
        colorbar;
        hold on;
        f=plot(W4(:,25),force0(:,1),  'w--',W4(:,23),force0(:,1),  'w--', 'LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(335);pcolor(W5,force0,E);
        title('T=0.5 N/m');
        xlim([0 1.0e-7]);
        caxis([40 100]);
        shading flat;
        colorbar;
        hold on;
        f=plot(W5(:,26),force0(:,1),  'w--',W5(:,36),force0(:,1),  'w--', 'LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(336);pcolor(W6,force0,E);
        title('T=0.6 N/m');
        xlim([0 1.0e-7]);
        caxis([40 100]);
        shading flat;
        colorbar;
        hold on;
        f=plot(W6(:,37),force0(:,1),  'w--',W6(:,35),force0(:,1),  'w--',W6(:,40),force0(:,1),  'w--', 'LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(337);pcolor(W7,force0,E);
        title('T=0.7 N/m');
        xlim([0 1.0e-7]);
        caxis([40 100]);
        shading flat;
        colorbar;
        hold on;
        f=plot(W7(:,43),force0(:,1),  'k--',W7(:,7),force0(:,1),  'w--',...
            W7(:,26),force0(:,1), 'w--',W7(:,54),force0(:,1), 'k--',...
            W7(:,31),force0(:,1), 'w--',W7(:,28),force0(:,1),  'w--','LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(338);pcolor(W8,force0,E);
        title('T=0.8 N/m');
        xlim([0 1.0e-7]);
        caxis([40 100]);
        shading flat;
        colorbar;
        hold on;
        f=plot(W8(:,11),force0(:,1),  'w--',W8(:,50),force0(:,1),  'k--', 'LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(339);
        f1=plot(W8(:,11),force0(:,1),  '--',W8(:,50),force0(:,1),  '--',...
            W7(:,43),force0(:,1),  '--',W7(:,7),force0(:,1),  '--',...
            W7(:,26),force0(:,1), '--',W7(:,54),force0(:,1), '--',...
            W7(:,31),force0(:,1), '--',W7(:,28),force0(:,1),  '--',...
            W6(:,37),force0(:,1),  '--',W6(:,35),force0(:,1),  '--',W6(:,40),force0(:,1), '--',...
            W5(:,26),force0(:,1),  '--',W5(:,36),force0(:,1), '--',...
            W4(:,25),force0(:,1),  '--',W4(:,23),force0(:,1), '--',...
            W3(:,10),force0(:,1), '--',...
            W2(:,32),force0(:,1), '--',W1(:,13),force0(:,1), '--','LineWidth', 1);
        title('Experiment data');
        xlim([0 1.5e-7]);
        ylim([0 6e-7]);
        
    case '16nm'
        simuData = handles.input_train(:, 858:1025); % 替换为16nm的数据
        
        kt = ones(1, 61) * 40;
        for i = 1:21
            E(:, i) = kt + i - 1;
        end
        
        Q1(:, :) = simuData(:, 1:21);
        Q2(:, :) = simuData(:, 22:42);
        Q3(:, :) = simuData(:, 43:63);
        Q4(:, :) = simuData(:, 64:84);
        Q5(:, :) = simuData(:, 85:105);
        Q6(:, :) = simuData(:, 106:126);
        Q7(:, :) = simuData(:, 127:147);
        Q8(:, :) = simuData(:, 148:168);
        
        
        force=0:1e-8:6e-7;
        for i = 1:21
            force0(:, i) = force(:);
        end
        
        
        figure('Name', '16nm-薄膜力-位移曲线机器学习分类结果', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 800]);
        colormap(parula);
        subplot(331);pcolor(Q4,force0,E);
        title('T=0.4 N/m');
        xlim([0 1.5e-7]);
        caxis([40 60]);
        shading flat;
        colorbar;
        hold on;
        f=plot(Q4(:,1),force0(:,1),  'w--',Q4(:,2),force0(:,1),  'w--',Q4(:,3),force0(:,1),  'w--', 'LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(332);pcolor(Q5,force0,E);
        title('T=0.5 N/m');
        xlim([0 1.5e-7]);
        caxis([40 60]);
        shading flat;
        colorbar;
        hold on;
        f=plot(Q5(:,3),force0(:,1),  'w--',Q5(:,11),force0(:,1),  'w--',...
            Q5(:,4),force0(:,1),  'w--',Q5(:,5),force0(:,1),  'w--','LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(333);pcolor(Q6,force0,E);
        title('T=0.6 N/m');
        xlim([0 1.5e-7]);
        caxis([40 60]);
        shading flat;
        colorbar;
        hold on;
        f=plot(Q6(:,6),force0(:,1),  'w--',Q6(:,12),force0(:,1),  'w--',Q6(:,14),force0(:,1),  'w--', 'LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(334);pcolor(Q7,force0,E);
        title('T=0.7 N/m');
        xlim([0 1.5e-7]);
        caxis([40 60]);
        shading flat;
        colorbar;
        hold on;
        f=plot(Q7(:,8),force0(:,1),  'w--',Q7(:,12),force0(:,1), 'w--','LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(335);pcolor(Q8,force0,E);
        title('T=0.8 N/m');
        xlim([0 1.5e-7]);
        caxis([40 60]);
        shading flat;
        colorbar;
        hold on;
        f=plot(Q8(:,9),force0(:,1),  'w--', 'LineWidth', 1);
        hold off;
        uistack(f);
        
        subplot(336);
        f1=plot(Q8(:,9),force0(:,1),  '--',...
            Q7(:,8),force0(:,1),  '--',Q7(:,12),force0(:,1),  '--',...
            Q6(:,6),force0(:,1),  '--',Q6(:,12),force0(:,1),  '--',Q6(:,14),force0(:,1), '--',...
            Q5(:,3),force0(:,1),  '--',Q5(:,11),force0(:,1),  '--',...
            Q5(:,4),force0(:,1),  '--',Q5(:,5),force0(:,1), '--',...
            Q4(:,1),force0(:,1),  '--',Q4(:,2),force0(:,1),  '--',Q4(:,3),force0(:,1), '--','LineWidth', 1);
        title('Experiment data');
        xlim([0 1.5e-7]);
        ylim([0 6e-7]);
        
    case '33nm'
                simuData = handles.input_train(:, 1026:1304); % 替换为33nm的数据
        kt = ones(1, 61) * 30;
        for i = 1:31
            E(:, i) = kt + i - 1;
        end

        R1(:, :) = simuData(:, 1:31);
        R2(:, :) = simuData(:, 32:62);
        R3(:, :) = simuData(:, 63:93);
        R4(:, :) = simuData(:, 94:124);
        R5(:, :) = simuData(:, 125:155);
        R6(:, :) = simuData(:, 156:186);
        R7(:, :) = simuData(:, 187:217);
        R8(:, :) = simuData(:, 218:248);
        R9(:, :) = simuData(:, 249:279);
        
        force=0:1e-8:6e-7;
        for i = 1:31
            force0(:, i) = force(:);
        end
        
        figure('Name', '33nm-薄膜力-位移曲线机器学习分类结果', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 800]);
        colormap(parula);
        subplot(331);pcolor(R1,force0,E);
title('T=0.5 N/m');
xlim([0 1.1e-7]);
caxis([30 60]);
shading flat;
colorbar;
hold on;
f=plot(R1(:,18),force0(:,1),  'w--', 'LineWidth', 1);
hold off;
uistack(f);

subplot(332);pcolor(R2,force0,E);
title('T=0.6 N/m');
xlim([0 1.1e-7]);
caxis([30 60]);
shading flat;
colorbar;
hold on;
f=plot(R2(:,17),force0(:,1),  'w--', 'LineWidth', 1);
hold off;
uistack(f);

subplot(333);pcolor(R4,force0,E);
title('T=0.8 N/m');
xlim([0 1.1e-7]);
caxis([30 60]);
shading flat;
colorbar;
hold on;
f=plot(R4(:,10),force0(:,1),  'w--',R4(:,13),force0(:,1),  'w--',...
    R4(:,12),force0(:,1),  'w--',R4(:,19),force0(:,1),  'w--','LineWidth', 1);
hold off;
uistack(f);

subplot(334);pcolor(R5,force0,E);
title('T=0.9 N/m');
xlim([0 1.1e-7]);
caxis([30 60]);
shading flat;
colorbar;
hold on;
f=plot(R5(:,12),force0(:,1),  'w--',R5(:,20),force0(:,1),  'w--',...
    R5(:,21),force0(:,1),  'w--',R5(:,28),force0(:,1),  'k--',...
    R5(:,8),force0(:,1),  'w--','LineWidth', 1);
hold off;
uistack(f);

subplot(335);pcolor(R6,force0,E);
title('T=1.0 N/m');
xlim([0 1.1e-7]);
caxis([30 60]);
shading flat;
colorbar;
hold on;
f=plot(R6(:,15),force0(:,1),  'w--',R6(:,16),force0(:,1),  'w--',...
    R6(:,17),force0(:,1),  'w--','LineWidth', 1);
hold off;
uistack(f);

subplot(336);pcolor(R7,force0,E);
title('T=1.1 N/m');
xlim([0 1.1e-7]);
caxis([30 60]);
shading flat;
colorbar;
hold on;
f=plot(R7(:,26),force0(:,1),  'k--','LineWidth', 1);
hold off;
uistack(f);

subplot(337);pcolor(R8,force0,E);
title('T=1.2 N/m');
xlim([0 1.1e-7]);
caxis([30 60]);
shading flat;
colorbar;
hold on;
f=plot(R8(:,28),force0(:,1),  'k--','LineWidth', 1);
hold off;
uistack(f);

subplot(338);pcolor(R9,force0,E);
title('T=1.3 N/m');
xlim([0 1.1e-7]);
caxis([30 60]);
shading flat;
colorbar;
hold on;
f=plot(R9(:,24),force0(:,1),  'k--','LineWidth', 1);
hold off;
uistack(f);

subplot(339);
f1=plot(R9(:,24),force0(:,1),  '--',...
    R8(:,28),force0(:,1),  '--',...
    R7(:,26),force0(:,1),  '--',...
    R6(:,15),force0(:,1),  '--',R6(:,16),force0(:,1),  '--',...
    R6(:,17),force0(:,1), '--',...
    R5(:,12),force0(:,1),  '--',R5(:,20),force0(:,1),  '--',...
    R5(:,21),force0(:,1),  '--',R5(:,28),force0(:,1),  '--',...
    R5(:,8),force0(:,1),  '--',...
    R4(:,10),force0(:,1),  '--',R4(:,13),force0(:,1),  '--',...
    R4(:,12),force0(:,1),  '--',R4(:,19),force0(:,1), '--',...
    R3(:,20),force0(:,1),  '--',...
    R2(:,17),force0(:,1),  '--',R1(:,18),force0(:,1), '--','LineWidth', 1);
title('Experiment data');
xlim([0 1.5e-7]);
ylim([0 6e-7]);
        
    case '44nm'
                simuData = handles.input_train(:, 1305:1451); % 替换为44nm的数据

        kt = ones(1, 61) * 40;
        for i = 1:21
            E(:, i) = kt + i - 1;
        end
        
        T12(:, :) = simuData(:, 1:21);
        T13(:, :) = simuData(:, 22:42);
        T14(:, :) = simuData(:, 43:63);
        T15(:, :) = simuData(:, 64:84);
        T16(:, :) = simuData(:, 85:105);
        T17(:, :) = simuData(:, 106:126);
        T18(:, :) = simuData(:, 127:147);
        
        force=0:1e-8:6e-7;
        for i = 1:21
            force0(:, i) = force(:);
        end        
        
        figure('Name', '44nm-薄膜力-位移曲线机器学习分类结果', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 800]);
        colormap(parula);
        subplot(331);pcolor(T13,force0,E);
title('T=1.3 N/m');
xlim([0 0.7e-7]);
caxis([40 60]);
shading flat;
colorbar;
hold on;
f=plot(T13(:,12),force0(:,1),  'w--', 'LineWidth', 1);
hold off;
uistack(f);

subplot(332);pcolor(T14,force0,E);
title('T=1.4 N/m');
xlim([0 0.7e-7]);
caxis([40 60]);
shading flat;
colorbar;
hold on;
f=plot(T14(:,15),force0(:,1),  'k--', 'LineWidth', 1);
hold off;
uistack(f);

subplot(333);pcolor(T15,force0,E);
title('T=1.5 N/m');
xlim([0 0.7e-7]);
caxis([40 60]);
shading flat;
colorbar;
hold on;
f=plot(T15(:,3),force0(:,1),  'w--',T15(:,7),force0(:,1),  'w--',...
    T15(:,21),force0(:,1),  'w--','LineWidth', 1);
hold off;
uistack(f);

subplot(334);pcolor(T16,force0,E);
title('T=1.6 N/m');
xlim([0 0.7e-7]);
caxis([40 60]);
shading flat;
colorbar;
hold on;
f=plot(T16(:,5),force0(:,1),  'w--',T16(:,11),force0(:,1),  'w--',...
    T16(:,4),force0(:,1),  'w--','LineWidth', 1);
hold off;
uistack(f);

subplot(335);pcolor(T18,force0,E);
title('T=1.8 N/m');
xlim([0 0.7e-7]);
caxis([40 60]);
shading flat;
colorbar;
hold on;
f=plot(T18(:,8),force0(:,1),  'w--',T18(:,10),force0(:,1),  'w--', 'LineWidth', 1);
hold off;
uistack(f);

subplot(336);
f1=plot(T18(:,8),force0(:,1),  '--',T18(:,10),force0(:,1),  '--',...
    T16(:,5),force0(:,1),  '--',T16(:,11),force0(:,1),  '--',...
    T16(:,4),force0(:,1),  '--',...
    T15(:,3),force0(:,1),  '--',T15(:,7),force0(:,1),  '--',...
    T15(:,21),force0(:,1),  '--',...
    T14(:,15),force0(:,1),  '--',...
    T13(:,12),force0(:,1), '--','LineWidth', 1);
title('Experiment data');
xlim([0 1.5e-7]);
ylim([0 6e-7]);
        
end



guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
