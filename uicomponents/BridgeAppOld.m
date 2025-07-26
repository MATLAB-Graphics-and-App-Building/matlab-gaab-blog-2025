function BridgeAppOld
% Load in data
s = load("BridgeScores.mat");
data = s.bridgeScoresCell;

figwidth = 800;
figheight = 400;
fig = figure(Position=[100 100 figwidth figheight]);
fig.MenuBar ="none";
pnlFilter = uipanel(fig,Position=[0.05 0.05 0.15 0.9],Title="Filter Data");
lblResult = uicontrol(pnlFilter,Position=[10 300 100 22], ...
    Style="text",String="Result",FontWeight="bold");
cbxMaking = uicontrol(pnlFilter,Position=[10 270 100 22], ...
    Style="checkbox",String="Making",Value=true,Callback=@updateData);
cbxDown = uicontrol(pnlFilter,Position=[10 240 100 22], ...
    Style="checkbox",String="Down",Value=true, ...
    Callback=@updateData);
lblPartner = uicontrol(pnlFilter,Position=[10 190 100 22], ...
    Style="text",String="Partner",FontWeight="bold");
ddPartner = uicontrol(pnlFilter,Position=[10 160 100 22], ...
    Style="popupmenu",String=["All","Alice","Bob","Charlie"], ...
    Callback=@updateData);
lblPosition = uicontrol(pnlFilter,Position=[10 100 100 22], ...
    Style="text",String="Position",FontWeight="bold");
cbxDeclaring = uicontrol(pnlFilter,Position=[10 70 100 22], ...
    Style="checkbox",String="Declaring",Value=true, ...
    Callback=@updateData);
cbxDefending = uicontrol(pnlFilter,Position=[10 40 100 22], ...
    Style="checkbox",String="Defending",Value=true, ...
    Callback=@updateData);

tbl = uitable(fig,Units="normalized",Position=[0.22 0.05 0.38 0.9], ...
    Data=data,RowName=[],ColumnName=["Bid","Overtricks","Partner","Declaring"]);

ax = axes(fig,OuterPosition=[0.62 0.35 0.33 0.6]);
h = histogram(ax,cell2mat(data(:,2)));
title(ax,"Contract Result")
xlabel(ax,"Tricks Off From Contract")
ylabel(ax,"Hands")

pnlAddData = uipanel(fig,Position=[0.62 0.05 0.33 0.25],Title="Add New Hand");
lblBid = uicontrol(pnlAddData,Position=[5 58 30 20], ...
    Style="text",String="Bid:");
editBid = uicontrol(pnlAddData,Position=[40 58 30 20], ...
    Style="edit",String="1");
ddBid = uicontrol(pnlAddData,Position=[75 58 40 22], ...
    Style="popupmenu",String=["♣","♦","♥","♠"]);
lblOvertricks = uicontrol(pnlAddData,Position=[135 58 60 20], ...
    Style="text",String="Overtricks:");
editOvertricks = uicontrol(pnlAddData,Position=[190 58 30 20], ...
    Style="edit",String="0");
lblPartner = uicontrol(pnlAddData,Position=[5 28 40 20], ...
    Style="text",String="Partner:");
ddSelectPartner = uicontrol(pnlAddData,Position=[50 28 75 22], ...
    Style="popupmenu",String=["Alice","Bob","Charlie"]);
lblDeclaring = uicontrol(pnlAddData,Position=[135 28 50 20], ...
    Style="text",String="Declaring:");
cbxIsDeclaring = uicontrol(pnlAddData,Position=[185 28 20 20], ...
    Style="checkbox",Value=true);
btnAdd = uicontrol(pnlAddData,Position=[220 5 30 25], ...
    Style="pushbutton",String="Add",Callback=@addData);


    function updateData(~,~)
    % Filter on result
    overtricks = zeros(height(data),1);
    position = zeros(height(data),1);
    if cbxDown.Value
        vals = cell2mat(data(:,2)) < 0;
        overtricks = overtricks | vals;
    end
    if cbxMaking.Value
        vals = cell2mat(data(:,2)) >= 0;
        overtricks = overtricks | vals;
    end
    if cbxDeclaring.Value
        vals = cell2mat(data(:,4));
        position = position | vals;
    end
    if cbxDefending.Value
        vals = ~cell2mat(data(:,4));
        position = position | vals;
    end
    rows = overtricks & position;
    partnerval = ddPartner.String{ddPartner.Value};
    if ~strcmp(partnerval,'All')
        partner = matches(string(data(:,3)),string(partnerval));
        rows = rows & partner;
    end
    newdata = data(rows,:);
    tbl.Data = newdata;
    plotData;
    end

    function plotData
        filteredOvertricks = cell2mat(tbl.Data(:,2));
        h.Data = filteredOvertricks;
    end

    function addData(~,~)
        newbid = [editBid.String ddBid.String{ddBid.Value}];
        newovertricks = str2double(editOvertricks.String);
        newpartner = ddSelectPartner.String{ddSelectPartner.Value};
        newposition = logical(cbxIsDeclaring.Value);
        data = [data;{newbid newovertricks newpartner newposition}];
        updateData([],[]);
    end
end