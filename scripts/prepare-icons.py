import base64, json, pathlib, subprocess
root = pathlib.Path('build/Assets.xcassets/AppIcon.appiconset')
root.mkdir(parents=True, exist_ok=True)
source = pathlib.Path('build/icon-source.png')
source.write_bytes(base64.b64decode(pathlib.Path('ios/AppIcon.png.base64').read_text()))
images = []
for idiom, specs in [('iphone', [(20,2),(20,3),(29,2),(29,3),(40,2),(40,3),(60,2),(60,3)]), ('ipad', [(20,1),(20,2),(29,1),(29,2),(40,1),(40,2),(76,1),(76,2),(83.5,2)]), ('ios-marketing', [(1024,1)])]:
    for size, scale in specs:
        pixels = int(size*scale)
        name = f'icon-{pixels}.png'
        if not (root/name).exists():
            subprocess.run(['sips','-z',str(pixels),str(pixels),str(source),'--out',str(root/name)], check=True)
        images.append(dict(idiom=idiom, size=f'{size}x{size}', scale=f'{scale}x', filename=name))
(root/'Contents.json').write_text(json.dumps(dict(images=images,info=dict(version=1,author='xcode'))))

