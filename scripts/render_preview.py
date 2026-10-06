#!/usr/bin/env python3
"""Render docs/preview.png (four views of an STL) with OpenSCAD's own preview renderer.

    python3 scripts/render_preview.py stl/cessna_skymaster_default.stl docs/preview.png

Needs openscad, xvfb-run (for a virtual display on headless machines) and Pillow.
The STL is imported into a tiny helper .scad so the images need no CGAL render.
"""
import os
import shutil
import subprocess
import sys
import tempfile

from PIL import Image, ImageDraw

# name -> OpenSCAD --camera string "tx,ty,tz,rx,ry,rz,distance" (nose is +X)
VIEWS = {
    "Front three-quarter": "-22,0,0,63,0,35,290",
    "Top": "-22,0,0,0,0,0,490",
    "Front": "-22,0,0,90,0,90,320",
    "Side": "-22,0,0,90,0,0,260",
}
SIZE = (1100, 700)


def render(stl, camera, out, workdir):
    scad = os.path.join(workdir, "view.scad")
    with open(scad, "w") as fh:
        fh.write(f'import("{os.path.abspath(stl)}");\n')
    cmd = ["openscad", f"--imgsize={SIZE[0]},{SIZE[1]}", "--projection=p", f"--camera={camera}",
           "--colorscheme=Tomorrow", "-o", out, scad]
    if shutil.which("xvfb-run") and not os.environ.get("DISPLAY"):
        cmd = ["xvfb-run", "-a", "-s", "-screen 0 1600x1200x24"] + cmd
    subprocess.run(cmd, check=True, capture_output=True, timeout=300)


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    stl, out = sys.argv[1:]
    with tempfile.TemporaryDirectory() as work:
        tiles = []
        for name, camera in VIEWS.items():
            png = os.path.join(work, name.replace(" ", "_") + ".png")
            render(stl, camera, png, work)
            im = Image.open(png).convert("RGB")
            ImageDraw.Draw(im).text((14, 10), name, fill=(40, 40, 40))
            tiles.append(im)
        w, h = SIZE
        sheet = Image.new("RGB", (2 * w, 2 * h), (248, 248, 248))
        for i, im in enumerate(tiles):
            sheet.paste(im, ((i % 2) * w, (i // 2) * h))
        sheet = sheet.resize((sheet.width * 2 // 3, sheet.height * 2 // 3), Image.LANCZOS)
        sheet.save(out, optimize=True)
    print(f"wrote {out} ({os.path.getsize(out) // 1024} KB)")


if __name__ == "__main__":
    main()
