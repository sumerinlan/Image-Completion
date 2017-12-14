function local_matching_single(target)

	[h, w, k] = size(target);
	[h1, w1, h2, w2] = find_rect(target);

	border = 80;
	top = max(1, h1 - border); % overflow
	bottom = min(h, h2 + border); 
	left = max(1, w1 - border); 
	right = min(w, w2 + border);
	bdtop = min(border, h1 - 1); % valid cut region
	bdbottom = min(border, h - h2);
	bdleft = min(border, w1 - 1);
	bdright = min(border, w - w2);

	%% to show rectangle (debug)
	% figure
	% imshow(target)
	% hold on
	% ii = [x1, x1, x2, x2, x1];
	% jj = [y1, y2, y2, y1, y1];
	% plot(jj, ii, 'r-', 'LineWidth', 1);
	% hold on
	% ii = [top, top, bottom, bottom, top];
	% jj = [left, right, right, left, left];
	% plot(jj, ii, 'b-', 'LineWidth', 1);

	%% add for loop here
	score_list = zeros(4, 1);
	for i = 1:6 % change 6 to 20 !!
		
		im = im2double(imread(sprintf('../test_img/before_%d.jpg',i))); % choose top 20 semantic matching images

		%% find mask
		patch = target(top:bottom, left:right, :);
		sample = im(top:bottom, left:right, :);
		[mask, score] = find_mask(patch, sample, bdtop, bdbottom, bdleft, bdright);

		%% blending
		mask_s = zeros(h, w, 3); % same size as background
		mask_s(top:bottom, left:right, :) = mask;
		im_s = zeros(h, w, 3); % same size as background
		im_s(top:bottom, left:right, :) = sample;
		poisson = poissonBlend(im_s, mask_s, target);
		% figure
		% imshow(poisson);
		imwrite(poisson, sprintf('../test_img/after_%d.jpg',i));
		% NO [index] with cost [cost]
		score_list(i) = score; % sum of 4 cut cost	
		fprintf('NO %d with cost %f\n', i, score);  	
	end
	
	% find min5
	sorted = sort(score_list);
	for i = 1:3 % best 5
		idx = find(score_list == sorted(i));
		% BEST [rank]: [index] with cost [cost]
		fprintf('BEST %d: %d with cost %f\n', i, idx, score_list(idx));
	end

end
