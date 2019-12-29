l = sym('l');
ssx = sym('ssx');
sdx = sym('sdx');
dt = sym('dt');
dx = sym('dx');
dy = sym('dy');

r = l * sdx / (ssx - sdx)
a = (ssx - sdx) / l


r = sym('r')
a = sym('a')

stato = [cos(dt), sin(dt),dx;
    -sin(dt), cos(dt), dy;
    0, 0, 1];

stepr = [1 0 0; 0, 1, -r-l/2; 0 0 1] * [ cos(a) sin(a) 0;
    -sin(a) cos(a) 0; 0 0 1] * [1 0 0; 0, 1, r+l/2;0 0 1]

stepf = [1 0 ssx; 0 1 0; 0 0 1]