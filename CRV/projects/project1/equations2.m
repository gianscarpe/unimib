f = sym('f');
h = sym('h');
xp = sym('xp');
yp = sym('yp');
xr = sym('xr');
yr = sym('yr');
theta = sym('theta');
dx = sym('dx');
dy = sym('dy');
d = sym('d');

p1 = [0; 0; 0; 1];
p2 = [d; 0; 0; 1];

roto = [cos(theta), sin(theta),0, dx;
    -sin(theta), cos(theta), 0, dy;
    0, 0, 0, 0;
    0, 0, 0, 1];


camera = 1 / h * [f, 0, 0, 0; 0, f, 0, 0; 0, 0, 1, 0] * [1, 0, 0, 0; 0, -1, 0, 0; 
    0, 0, -1, h; 0, 0, 0, 1];

pixel_point1 = camera * roto * p1
pixel_point2 = camera * roto * p2