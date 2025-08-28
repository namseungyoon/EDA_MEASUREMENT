clear all
close all

fileList = dir();
n_files = length(fileList);

pccs = double(0);
rmses = double(0);
norm_pccs = double(0);
norm_pccs = double(0);
for n = 1:n_files
    
    if contains(fileList(n).name, 'fetEDA_nomadixEDA_')
        fileName = fileList(n).name;
        load(fileName);
        timeIdx = fetEDA_nomadixEDA.time;

        fetEDA = fetEDA_nomadixEDA.fetEDA;
        nomadixEDA = fetEDA_nomadixEDA.nomadixEDA;
        pcc = corr(fetEDA, nomadixEDA);  % 또는 corr(predicted', actual')로도 사용 가능
        rmse = sqrt(mean((fetEDA - nomadixEDA).^2));
        pccs(n) = pcc;
        rmses(n) = rmse;

        norm_fetEDA = normalize(fetEDA,"range");
        norm_nomadixEDA = normalize(nomadixEDA,"range");
        norm_pcc = corr(norm_fetEDA, norm_nomadixEDA);  % 또는 corr(predicted', actual')로도 사용 가능
        norm_rmse = sqrt(mean((norm_fetEDA - norm_nomadixEDA).^2));
        norm_pccs(n) = norm_pcc;
        norm_rmses(n) = norm_rmse;
        
        figure(n);
        subplot(2,1,1);
        plot(timeIdx, fetEDA);
        hold on;
        plot(timeIdx, nomadixEDA);
        hold off;
        title_str = ['PCC = ', num2str(pcc), ', RMSE = ', num2str(rmse)];
        title(title_str)
        subplot(2,1,2);
        plot(timeIdx, norm_fetEDA);
        hold on;
        plot(timeIdx, norm_nomadixEDA);
        hold off;
        title_norm_str = ['norm\_PCC = ', num2str(norm_pcc), ', norm\_RMSE = ', num2str(norm_rmse)];
        title(title_norm_str);
    end
end
