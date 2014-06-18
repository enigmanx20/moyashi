% Initial settings
function PCA_LDA(mozmin, mozmax, pcx, pcy)
MOZMIN = mozmin; MOZMAX = mozmax;
DIR = './';
FILE1 = 'data1.txt';
FILE2 = 'data2.txt';
num1 = pcx;  % PC num1 for the x axis
num2 = pcy;  % PC num2 for the y axis

D1 = importdata([DIR, FILE1], '\t', 2);
D2 = importdata([DIR, FILE2], '\t', 2);
NAME1 = D1.textdata{1, 1};
NAME2 = D2.textdata{1, 1};
[i1, j1] = size(D1.data);
[i2, j2] = size(D2.data);
if i1 > i2
    error('D1.data has greater number of rows.');
elseif i1 < i2
    error('D2.data has greater number of rows.');
else
    MOZ = D1.data(1:i1, 1);
    X1 = D1.data(1:i1, 2:j1);
    X2 = D2.data(1:i1, 2:j2);
end

X1 = X1(MOZMIN<=MOZ & MOZ<MOZMAX, :);
X2 = X2(MOZMIN<=MOZ & MOZ<MOZMAX, :);
MOZ = MOZ(MOZMIN<=MOZ & MOZ<MOZMAX,1);
[i1, j1] = size(X1);
[~, j2] = size(X2);
i = i1;
clear i1 i2;

GROUP1 = repmat(NAME1, j1, 1);
GROUP2 = repmat(NAME2, j2, 1);
GROUP = char(GROUP1, GROUP2);

% Normalization of intensities by their mean
for I = 1:j1
    X1(:, I) = X1(:, I) ./ mean(X1(:, I));
end
for I = 1:j2
    X2(:, I) = X2(:, I) ./ mean(X2(:, I));
end

% PCA analysis (PC num1 v.s. PC num2)
[COEFF, SCORE, LATENT] = pca([X1, X2]');
kiyo = LATENT ./ sum(LATENT);
ruikiyo = cumsum(LATENT) ./ sum(LATENT);
PC1 = SCORE(:, num1);
PC2 = SCORE(:, num2);
figure
set(0, 'defaultAxesFontSize', 15);
set(0,'defaultAxesFontName','Centry')
set(0,'defaultTextFontName','Centry')
set(0, 'defaultAxesFontWeight','demi')
set(0,'defaultAxesLineWidth', 0.5)
h1 = gscatter(PC1, PC2, GROUP, 'br', 'oo', 10, 'off');
set(h1(1), 'MarkerFaceColor', 'b')
set(h1(2), 'MarkerFaceColor', 'r')
legend({NAME1, NAME2}, 'interpreter', 'none', 'Location', 'Best')
grid on;
hold on;

% Fisher's linear discriminant analysis
cls = ClassificationDiscriminant.fit([PC1, PC2], GROUP);
K = cls.Coeffs(1, 2).Const;
L = cls.Coeffs(1, 2).Linear;
f = @(PC1, PC2)K + L(1)*PC1 + L(2)*PC2;
h2 = ezplot(f, [min(PC1), max(PC1), min(PC2), max(PC2)]);
set(h2, 'Color', [0.6 0 0.6], 'LineWidth', 1)
axis([min(PC1), max(PC1), min(PC2), max(PC2)])
xlabel(['PC', num2str(num1), ' (', num2str(kiyo(num1,1)*100), ' %)'])
ylabel(['PC', num2str(num2), ' (', num2str(kiyo(num2,1)*100), ' %)'])
title('{\bf Linear Classification}', 'Color', [0.6 0 0.6])
% gname
hold off;

% K-fold cross validation
k = 10;
if k > j1 + j2
    fprintf(2, 'At least %d samples are required for %d-fold cross-validation.\n', k, k);
else
    cvmodel = crossval(cls, 'kfold', k);
    Loss = kfoldLoss(cvmodel);
    fprintf(1, '%d-fold cross-validation accuracy =\n\n\t%f\n\n', k, 1 - Loss);
end
