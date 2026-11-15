"""Mobile release art, rendered locally: no browser, web fonts or external page."""
import argparse
import datetime as dt
import os
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]


def font(size, mono=False, bold=False):
    name = 'DMMono-Medium.ttf' if mono else 'DMSans-SemiBold.ttf' if bold else 'DMSans-Regular.ttf'
    return ImageFont.truetype(str(ROOT / 'assets/fonts' / name), size)


def render(version, channel, output, hero=False):
    if channel not in ('stable', 'nightly'): raise ValueError('Unknown banner channel')
    accent = '#65e2ce' if channel == 'stable' else '#ffa58d'
    w, h = 1600, 620 if hero else 400
    image = Image.new('RGB', (w,h), '#0b1318')
    glow = Image.new('RGB',(w,h),'#0b1318'); gd=ImageDraw.Draw(glow)
    gd.ellipse((920,-340,1850,570),fill='#163f43' if channel=='stable' else '#492f36')
    gd.ellipse((-260,220,500,980),fill='#142737')
    image = Image.blend(image, glow.filter(ImageFilter.GaussianBlur(85)), .8)
    d=ImageDraw.Draw(image)
    for x in range(840,w,40): d.line((x,0,x,h),fill='#193036',width=1)
    for y in range(0,h,40): d.line((840,y,w,y),fill='#193036',width=1)
    icon=Image.open(ROOT/'assets/branding/lokal_icon.png').convert('RGBA');icon.thumbnail((62,62))
    image.paste(icon,(70,45),icon)
    d.text((150,54),'LOKAL / MOBILE',font=font(25,mono=True),fill='#f0f7f7')
    pill='ANDROID  /  1.0' if hero else ('STABLE RELEASE' if channel=='stable' else 'NIGHTLY BUILD')
    box=d.textbbox((0,0),pill,font=font(16,mono=True)); pw=box[2]+42
    d.rounded_rectangle((w-pw-65,48,w-65,89),radius=21,outline=accent,width=1,fill='#102126')
    d.text((w-pw-44,58),pill,font=font(16,mono=True),fill=accent)
    if hero:
        d.text((70,180),'Your music.',font=font(86,bold=True),fill='#f3f7f8')
        d.text((70,273),'Everywhere you go.',font=font(76,bold=True),fill=accent)
        d.text((75,400),'Your files. Synced lyrics. A little more soul.',font=font(28),fill='#a9bcc2')
        d.text((75,529),'LOCAL FIRST  /  ANDROID  /  OPEN SOURCE',font=font(18,mono=True),fill='#a9bcc2')
    else:
        main,sep,suffix=version.removeprefix('v').partition('-')
        d.text((70,135),f'v{main}',font=font(86,mono=True),fill='#f4f7f8')
        if sep: d.text((73,243),suffix,font=font(25,mono=True),fill=accent)
        date=dt.date.today().isoformat()
        d.text((74,335),f'ANDROID  /  ARM64 + ARMv7  /  {date}',font=font(18,mono=True),fill='#9bb1ba')
    # Audio waveform shared by README and release art; mobile keeps teal/coral.
    left, right = (1130, 1515) if hero else (960, 1515)
    center = 350 if hero else 240
    amplitude = 150 if hero else 85
    count = 43
    for i in range(count):
        phase = i / (count - 1)
        envelope = math.sin(math.pi * phase) ** .7
        pulse = .24 + .76 * abs(math.sin(i * .71) * math.cos(i * .23))
        height = 8 + amplitude * envelope * pulse
        x = left + (right - left) * phase
        d.rounded_rectangle((x, center - height, x + 5, center + height),
                            radius=3, fill=accent)
    Path(output).parent.mkdir(parents=True,exist_ok=True)
    image.save(output,optimize=True)


def demo_covers(folder):
    folder=Path(folder);folder.mkdir(parents=True,exist_ok=True)
    colors=['#287f7b','#d87963','#8072b7','#2e6f9b','#b28d48','#478b76']
    for i,color in enumerate(colors):
        im=Image.new('RGB',(600,600),color);d=ImageDraw.Draw(im)
        for j in range(9):
            x=65+j*30
            d.arc((x,60,x+430,530),90,270,fill='#12272e',width=15)
        d.text((35,440),['TIDELINE','AFTER HOURS','LILAC SKY','BLUE ROOM','SLOW LIGHT','SIDE STREETS'][i],font=font(38,bold=True),fill='#f3f6f4')
        d.text((38,505),'LOKAL / DEMO LIBRARY',font=font(17,mono=True),fill='#e3e8df')
        im.save(folder/f'{i}.png')


if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--output',default='release-banner.png')
    parser.add_argument('--hero',action='store_true')
    parser.add_argument('--demo-covers')
    args=parser.parse_args()
    if args.demo_covers: demo_covers(args.demo_covers)
    else: render(os.environ.get('BANNER_VERSION','1.0.0'),os.environ.get('BANNER_TYPE','stable'),args.output,args.hero)
