import os
import subprocess
from PIL import Image

def analyze_video_frames():
    video_path = 'user/assets/slides/slide-1/preview/slide-1.preview.mp4'
    if not os.path.exists(video_path):
        video_path = 'user/assets/slides/slide-1/slide-1.mp4'
        
    if not os.path.exists(video_path):
        print("Video file not found")
        return
        
    print(f"Analyzing frames for video: {video_path}")
    
    # Extract frames at 1s, 2s, 3s, 4s using ffmpeg
    for t in [1.0, 2.0, 3.0, 4.0]:
        out_img = f"temp_frame_{t}.png"
        cmd = [
            "ffmpeg", "-y", "-ss", str(t), "-i", video_path,
            "-frames:v", "1", out_img, "-loglevel", "error"
        ]
        subprocess.run(cmd)
        
        if os.path.exists(out_img):
            img = Image.open(out_img).convert('RGB')
            avg_color = [sum(x)/len(img.getdata()) for x in zip(*img.getdata())]
            print(f"Frame at {t}s average color: {avg_color}")
            os.remove(out_img)
        else:
            print(f"Failed to extract frame at {t}s")

if __name__ == "__main__":
    analyze_video_frames()
