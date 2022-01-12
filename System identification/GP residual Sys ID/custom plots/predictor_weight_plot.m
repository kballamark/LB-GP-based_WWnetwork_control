%%

for i = 1:Nx 
    weights{i} = exp(-gps{i}.KernelInformation.KernelParameters(1:end-1));      % Predictor weights
    weights{i} = weights{i}/sum(weights{i});                                    % normalized predictor weights
end

%% Find the predictor weights by taking the exponential of the negative learned length scales. Normalize the weights.

figure

i = 1;
ax(i) = subplot(2,2,i);
ax(i).TickLabelInterpreter='latex';
b(i) = bar(weights{i},'FaceColor','flat');
clr1 = [1,0,0; 0.5,0.5,0.5];
b(i).CData = clr1;
ylim([0,1])
ylabel('Weight','interpreter','latex')
%xlabel('Index','interpreter','latex')
grid on
title('$y_1$','interpreter','latex')
ax(i).XTickLabel={'d_{t1}', 't'};
xtips = b(i).XEndPoints;
ytips = b(i).YEndPoints;
labels = string(round(b(i).YData,2));
text(xtips,ytips,labels,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')

i = 2;
ax(i) = subplot(2,2,i);
ax(i).TickLabelInterpreter='latex';
b(i) = bar(weights{i},'FaceColor','flat');
clr1 = [0,0.5,0; 0,0,1; 0.5, 0.5, 0.5];
b(i).CData = clr1;
ylim([0,1])
ylabel('Weight','interpreter','latex')
%xlabel('Index','interpreter','latex')
grid on
title('$y_2$','interpreter','latex')
ax(i).XTickLabel={'h_{p4}', 'Q_{t2}','t'};
xtips = b(i).XEndPoints;
ytips = b(i).YEndPoints;
labels = string(round(b(i).YData,2));
text(xtips,ytips,labels,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')

i = 3;
ax(i) = subplot(2,2,i);
ax(i).TickLabelInterpreter='latex';
b(i) = bar(weights{i},'FaceColor','flat');
clr1 = [0,0.5,0; 0,0,1; 0.5, 0.5, 0.5];
b(i).CData = clr1;
ylim([0,1])
ylabel('Weight','interpreter','latex')
xlabel('Index','interpreter','latex')
grid on
title('$y_3$','interpreter','latex')
ax(i).XTickLabel={'h_{p3}', 'Q_{t1}', 't'};
xtips = b(i).XEndPoints;
ytips = b(i).YEndPoints;
labels = string(round(b(i).YData,2));
text(xtips,ytips,labels,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')

i = 4;
ax(i) = subplot(2,2,i);
ax(i).TickLabelInterpreter='latex';
b(i) = bar(weights{i},'FaceColor','flat');
clr1 = [0,0.5,0; 0,0.5,0; 0.5,0.5,0.5];
b(i).CData = clr1;
ylim([0,1])
ylabel('Weight','interpreter','latex')
xlabel('Index','interpreter','latex')
grid on
title('$y_4$','interpreter','latex')
ax(i).XTickLabel={'h_{p3}', 'h_{p4}', 't'};
xtips = b(i).XEndPoints;
ytips = b(i).YEndPoints;
labels = string(round(b(i).YData,2));
text(xtips,ytips,labels,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')

sgtitle('Predictor relevance')