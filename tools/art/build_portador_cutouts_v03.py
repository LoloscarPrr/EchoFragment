#!/usr/bin/env python3
"""EchoFragment 0.3: alpha-masked anatomical pieces, no Sprite2D rectangles.
Converts the nine existing original 1024px art sources OR the currently checked
in Canva previews to 22 distinct transparent PNGs. Each output preserves the
original canvas origin, making the same pivots work in either resolution.
This is a mechanically useful cutout, NOT inpainted final concealed surfaces.
"""
import argparse
from pathlib import Path
from PIL import Image
import numpy as np

SOURCE={
 'head_helmet':'portador_head_helmet.png',
 'torso_upper':'portador_torso_upper.png',
 'pelvis_waist':'portador_pelvis_waist.png',
 'sword':'portador_sword.png',
 'cape':'portador_cape.png',
 'arm_R':'portador_arm_R.png',
 'arm_L':'portador_arm_L.png',
 'leg_R':'portador_leg_R.png',
 'leg_L':'portador_leg_L.png',
}

def smooth(t):
    t=np.clip(t,0,1)
    return t*t*(3-2*t)

def left(t,split,width):
    return 1-smooth((t-split+width*.5)/width)

def right(t,split,width):
    return smooth((t-split+width*.5)/width)

def ellipse(xx,yy,x,y,rx,ry):
    return 1-smooth((np.sqrt(((xx-x)/rx)**2+((yy-y)/ry)**2)-0.72)/0.28)

def main(src:Path,dest:Path):
    dest.mkdir(parents=True,exist_ok=True)
    count=0
    for key,file in SOURCE.items():
        im=Image.open(src/file).convert('RGBA')
        a=np.asarray(im,np.uint8)
        h,w=a.shape[:2]
        native_h=1024 if key in ('head_helmet','torso_upper','pelvis_waist') else 1536
        y=np.arange(h,dtype=np.float32)[:,None]*(native_h/h)
        x=np.arange(w,dtype=np.float32)[None,:]*(1024/w)
        masks={}
        if key in ('head_helmet','torso_upper','pelvis_waist','sword'):
            masks[key]=1.
        elif key=='cape':
            split=510+(y-760)*.16
            masks['cape_main']=right(x,split,155)
            masks['cape_tip']=left(x,split,155)
        elif key.startswith('arm_'):
            side=key[-1]
            e=655+(x-500)*.12
            wrist=1110+(x-530)*.05
            masks[f'arm_{side}_upper']=left(y,e,100)
            masks[f'arm_{side}_forearm']=right(y,e,100)*left(y,wrist,105)
            masks[f'hand_{side}']=right(y,wrist,105)
            ex,ey=(410,665) if side=='R' else (570,650)
            masks[f'arm_{side}_elbow_guard']=ellipse(x,y,ex,ey,145,150)
        elif key.startswith('leg_'):
            side=key[-1]
            knee=690+(x-500)*.08
            ankle=1170+(x-580)*.05
            masks[f'leg_{side}_thigh']=left(y,knee,110)
            masks[f'leg_{side}_shin']=right(y,knee,110)*left(y,ankle,110)
            masks[f'foot_{side}']=right(y,ankle,110)
            kx,ky=(540,700) if side=='R' else (550,700)
            masks[f'leg_{side}_knee_guard']=ellipse(x,y,kx,ky,160,140)
        for name,mask in masks.items():
            rendered=a.copy()
            if not np.isscalar(mask):
                rendered[:,:,3]=np.clip(np.rint(a[:,:,3].astype(np.float32)*mask),0,255).astype(np.uint8)
            if (rendered[:,:,3]>10).sum()<15:raise RuntimeError(f'No visible art: {name}')
            img=Image.fromarray(rendered,'RGBA')
            img.save(dest / f'portador_{name}.png',optimize=True)
            print('ART',name,img.size)
            count+=1
    print('READY',count,'independent RGBA piece textures')
    assert count==22

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--source',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args()
    main(a.source,a.out)
