#!/usr/bin/env python3
"""
Generate 1024x1024 PNG icons for Unperch app icon.
Produces two files:
  app_icon.png            — full icon (green circle bg + white figure)
  app_icon_foreground.png — foreground only (white figure on transparent)

Uses only Python stdlib (struct, zlib, math). No PIL required.
"""

import struct
import zlib
import math
import os

SIZE = 1024

# ── PNG writer ──────────────────────────────────────────────────────────────

def _chunk(tag: bytes, data: bytes) -> bytes:
    length = struct.pack(">I", len(data))
    crc = struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
    return length + tag + data + crc

def write_png(path: str, pixels: list[list[tuple[int, int, int, int]]]) -> None:
    """Write an RGBA PNG from a list-of-rows of (R,G,B,A) tuples."""
    h = len(pixels)
    w = len(pixels[0])

    raw_rows = []
    for row in pixels:
        row_bytes = bytearray([0])  # filter type None
        for r, g, b, a in row:
            row_bytes += bytes([r, g, b, a])
        raw_rows.append(bytes(row_bytes))

    raw = b"".join(raw_rows)
    compressed = zlib.compress(raw, 9)

    ihdr_data = struct.pack(">IIBBBBB", w, h, 8, 2 | 4, 0, 0, 0)  # 8-bit RGBA
    # correct IHDR: width(4) height(4) bitdepth(1) colortype(1=RGBA=6) compress(1) filter(1) interlace(1)
    ihdr_data = struct.pack(">II", w, h) + bytes([8, 6, 0, 0, 0])

    sig = b"\x89PNG\r\n\x1a\n"
    png = (
        sig
        + _chunk(b"IHDR", ihdr_data)
        + _chunk(b"IDAT", compressed)
        + _chunk(b"IEND", b"")
    )
    with open(path, "wb") as f:
        f.write(png)
    print(f"  wrote {path}  ({os.path.getsize(path):,} bytes)")

# ── Drawing primitives ───────────────────────────────────────────────────────

def filled_circle(cx, cy, r, pixels, color):
    """Fill a circle at (cx,cy) with radius r."""
    r2 = r * r
    for y in range(max(0, cy - r - 1), min(SIZE, cy + r + 2)):
        for x in range(max(0, cx - r - 1), min(SIZE, cx + r + 2)):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r2:
                pixels[y][x] = color

def aa_circle(cx, cy, r, pixels, color, thickness=1):
    """Draw an anti-aliased filled circle (solid disc)."""
    filled_circle(cx, cy, r, pixels, color)

def filled_rect(x0, y0, x1, y1, pixels, color):
    for y in range(max(0, y0), min(SIZE, y1)):
        for x in range(max(0, x0), min(SIZE, x1)):
            pixels[y][x] = color

def draw_thick_line(x0, y0, x1, y1, pixels, color, thickness=12):
    """Draw a thick anti-aliased line using Bresenham + perpendicular fill."""
    dx, dy = x1 - x0, y1 - y0
    length = math.hypot(dx, dy)
    if length == 0:
        return
    # perpendicular unit vector
    px, py = -dy / length, dx / length
    half = thickness / 2.0
    steps = max(abs(dx), abs(dy), 1) * 2
    for i in range(steps + 1):
        t = i / steps
        cx = x0 + dx * t
        cy = y0 + dy * t
        for j in range(-int(half) - 1, int(half) + 2):
            nx = int(round(cx + px * j))
            ny = int(round(cy + py * j))
            if 0 <= nx < SIZE and 0 <= ny < SIZE:
                dist = abs(j) - half
                if dist < 0:
                    pixels[ny][nx] = color
                elif dist < 1.0:
                    # blend
                    alpha = int((1.0 - dist) * color[3])
                    if alpha > pixels[ny][nx][3]:
                        pixels[ny][nx] = (color[0], color[1], color[2], alpha)

# ── Figure drawing ──────────────────────────────────────────────────────────
# The icon depicts a stick figure STANDING UP from a chair:
#   • Head (circle)
#   • Body (vertical line, slightly angled forward — "rising")
#   • One arm raised up (triumphant)
#   • One arm pushing off chair
#   • Legs — one extended down (standing), one bent (pushing off seat)
#   • A simple chair silhouette behind/below

def draw_figure(pixels, color):
    W = SIZE
    # Scale factor — figure occupies ~60% of canvas height, centred slightly upper-half
    # All coordinates in a 0-100 unit grid, scaled to SIZE
    def sc(v):
        return int(v / 100 * W)

    T = sc  # alias

    lw = max(8, SIZE // 96)  # line width ~10px at 1024

    # --- Chair (draw first so figure appears in front) ---
    chair_color = (200, 230, 200, 220)  # light green tint so it reads as background

    # Seat (horizontal bar)
    draw_thick_line(T(25), T(68), T(65), T(68), pixels, chair_color, lw)
    # Back rest (vertical bar on left)
    draw_thick_line(T(25), T(45), T(25), T(68), pixels, chair_color, lw)
    # Chair legs
    draw_thick_line(T(27), T(68), T(24), T(88), pixels, chair_color, lw - 2)
    draw_thick_line(T(63), T(68), T(60), T(88), pixels, chair_color, lw - 2)

    # --- Stick figure ---
    # Head
    filled_circle(T(57), T(22), sc(6), pixels, color)

    # Body — angled forward/upward (rising from seat)
    draw_thick_line(T(57), T(28), T(52), T(55), pixels, color, lw)

    # Right arm — raised high (triumph / standing up)
    draw_thick_line(T(54), T(35), T(68), T(20), pixels, color, lw)
    # hand dot
    filled_circle(T(68), T(20), sc(3), pixels, color)

    # Left arm — pushing off chair arm/seat
    draw_thick_line(T(55), T(37), T(38), T(52), pixels, color, lw)
    # hand on seat
    filled_circle(T(38), T(52), sc(3), pixels, color)

    # Right leg — extended downward (foot on floor, standing)
    draw_thick_line(T(52), T(55), T(58), T(75), pixels, color, lw)  # thigh
    draw_thick_line(T(58), T(75), T(55), T(90), pixels, color, lw)  # shin
    filled_circle(T(55), T(91), sc(3), pixels, color)               # foot

    # Left leg — bent, just leaving seat
    draw_thick_line(T(52), T(55), T(42), T(70), pixels, color, lw)  # thigh angled left
    draw_thick_line(T(42), T(70), T(45), T(84), pixels, color, lw)  # shin
    filled_circle(T(45), T(85), sc(3), pixels, color)               # foot

# ── Main ─────────────────────────────────────────────────────────────────────

def blank_pixels(bg=(0, 0, 0, 0)):
    return [[bg] * SIZE for _ in range(SIZE)]

BG_GREEN = (0x1B, 0x5E, 0x20, 255)
WHITE    = (255, 255, 255, 255)

script_dir = os.path.dirname(os.path.abspath(__file__))

print("Generating app_icon.png (full icon)…")
pixels_full = blank_pixels((0, 0, 0, 0))
# Green circle background
filled_circle(SIZE // 2, SIZE // 2, SIZE // 2 - 4, pixels_full, BG_GREEN)
draw_figure(pixels_full, WHITE)
write_png(os.path.join(script_dir, "app_icon.png"), pixels_full)

print("Generating app_icon_foreground.png (foreground for adaptive icon)…")
pixels_fg = blank_pixels((0, 0, 0, 0))
draw_figure(pixels_fg, WHITE)
write_png(os.path.join(script_dir, "app_icon_foreground.png"), pixels_fg)

print("Done.")
