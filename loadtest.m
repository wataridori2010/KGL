fp=fopen('test.csv','r');data=textscan(fp,'%n%n%n%D%n%n%q%q','delimiter', ',', 'headerLines', 1 );fclose(fp);f0=data{1};f1=data{2};f2=data{3};f3=datenum(data{4});f4=data{5};f5=data{6};fnum=length(data{6});f8=zeros(fnum,1);f9=zeros(fnum,1);for i=1:fnum    if(strcmp(data{7}{i},'0'))        f8(i)=0;    elseif(strcmp(data{7}{i},'a'))        f8(i)=1;    elseif(strcmp(data{7}{i},'b'))        f8(i)=2;    elseif(strcmp(data{7}{i},'c'))                f8(i)=3;    else        f8(i)=4;            end            if(strcmp(data{8}{i},'0'))        f9(i)=0;    else        f9(i)=1;            endendmaxf1=max(f1);minf3=min(f3);maxf3=max(f3);map2=zeros(maxf1,maxf3-minf3+1);map4=zeros(maxf1,maxf3-minf3+1);map5=zeros(maxf1,maxf3-minf3+1);map6=zeros(maxf1,maxf3-minf3+1);map7=zeros(maxf1,maxf3-minf3+1);map8=zeros(maxf1,maxf3-minf3+1);map9=zeros(maxf1,maxf3-minf3+1);for i=1:fnum    map2(f1(i),f3(i)-minf3+1)=f2(i);%week    map4(f1(i),f3(i)-minf3+1)=f4(i);%open    map5(f1(i),f3(i)-minf3+1)=f5(i);%promo    map8(f1(i),f3(i)-minf3+1)=f8(i);%holi1    map9(f1(i),f3(i)-minf3+1)=f9(i);%holi2    endfigure;imagesc(map2);figure;imagesc(map4);figure;imagesc(map5);figure;imagesc(map8);figure;imagesc(map9);%=========================================================================% solution1,2% average%{%map4a=mean(map4');%save('map4a.mat','map4a');load 'map4a.mat'pred=zeros(fnum,2);pred(:,1)=1:fnum;for i=1:fnum%    pred(i,2)=map4a(f1(i))*f4(i);%too much huristec....    pred(i,2)=map4a(f1(i))*f4(i)*(8.0-f2(i)+4)/8.0;%too much huristec....endcsvwrite('res.csv',pred);%}%=========================================================================% solution3% kNN%{load 'map29.mat' %training dataload 'map4a.mat' map29size=size(map29,2);%the term of training data pred=zeros(fnum,2);pred(:,1)=1:fnum;%C1=1;   C2=7;   C3=3;   C4=3;   C5=3;C1=1;   C2=7;   C3=2;   C4=5;   C5=5;for i=1:fnum        store = f1(i);    %find closest feature    % f1(i) : store    % f2(i) : day of week    % f3(i) : time        % f4(i) : open    % f5(i) : promo    % f8(i) : state holiday    % f9(i) :  holiday        %map29(store,time,1) : day of week    %map29(store,time,2) : sales    %map29(store,time,3) : customers    %map29(store,time,4) : open    %map29(store,time,5) : promo    %map29(store,time,6) : state holiday    %map29(store,time,7) : hokiday    minDist=100000000;    p1=0;p2=0;p3=0;    for j=1:map29size        Dist= C1*abs(map29(store,j,1) - f2(i)) +...            C2*abs(map29(store,j,4) - f4(i)) +...            C3*abs(map29(store,j,5) - f5(i)) +...            C4*abs(map29(store,j,6) - f8(i)) +...            C5*abs(map29(store,j,7) - f9(i));        if(minDist>Dist)            minDist=Dist;            p3=p2;            p2=p1;                        p1=map29(store,j,2);        end    end    %    pred(i,2)=(p1+p2+p3)/3;    pred(i,2)=f4(i)*(p1+p2+p3)/3;    %    pred(i,2)=map4a(f1(i))*f4(i);%too much huristec....%    pred(i,2)=map4a(f1(i))*f4(i)*(8.0-f2(i)+4)/8.0;%too much huristec....    fprintf('%d\n',i);endcsvwrite('res.csv',pred);%}%=========================================================================% solution4 SVM :each line modeladdpath('./libsvm-3.20/matlab');%map4a=mean(map4');%save('map4a.mat','map4a');load 'map4a.mat'%load 'modelStock.mat'%load 'modelStock2.mat'%load 'modelStock800942.mat'%load 'modelStock800942_2.mat'%load 'modelStock_season.mat'%load 'modelStock3.mat'%load 'modelStock4.mat'%load 'modelStock43.mat'load 'modelStock50.mat'mean6=mean(map8)';mean7=mean(map9)';minf3=min(f3);maxf3=max(f3);pred=zeros(fnum,2);pred(:,1)=1:fnum;for i=1:fnum%    pred(i,2)=map4a(f1(i))*f4(i);%too much huristec....    model=modelStock{f1(i)};%    X=[f2(i) f4(i) f5(i) f8(i) f9(i)];%    X=[f2(i) f4(i) f5(i) f8(i) f9(i) mean6(f3(i)-minf3+1) mean7(f3(i)-minf3+1)];    X=[f2(i) f4(i) f5(i) f8(i) f9(i) mean6(maxf3-f3(i)+1) mean7(maxf3-f3(i)+1)];    %    X=[f2(i) f4(i) f5(i)]; %only for modelstock4.mat    y=1000;    [y_hat, Acc, projection] = svmpredict(y, X, model);    pred(i,2)=projection;%    pred(i,2)=f4(i)*projection;%    pred(i,2)=map4a(f1(i))*f4(i)*(8.0-f2(i)+4)/8.0;%too much huristec....    fprintf('%d\n',i);endcsvwrite('res.csv',pred);%=========================================================================%{%previous result checkpred=zeros(fnum,2);pred(:,1)=1:fnum;rs=csvread('res1_submission.csv',1,0); %previous resultpred(:,2)=rs(:,2);%}%=========================================================================%result visualizationmapR=zeros(maxf1,maxf3-minf3+1);for i=1:fnum    mapR(f1(i),f3(i)-minf3+1)=pred(i,2);endfigure;imagesc(mapR);%=========================================================================%estimation%{[B,dev,stats] = mnrfit(map2(1,:),map4(1,:));% (x,y)%[b,bint,r,rint,stats] = regress(y,X)X=[map4(1,:)' map6(1,:)' map7(1,:)' map8(1,:)' map9(1,:)'];y=map2(1,:)';[b,bint,r,rint,stats] = regress(y,X);mdl = nlinfit(map2(1,:),map4(1,:),@hougen,0)p=polyfit(map2(1,:),map4(1,:),2);%(x,y)polyval(p,)%}