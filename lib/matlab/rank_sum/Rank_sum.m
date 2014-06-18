% Initial settings
function Rank_sum(mozmin, mozmax)
MOZMIN = mozmin; MOZMAX = mozmax;
DIR = './';
FILE1 = 'data1.txt';
FILE2 = 'data2.txt';

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

% Wilcoxon Rank Sum test of the raw data
G = zeros(i, 1); P = zeros(i, 1);
MU1 = median(X1(:, :), 2);
MU2 = median(X2(:, :), 2);
for I = 1:i
    if MU1(I, 1) > MU2(I, 1)
        G(I, 1) = 1;
    else
        G(I, 1) = 2;
    end
    P(I, 1) = ranksum(X1(I, :), X2(I, :));
end

% Conversion of raw data/0.1s into compressed data/1s
si = i/10;
SMOZ = zeros(si, 1); SX1 = zeros(si, j1); SX2 = zeros(si, j2);
L = 1;
for I=1:10:i
    SMOZ(L, 1) = median(MOZ(I:I+9, 1));
    SX1(L, :) = mean(X1(I:I+9, :));
    SX2(L, :) = mean(X2(I:I+9, :));
    L = L + 1;
end

% Wilcoxon Rank Sum test of the compressed data
SG = zeros(si, 1); SP = zeros(si, 1);
SMU1 = median(SX1(:, :), 2);
SMU2 = median(SX2(:, :), 2);
for I = 1:si
    if SMU1(I, 1) > SMU2(I, 1)
        SG(I, 1) = 1;
    else
        SG(I, 1) = 2;
    end
    SP(I, 1) = ranksum(SX1(I, :), SX2(I, :));
end

% File export of results ('mean_pvalue_1.txt', 'mean_pvalue_1s.txt')
MP1 = [MOZ, MU1, MU2, P, G];
SMP1 = [SMOZ, SMU1, SMU2, SP, SG];
fid = fopen([DIR, 'median_pvalue_1.txt'], 'w');
fids = fopen([DIR, 'median_pvalue_1s.txt'], 'w');
fprintf(fid, '%s\t%s\t%s\t%s\t%s\n', 'm/z', 'median1', 'median2', 'P', 'Greater');
fprintf(fids, '%s\t%s\t%s\t%s\t%s\n', 'm/z', 'median1', 'median2', 'P', 'Greater');
fprintf(fid, '%.1f\t%.3f\t%.3f\t%.3e\t%d\n', MP1');
fprintf(fids, '%.1f\t%.3f\t%.3f\t%.3e\t%d\n', SMP1');
fclose(fid);
fclose(fids);

% Graphical representation of the results from raw data ('Figure 1')
figure
set(0, 'defaultAxesFontSize', 14);
set(0,'defaultAxesFontName','Centry')
set(0,'defaultTextFontName','Centry')
set(0, 'defaultAxesFontWeight','demi');
set(0,'defaultAxesLineWidth', 0.5);
subplot(2, 1, 1);
plot(MOZ, MU1, 'b', MOZ, MU2, 'r');
legend({NAME1, NAME2}, 'interpreter', 'none', 'Location', 'Best');
xlabel('m/z'); ylabel('Relative intensity');
subplot(2, 1, 2);
semilogy(MOZ, P, 'k', MOZ, 0.05/numel(MOZ), 'g')
xlabel('m/z'); ylabel('p-value');

% Graphical representation of the results from compressed data ('Figure 2')
figure
subplot(2, 1, 1);
plot(SMOZ, SMU1, 'b', SMOZ, SMU2, 'r');
legend({NAME1, NAME2}, 'interpreter', 'none', 'Location', 'Best');
xlabel('m/z'); ylabel('Relative intensity');
subplot(2, 1, 2);
semilogy(SMOZ, SP, 'k', MOZ, 0.05/numel(SMOZ), 'g');
xlabel('median(m/z)'); ylabel('p-value');

% File export of the results which is ordered ascendingly by p-values
% ('median_pvalue_2.txt', 'median_pvalue_2s.txt')
MP2 = sortrows(MP1, 4);
SMP2 = sortrows(SMP1, 4);
fid = fopen([DIR, 'median_pvalue_2.txt'], 'w');
fids = fopen([DIR, 'median_pvalue_2s.txt'], 'w');
fprintf(fid, '%s\t%s\t%s\t%s\t%s\n', 'm/z', 'median1', 'median2', 'P', 'Greater');
fprintf(fids, '%s\t%s\t%s\t%s\t%s\n', 'm/z', 'median1', 'median2', 'P', 'Greater');
fprintf(fid, '%.1f\t%.3f\t%.3f\t%.3e\t%d\n', MP2');
fprintf(fids, '%.1f\t%.3f\t%.3f\t%.3e\t%d\n', SMP2');
fclose(fid);
fclose(fids);
