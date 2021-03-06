function [v, res] = poissonBlendOneDim(im_s, mask_s, im_background, miny, maxy, minx, maxx, im2var)
	Ai = [];
	Aj = [];
	Ak = [];
	b = zeros(5, 1);
	e = 0;
	% minimize (v(x+1,y)-v(x,y) - (s(x+1,y)-s(x,y)))^2
	for y = miny:maxy
		for x = minx:maxx-1
			if mask_s(y,x) && mask_s(y,x+1)
				e = e+1;
				Ai(end+1) = e;
				Aj(end+1) = im2var(y,x);
				Ak(end+1) = -1;
				Ai(end+1) = e;
				Aj(end+1) = im2var(y,x+1);
				Ak(end+1) = 1;
				b(e) = im_s(y,x+1)-im_s(y,x);
			end
		end
	end
	% minimize (v(x,y+1)-v(x,y) - (s(x,y+1)-s(x,y)))^2
	for y = miny:maxy-1
		for x = minx:maxx
			if mask_s(y,x) && mask_s(y+1,x)
				e = e+1;
				Ai(end+1) = e;
				Aj(end+1) = im2var(y,x);
				Ak(end+1) = -1;
				Ai(end+1) = e;
				Aj(end+1) = im2var(y+1,x);
				Ak(end+1) = 1;
				b(e) = im_s(y+1,x)-im_s(y,x);
			end
		end
	end
	% minimize (vi-tj - (si-sj))^2
	for y = miny+1:maxy-1
		for x = minx+1:maxx-1
			if mask_s(y,x)
				if mask_s(y-1,x) == 0
					e = e+1;
					Ai(end+1) = e;
					Aj(end+1) = im2var(y,x);
					Ak(end+1) = 1;
					b(e) = im_background(y-1,x)+im_s(y,x)-im_s(y-1,x);
				end
				if mask_s(y,x-1) == 0
					e = e+1;
					Ai(end+1) = e;
					Aj(end+1) = im2var(y,x);
					Ak(end+1) = 1;
					b(e) = im_background(y,x-1)+im_s(y,x)-im_s(y,x-1);
				end
				if mask_s(y+1,x) == 0
					e = e+1;
					Ai(end+1) = e;
					Aj(end+1) = im2var(y,x);
					Ak(end+1) = 1;
					b(e) = im_background(y+1,x)+im_s(y,x)-im_s(y+1,x);
				end
				if mask_s(y,x+1) == 0
					e = e+1;
					Ai(end+1) = e;
					Aj(end+1) = im2var(y,x);
					Ak(end+1) = 1;
					b(e) = im_background(y,x+1)+im_s(y,x)-im_s(y,x+1);
				end
			end
		end
	end
	A = sparse(Ai, Aj, Ak);
	v = A\b;
	res = sum((A * v - b) .^ 2);
end
