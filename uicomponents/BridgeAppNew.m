function BridgeAppNew
% Load in data
s = load("BridgeScoresTable.mat");
data = s.bridgeScores;

figwidth = 800;
figheight = 400;
fig = uifigure(Position=[100 100 figwidth figheight]);
g = uigridlayout(fig);
g.RowHeight = {'1x','fit'};
g.ColumnWidth = {'fit','fit','1x'};
pnlFilter = uipanel(g,Title="Filter Data");
pnlFilter.Layout.Row = [1 2];
pnlFilter.Layout.Column = 1;

gFilter = uigridlayout(pnlFilter);
gFilter.RowHeight = {'1x','fit','fit','fit','1x','fit','fit','1x','fit','fit','fit','1x'};
gFilter.ColumnWidth = {'1x'};
lblResult = uilabel(gFilter,Text="Result",FontWeight="bold");
lblResult.Layout.Row = 2;
cbxMaking = uicheckbox(gFilter,Text="Making",Value=true, ...
    ValueChangedFcn=@updateData);
cbxMaking.Layout.Row = 3;
cbxDown = uicheckbox(gFilter,Text="Down",Value=true, ...
    ValueChangedFcn=@updateData);
cbxDown.Layout.Row = 4;
lblPartner = uilabel(gFilter,Text="Partner",FontWeight="bold");
lblPartner.Layout.Row = 6;
ddPartner = uidropdown(gFilter,Items=["All","Alice","Bob","Charlie"], ...
    ValueChangedFcn=@updateData);
ddPartner.Layout.Row = 7;
lblPosition = uilabel(gFilter,Text="Position",FontWeight="bold");
lblPosition.Layout.Row = 9;
cbxDeclaring = uicheckbox(gFilter,Text="Declaring",Value=true, ...
    ValueChangedFcn=@updateData);
cbxDeclaring.Layout.Row = 10;
cbxDefending = uicheckbox(gFilter,Text="Defending",Value=true, ...
    ValueChangedFcn=@updateData);
cbxDefending.Layout.Row = 11;

tbl = uitable(g,Data=data,ColumnWidth={'fit'}, ...
    ColumnEditable=[false true true true],ColumnSortable=true);
tbl.Layout.Row = [1 2];
tbl.Layout.Column = 2;
styleTable;

ax = uiaxes(g);
ax.Layout.Row = 1;
ax.Layout.Column = 3;
h = histogram(ax,tbl.Data.Overtricks);
title(ax,"Contract Result")
xlabel(ax,"Tricks Off From Contract")
ylabel(ax,"Hands")

pnlAddData = uipanel(g,Title="Add New Hand");
pnlAddData.Layout.Row = 2;
pnlAddData.Layout.Column = 3;
gAddData = uigridlayout(pnlAddData);
gAddData.RowHeight = {'1x','1x','1x'};
gAddData.ColumnWidth = {'fit',50,'fit','fit',50};
lblBid = uilabel(gAddData,Text="Bid:");
lblBid.Layout.Row = 1;
lblBid.Layout.Column = 1;
editBid = uispinner(gAddData,Value=1,Limits=[1 7]);
editBid.Layout.Row = 1;
editBid.Layout.Column = 2;
ddBid = uidropdown(gAddData,Items=["♣","♦","♥","♠"]);
ddBid.Layout.Row = 1;
ddBid.Layout.Column = 3;
lblOvertricks = uilabel(gAddData,Text="Overtricks:");
lblOvertricks.Layout.Row = 1;
lblOvertricks.Layout.Column = 4;
editOvertricks = uispinner(gAddData,Value=0,Limits=[-13 13]);
editOvertricks.Layout.Row = 1;
editOvertricks.Layout.Column = 5;
lblPartner = uilabel(gAddData,Text="Partner:");
lblPartner.Layout.Row = 2;
lblPartner.Layout.Column = 1;
ddSelectPartner = uidropdown(gAddData,Items=["Alice","Bob","Charlie"]);
ddSelectPartner.Layout.Row = 2;
ddSelectPartner.Layout.Column = [2 3];
lblDeclaring = uilabel(gAddData,Text="Declaring:");
lblDeclaring.Layout.Row = 2;
lblDeclaring.Layout.Column = 4;
cbxIsDeclaring = uicheckbox(gAddData,Value=true,Text="");
cbxIsDeclaring.Layout.Row = 2;
cbxIsDeclaring.Layout.Column = 5;
btnAdd = uibutton(gAddData,Text="Add",ButtonPushedFcn=@addData);
btnAdd.Layout.Row = 3;
btnAdd.Layout.Column = [4 5];


    function updateData(~,~)
    % Filter on result
    overtricks = zeros(height(data),1);
    position = zeros(height(data),1);
    if cbxDown.Value
        overtricks = overtricks | data.Overtricks < 0;
    end
    if cbxMaking.Value
        overtricks = overtricks | data.Overtricks >= 0;
    end
    if cbxDeclaring.Value
        position = position | data.Declaring;
    end
    if cbxDefending.Value
        position = position | ~data.Declaring;
    end
    rows = overtricks & position;
    if ddPartner.Value ~= "All"
        partner = matches(data.Partner,ddPartner.Value);
        rows = rows & partner;
    end
    newdata = data(rows,:);
    tbl.Data = newdata;
    plotData;
    styleTable;
    end

    function plotData
        filteredOvertricks = tbl.Data.Overtricks;
        h.Data = filteredOvertricks;
    end

    function addData(~,~)
        newbid = {editBid.Value ddBid.Value};
        newovertricks = editOvertricks.Value;
        newpartner = string(ddSelectPartner.Value);
        newposition = cbxIsDeclaring.Value;
        newdata = table(newbid,newovertricks,newpartner,newposition, ...
            VariableNames=["Bid" "Overtricks" "Partner" "Declaring"]);
        data = [data;newdata];
        updateData([],[]);
    end

    function styleTable
        removeStyle(tbl)
        undertrickRows = find(tbl.Data.Overtricks < 0);
        sUnder = uistyle(BackgroundColor="#FFBBAA");
        addStyle(tbl,sUnder,"row",undertrickRows)
        makingRows = find(tbl.Data.Overtricks == 0);
        sMaking = uistyle(BackgroundColor="#D5FFAD");
        addStyle(tbl,sMaking,"row",makingRows)
        overtrickRows = find(tbl.Data.Overtricks > 0);
        sOver = uistyle(BackgroundColor="#ADBDFF");
        addStyle(tbl,sOver,"row",overtrickRows)
    end
end