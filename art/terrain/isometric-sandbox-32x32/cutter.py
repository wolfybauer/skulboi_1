from PIL import Image

WIDTH = 32
HEIGHT = 32

im = Image.open('isometric-sandbox-sheet.png')
sheet_w,sheet_h = im.size

cols = sheet_w/32
rows = sheet_h/32

print(f'cols: {cols}')
print(f'rows: {rows}')

counter = 0

for row in range(int(rows)):
    for col in range(int(cols)):
        # print(col, row)
        print(f'({col*32},{row*32})')
        x1 = col*WIDTH
        y1 = row*HEIGHT
        x2 = x1+WIDTH
        y2 = y1+HEIGHT
        im_out = im.crop((x1,y1,x2,y2))
        im_out.save(f'out/{counter}.png')
        counter += 1