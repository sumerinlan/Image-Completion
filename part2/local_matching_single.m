function local_matching_single(loc, withmask)

	addpath(loc)

	target = im2double(imread('input.jpg'));

	if withmask == false
		% get mask
		objmask = getMask(target);
		imwrite(objmask, sprintf('%s/mask.jpg', loc));
		objmask = cat(3, objmask, objmask, objmask);
	else
		objmask = im2double(imread('mask.jpg'));
		if size(objmask, 3) == 1
			objmask = cat(3, objmask, objmask, objmask);
		end
	end
	target = target .* ~objmask;
	imshow(target);

	[h, w, k] = size(target);
	[h1, w1, h2, w2] = find_rect(target);

	border = 80;
	top = max(1, h1 - border); % overflow
	bottom = min(h, h2 + border); 
	left = max(1, w1 - border); 
	right = min(w, w2 + border);
	bdtop = min(border, h1);
	bdbottom = min(border, h - h2);
	bdleft = min(border, w1);
	bdright = min(border, w - w2);
	if sum(sum(sum(~objmask(h1, w1:w2, :)))) > 20
		bdtop = bdtop + min(border, (h2 - h1) / 2); % valid cut region
	end
	if sum(sum(sum(~objmask(h2, w1:w2, :)))) > 20
		bdbottom = bdbottom + min(border, (h2 - h1) / 2); % valid cut region
	end
	if sum(sum(sum(~objmask(h1:h2, w1, :)))) > 20
		bdleft = bdleft + min(border, (w2 - w1) / 2); % valid cut region
	end
	if sum(sum(sum(~objmask(h1:h2, w2, :)))) > 20
		bdright = bdright + min(border, (w2 - w1) / 2); % valid cut region
	end

	%% to show rectangle (debug)
	
	function plot_rec(x1, y1, x2, y2)
		ii = [x1, x1, x2, x2, x1];
		jj = [y1, y2, y2, y1, y1];
		plot(jj, ii, 'LineWidth', 2);
	end

% 	h = figure
% 	imshow(target)
% 	hold on
% 	plot_rec(h1, w1, h2, w2)
% 	hold on
% 	plot_rec(top, left, bottom, right)
% 	hold on
% 	plot_rec(top+bdtop, left+bdleft, bottom-bdbottom, right-bdright)
% 	saveas(h, sprintf('%s/border.png', loc));

	%% build map
	
	c = containers.Map;
	fid = fopen('dist.txt');
	tline = fgetl(fid);
	while ischar(tline)
		par = strsplit(tline, ': ');
		c(par{1}) = str2double(par{2});
		tline = fgetl(fid);
	end
	fclose(fid);
	
	%% add for loop here
% 	score_list = zeros(19, 1);
	dinfo = dir(sprintf('%s/20*.jpg', loc));
	c1 = containers.Map;
	objmask_new = objmask(top:bottom, left:right, :);
	patch = target(top:bottom, left:right, :);
	fid = fopen('data.txt','wt');
	for i = 1:length(dinfo)
		
		thisfilename = dinfo(i).name;
		c1(int2str(i)) = thisfilename;
		
		im = im2double(imread(thisfilename)); % choose top 20 semantic matching images
		
		%% find mask
		sample = im(top:bottom, left:right, :);
		[mask, cutcost] = find_mask(patch, sample, objmask_new, bdtop, bdbottom, bdleft, bdright);
		
		%% blending
		mask_s = zeros(h, w, 3); % same size as background
		mask_s(top:bottom, left:right, :) = mask;
		im_s = zeros(h, w, 3); % same size as background
		im_s(top:bottom, left:right, :) = sample;
		[poisson, blendcost] = poissonBlend(im_s, mask_s, target);
% 		figure
% 		imshow(poisson);
% 		imwrite(poisson, sprintf('%s/after%d.jpg', loc, i));
		% NO [index] with cost [cost];
		fprintf(fid, 'No. %d %s: gistdist=%f\n cutcost=%f blendcost=%f\n', i, thisfilename, c(thisfilename), cutcost, blendcost);
% 		score_list(i) = cutcost * 10^(-2) + blendcost * 10^(-1) + 2*c(thisfilename); % sum of 4 cut cost	
% 		fprintf('No. %d %s with cost %f\n', i, thisfilename, score_list(i));  	
	end
	fclose(fid);
	
	% find min5
% 	sorted = sort(score_list);
% 	for i = 1:5 % best 5
% 		idx = find(score_list == sorted(i));
% 		% BEST [rank]: [index] with cost [cost]
% 		fprintf('BEST %d: no. %d %s with cost %f\n', i, idx, c1(int2str(idx)), score_list(idx));
% 	end

end
