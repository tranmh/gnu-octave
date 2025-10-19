s/xline(\([0-9]*\), '\([^']*\)', 'LineWidth', \([0-9.]*\), 'Label', '\([^']*\)')/plot([\1, \1], ylim, '\2', 'LineWidth', \3); text(\1, max(ylim)*0.95, '\4', 'Rotation', 90, 'VerticalAlignment', 'bottom')/g
s/xline(\([0-9]*\), '\([^']*\)', 'LineWidth', \([0-9.]*\))/plot([\1, \1], ylim, '\2', 'LineWidth', \3)/g
