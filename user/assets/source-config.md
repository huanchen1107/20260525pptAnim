# Source Configuration

## Video Source
- **YouTube URL:** https://www.youtube.com/watch?v=MqwmP4CJnSE&t=16s
- **Direct MP4 URL:** https://rr1---sn-ipoxu-umbe7.googlevideo.com/videoplayback?expire=1779541257&ei=qVARavaFFdqzms0Pl6KUuAU&ip=211.75.77.23&id=o-AOHf64itJuHvuLzA2PepoN5xi_kckJAH5xUQIRNdUABM&itag=18&source=youtube&requiressl=yes&xpc=EgVo2aDSNQ%3D%3D&cps=164&met=1779519657%2C&mh=ZN&mm=31%2C29&mn=sn-ipoxu-umbe7%2Csn-un57snee&ms=au%2Crdu&mv=m&mvi=1&pl=22&rms=au%2Cau&initcwndbps=2426250&bui=AbKmrwon7VUhOR1je2C4giU7Dv-VlQ2jfXnK8RDZ6386SL_JUmGbBWlxdsJNIGw-P7TBeus6dYdOQOOf&spc=96Xrv7MJsK3UiB8IK7hDsbAbMJU3MQNAnCeLl1fl-GxtRCl6kVHEfobBrvpY2ATSTJTEMWvS&vprv=1&svpuc=1&mime=video%2Fmp4&ns=c-x7UKJaNUmbfeXkqU6CrOIV&rqh=1&gir=yes&clen=7816285&ratebypass=yes&dur=434.631&lmt=1775713206702938&mt=1779519177&fvip=3&fexp=51565116%2C51565681&c=WEB&sefc=1&txp=6209224&n=sX-lpgyhcvV2t3Kto4&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cxpc%2Cbui%2Cspc%2Cvprv%2Csvpuc%2Cmime%2Cns%2Crqh%2Cgir%2Cclen%2Cratebypass%2Cdur%2Clmt&sig=AHEqNM4wRgIhAKv-L3XBJc_603yHLxV9kpHTLo8GcuUCAMs1XUFcbg-1AiEAwWX4u2VG2KYRwYJFpA5Yx7rXzzfmwt98cNuq0o7kxuM%3D&lsparams=cps%2Cmet%2Cmh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Crms%2Cinitcwndbps&lsig=APaTxxMwRgIhAOZC-_R4gEAly1KsNeij2taX7qN14NDDEK9_JoRjrDy5AiEAwYqwaF2ozbCDG5Gn06HUMapUG-AY-e14tsec50j0x-k%3D
- **Local file:** ./original_video.mp4

## Subtitle
- **File:** ./A2Zsrt.srt

## Tools

The following tools can be used to retrieve and manage the video asset.

### yt-dlp
A command‑line downloader for YouTube and many other platforms.
```bash
yt-dlp -f best -o "./original_video.mp4" "https://www.youtube.com/watch?v=MqwmP4CJnSE&t=16s"
```

### curl
Standard HTTP client for downloading files.
```bash
curl -L -o "./original_video.mp4" "https://rr1---sn-ipoxu-umbe7.googlevideo.com/videoplayback?expire=1779541257&ei=qVARavaFFdqzms0Pl6KUuAU&ip=211.75.77.23&id=o-AOHf64itJuHvuLzA2PepoN5xi_kckJAH5xUQIRNdUABM&itag=18&source=youtube&requiressl=yes&xpc=EgVo2aDSNQ%3D%3D&cps=164&met=1779519657%2C&mh=ZN&mm=31%2C29&mn=sn-ipoxu-umbe7%2Csn-un57snee&ms=au%2Crdu&mv=m&mvi=1&pl=22&rms=au%2Cau&initcwndbps=2426250&bui=AbKmrwon7VUhOR1je2C4giU7Dv-VlQ2jfXnK8RDZ6386SL_JUmGbBWlxdsJNIGw-P7TBeus6dYdOQOOf&spc=96Xrv7MJsK3UiB8IK7hDsbAbMJU3MQNAnCeLl1fl-GxtRCl6kVHEfobBrvpY2ATSTJTEMWvS&vprv=1&svpuc=1&mime=video%2Fmp4&ns=c-x7UKJaNUmbfeXkqU6CrOIV&rqh=1&gir=yes&clen=7816285&ratebypass=yes&dur=434.631&lmt=1775713206702938&mt=1779519177&fvip=3&fexp=51565116%2C51565681&c=WEB&sefc=1&txp=6209224&n=sX-lpgyhcvV2t3Kto4&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cxpc%2Cbui%2Cspc%2Cvprv%2Csvpuc%2Cmime%2Cns%2Crqh%2Cgir%2Cclen%2Cratebypass%2Cdur%2Clmt&sig=AHEqNM4wRgIhAKv-L3XBJc_603yHLxV9kpHTLo8GcuUCAMs1XUFcbg-1AiEAwWX4u2VG2KYRwYJFpA5Yx7rXzzfmwt98cNuq0o7kxuM%3D&lsparams=cps%2Cmet%2Cmh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Crms%2Cinitcwndbps&lsig=APaTxxMwRgIhAOZC-_R4gEAly1KsNeij2taX7qN14NDDEK9_JoRjrDy5AiEAwYqwaF2ozbCDG5Gn06HUMapUG-AY-e14tsec50j0x-k%3D"
```

### ffmpeg (alternative)
Multimedia framework for processing video streams.
```bash
ffmpeg -i "https://rr1---sn-ipoxu-umbe7.googlevideo.com/videoplayback?expire=1779541257&ei=qVARavaFFdqzms0Pl6KUuAU&ip=211.75.77.23&id=o-AOHf64itJuHvuLzA2PepoN5xi_kckJAH5xUQIRNdUABM&itag=18&source=youtube&requiressl=yes&xpc=EgVo2aDSNQ%3D%3D&cps=164&met=1779519657%2C&mh=ZN&mm=31%2C29&mn=sn-ipoxu-umbe7%2Csn-un57snee&ms=au%2Crdu&mv=m&mvi=1&pl=22&rms=au%2Cau&initcwndbps=2426250&bui=AbKmrwon7VUhOR1je2C4giU7Dv-VlQ2jfXnK8RDZ6386SL_JUmGbBWlxdsJNIGw-P7TBeus6dYdOQOOf&spc=96Xrv7MJsK3UiB8IK7hDsbAbMJU3MQNAnCeLl1fl-GxtRCl6kVHEfobBrvpY2ATSTJTEMWvS&vprv=1&svpuc=1&mime=video%2Fmp4&ns=c-x7UKJaNUmbfeXkqU6CrOIV&rq=somePlaceholder" -c copy "./original_video.mp4"
```

These commands should be run from the `user/assets` directory.
## Audio‑Slide Split

The `split_pages.sh` script generates per‑slide assets.

```bash
bash split_pages.sh
```

Outputs are placed in `user/assets/slide‑N/` folders as described in the README.
