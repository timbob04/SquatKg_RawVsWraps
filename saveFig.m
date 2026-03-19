function saveFig(saveName)

if ~exist(fileparts(saveName),'dir') > 0
    return
end

set(gcf,'Units','inches')
pos = get(gcf,'Position');

set(gcf,'PaperUnits','inches')
set(gcf,'PaperPositionMode','manual')
set(gcf,'PaperPosition',[0 0 pos(3) pos(4)])
set(gcf,'PaperSize',[pos(3) pos(4)])

pause(1)

print(saveName,'-dpdf','-vector')


