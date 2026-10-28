#!/usr/bin/env python3
"""Source-aligned static QA assembly. This does NOT substitute game testing.
Renders all 22 individual v0.3 sprite cutouts at the neutral rig pivot layout.
"""
from pathlib import Path
from PIL import Image,ImageDraw

ROOT=Path('assets/player/portador_rig2d/v03')
OUT=Path('docs/animation/rig_v03_assembled_qa.png')
origin=(545,500)
# (part, root-relative bone x/y, natural image pivot, native visual scale, z index)
items=[
('cape_main',(-28,-128),(870,255),.225,-30),
('cape_tip',(-111,-6),(510,810),.225,-29),
('leg_L_thigh',(-57,14),(420,175),.22,-21),
('leg_L_shin',(-28,129),(550,700),.22,-20),
('leg_L_knee_guard',(-28,129),(550,700),.22,-19),
('foot_L',(-10,233),(635,1170),.22,-18),
('torso_upper',(0,-2),(512,750),.305,0),
('arm_L_upper',(-72,-113),(440,215),.172,2),
('arm_L_forearm',(-48,-37),(570,650),.172,3),
('arm_L_elbow_guard',(-48,-37),(570,650),.172,4),
('hand_L',(-43,39),(600,1100),.172,5),
('head_helmet',(0,-151),(545,870),.175,6),
('leg_R_thigh',(42,14),(430,175),.22,7),
('leg_R_shin',(66,129),(540,700),.22,8),
('leg_R_knee_guard',(66,129),(540,700),.22,9),
('foot_R',(80,232),(605,1170),.22,10),
('pelvis_waist',(0,0),(512,265),.285,11),
('arm_R_upper',(72,-113),(525,230),.172,12),
('arm_R_forearm',(52,-39),(410,665),.172,13),
('arm_R_elbow_guard',(52,-39),(410,665),.172,14),
('hand_R',(83,39),(590,1125),.172,15),
('sword',(99,74),(855,240),.125,16)
]
canvas=Image.new('RGBA',(1100,950),(20,23,31,255))
D=ImageDraw.Draw(canvas)
D.rectangle((0,0,1099,140),fill=(15,17,24,255))
D.text((40,32),'ECHOFRAGMENT  /  PORTADOR DEL ECO',fill=(235,210,215))
D.text((40,68),'RIG 2D 0.3  |  22 PIEZAS REALES / VISTA NEUTRAL',fill=(220,128,142))
D.line((160,820,925,820),fill=(114,65,78),width=2)
for name,xy,pivot,scale,z in sorted(items,key=lambda a:a[-1]):
    p=ROOT/('portador_'+name+'.png')
    img=Image.open(p).convert('RGBA')
    original_w=1024.
    original_h=1024. if name in ('head_helmet','torso_upper','pelvis_waist') else 1536.
    ratio_x=scale*original_w/img.width
    ratio_y=scale*original_h/img.height
    img=img.resize((max(1,round(img.width*ratio_x)), max(1,round(img.height*ratio_y))),Image.Resampling.LANCZOS)
    dest=(round(origin[0]+xy[0]-pivot[0]*scale),round(origin[1]+xy[1]-pivot[1]*scale))
    canvas.alpha_composite(img,dest)
OUT.parent.mkdir(parents=True,exist_ok=True)
canvas.convert('RGB').save(OUT,optimize=True)
print('Saved assembled neutral preview',OUT)
