from PIL import Image
img = Image.open('frame_0.png')
pixels = list(img.getdata())
avg_r = sum(p[0] for p in pixels) / len(pixels)
avg_g = sum(p[1] for p in pixels) / len(pixels)
avg_b = sum(p[2] for p in pixels) / len(pixels)
print(f"Frame 0s average color: {avg_r:.1f}, {avg_g:.1f}, {avg_b:.1f}")
