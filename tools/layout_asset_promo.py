"""Lay out actual Blender renders into a labeled advertising sheet and cards."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json
P=Path(__file__).resolve().parents[1]/'assets'/'promo'
BG='#0b1018'; PANEL='#151e2a'; WHITE='#f0f3f5'; MUTED='#a8b5c7'; YELLOW='#edce38'
def font(size,bold=False):return ImageFont.truetype('C:/Windows/Fonts/'+('arialbd.ttf' if bold else 'arial.ttf'),size)
entries=[('arena','MODULAR ARENA STAGE','Venue structure, platforms & stage props'),
 ('event','EVENT STAGE SETUP','Stage, screen panels & lighting'),
 ('speakers','RAVESPACE SPEAKERS','Straight arrays, curved arrays, horns & subs'),
 ('truss','TRUSS & LINE ARRAY','Support towers, straight sections & circular truss'),
 ('devices','SOUND, LIGHTING & PROJECTION','Fixtures, speakers, control desks & stage'),
 ('mixer','MUSIC MIXTABLE','Twin decks & mixer controls')]
def render_into(canvas,key,box):
 im=Image.open(P/(key+'.png')).convert('RGBA')
 bbox=im.getchannel('A').getbbox()
 if bbox:im=im.crop(bbox)
 x,y,w,h=box;im.thumbnail((w,h),Image.Resampling.LANCZOS)
 canvas.paste(im,(x+(w-im.width)//2,y+(h-im.height)//2),im)
def card(key,title,sub,w=1200,h=825):
 c=Image.new('RGB',(w,h),PANEL);d=ImageDraw.Draw(c)
 d.rectangle((36,38,94,44),fill=YELLOW)
 d.text((36,65),title,font=font(37,True),fill=WHITE)
 d.text((36,117),sub,font=font(25),fill=MUTED)
 render_into(c,key,(35,180,w-70,h-215))
 return c
poster=Image.new('RGB',(3840,2240),BG);d=ImageDraw.Draw(poster)
d.text((72,40),'EVENT DJ',font=font(112,True),fill=WHITE)
d.text((77,172),'ARMA 3  /  STAGES • SOUND • LIGHTING',font=font(32),fill=MUTED)
d.rounded_rectangle((2835,67,3768,143),radius=8,fill=YELLOW)
d.text((2870,84),'DEVELOPMENT ASSET PREVIEW',font=font(38,True),fill=BG)
for i,(key,title,sub) in enumerate(entries):
 c=card(key,title,sub)
 poster.paste(c,(72+(i%3)*1248,280+(i//3)*873))
 solo=Image.new('RGB',(1920,1280),BG)
 solo.paste(c.resize((1800,1238),Image.Resampling.LANCZOS),(60,21))
 solo.save(P/(key+'_preview_card.png'))
d.rectangle((72,2040,3768,2042),fill='#344255')
d.text((76,2070),'COMING SOON',font=font(31,True),fill=YELLOW)
d.text((385,2065),'DJ PLAYER',font=font(43,True),fill=WHITE)
d.text((77,2160),'Source-model renders • In development • Final in-game appearance may differ',font=font(27),fill=MUTED)
poster.save(P/'event_dj_asset_showcase_3840.png')
poster.save(P/'event_dj_asset_showcase_3840.jpg',quality=94,subsampling=0)
poster.resize((1920,1120),Image.Resampling.LANCZOS).save(P/'event_dj_asset_showcase_1920.jpg',quality=92)
reports={k:json.loads((P/(k+'_report.json')).read_text()) for k,_,_ in entries}
(P/'render_manifest.json').write_text(json.dumps(reports,indent=2))
print('Created showcase PNG/JPG, sharing JPG, and six individual preview cards')
