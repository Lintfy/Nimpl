import ../src/nimpl,math

var t,sins,coses,tans:seq[float] = @[]
var p:float

# make data

for i in countup(-1000,1000):
  p=float(i)/100
  t.add(p)          # @[-100.0, -99.9, -99.8...]
  sins.add(p.sin)   # @[sin(-100.0),sin(-99.9),sin(-99.8)....]
  coses.add(p.cos)  # @[cos(-100.0),cos(-99.9),cos(-99.8)....]
  tans.add(p.tan)   # @[tan(-100.0),tan(-99.9),tan(-99.8)....]

# ---

# preparing data

var sin:line
sin.name="SINE"        # line name
sin.xdata= t           # x value
sin.ydata= sins        # y value
sin.color= [30,50,200] # line color

var cos:line
cos.name="COSINE"
cos.xdata= t
cos.ydata= coses
cos.color= [230,50,30]

var tan:line= nlLine("TANGENT", t, tans, [150,230,150])
# ---

# configulation of nimpl
nlLineConf(
  floatValue=true, # <true> -> use float values | <false> -> use int values // default - true
  roundLevel=8     # rounding level of float values [ 1 -> PI=3.1 ] [ 4 -> PI=3.1416 ] {it adapted if floatValue==true} // default - 8
)

# Range to display of graph
nlSetLineRange(-10,10,-3,3)

# window size
nlSetSize(550,450)

# show graph
nlShowLine(sin,cos,tan)
