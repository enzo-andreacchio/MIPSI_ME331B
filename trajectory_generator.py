import os
import csv
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

STROKE_FONT = {
    "A": [[(0.05, 0.0), (0.5, 1.0), (0.95, 0.0)], [(0.25, 0.45), (0.75, 0.45)]],
    "B": [
        [(0.1, 0.0), (0.1, 1.0)],
        [(0.1, 1.0), (0.72, 0.92), (0.85, 0.72), (0.72, 0.55), (0.1, 0.5)],
        [(0.1, 0.5), (0.78, 0.45), (0.92, 0.2), (0.75, 0.03), (0.1, 0.0)],
    ],
    "C": [
        [
            (0.9, 0.85),
            (0.7, 1.0),
            (0.25, 0.95),
            (0.05, 0.72),
            (0.05, 0.28),
            (0.25, 0.05),
            (0.7, 0.0),
            (0.9, 0.15),
        ]
    ],
    "D": [
        [
            (0.1, 0.0),
            (0.1, 1.0),
            (0.65, 0.95),
            (0.9, 0.72),
            (0.9, 0.28),
            (0.65, 0.05),
            (0.1, 0.0),
        ]
    ],
    "E": [
        [(0.85, 1.0), (0.1, 1.0), (0.1, 0.0), (0.85, 0.0)],
        [(0.1, 0.5), (0.65, 0.5)],
    ],
    "F": [[(0.1, 0.0), (0.1, 1.0), (0.85, 1.0)], [(0.1, 0.5), (0.65, 0.5)]],
    "G": [
        [
            (0.9, 0.82),
            (0.7, 1.0),
            (0.25, 0.95),
            (0.05, 0.72),
            (0.05, 0.28),
            (0.25, 0.05),
            (0.72, 0.0),
            (0.9, 0.2),
            (0.9, 0.45),
            (0.55, 0.45),
        ]
    ],
    "H": [[(0.1, 0.0), (0.1, 1.0)], [(0.9, 0.0), (0.9, 1.0)], [(0.1, 0.5), (0.9, 0.5)]],
    "I": [[(0.2, 1.0), (0.8, 1.0)], [(0.5, 1.0), (0.5, 0.0)], [(0.2, 0.0), (0.8, 0.0)]],
    "J": [[(0.8, 1.0), (0.8, 0.2), (0.62, 0.0), (0.32, 0.0), (0.15, 0.18)]],
    "K": [[(0.1, 0.0), (0.1, 1.0)], [(0.9, 1.0), (0.1, 0.48), (0.9, 0.0)]],
    "L": [[(0.1, 1.0), (0.1, 0.0), (0.85, 0.0)]],
    "M": [[(0.08, 0.0), (0.08, 1.0), (0.5, 0.35), (0.92, 1.0), (0.92, 0.0)]],
    "N": [[(0.1, 0.0), (0.1, 1.0), (0.9, 0.0), (0.9, 1.0)]],
    "O": [
        [
            (0.5, 1.0),
            (0.85, 0.85),
            (0.95, 0.5),
            (0.85, 0.15),
            (0.5, 0.0),
            (0.15, 0.15),
            (0.05, 0.5),
            (0.15, 0.85),
            (0.5, 1.0),
        ]
    ],
    "P": [
        [
            (0.1, 0.0),
            (0.1, 1.0),
            (0.68, 1.0),
            (0.88, 0.82),
            (0.88, 0.62),
            (0.68, 0.5),
            (0.1, 0.5),
        ]
    ],
    "Q": [
        [
            (0.5, 1.0),
            (0.85, 0.85),
            (0.95, 0.5),
            (0.85, 0.15),
            (0.5, 0.0),
            (0.15, 0.15),
            (0.05, 0.5),
            (0.15, 0.85),
            (0.5, 1.0),
        ],
        [(0.62, 0.25), (0.95, -0.08)],
    ],
    "R": [
        [
            (0.1, 0.0),
            (0.1, 1.0),
            (0.68, 1.0),
            (0.88, 0.82),
            (0.88, 0.62),
            (0.68, 0.5),
            (0.1, 0.5),
        ],
        [(0.48, 0.5), (0.9, 0.0)],
    ],
    "S": [
        [
            (0.88, 0.85),
            (0.68, 1.0),
            (0.25, 0.95),
            (0.08, 0.75),
            (0.25, 0.55),
            (0.7, 0.45),
            (0.9, 0.25),
            (0.7, 0.03),
            (0.22, 0.0),
            (0.05, 0.16),
        ]
    ],
    "T": [[(0.05, 1.0), (0.95, 1.0)], [(0.5, 1.0), (0.5, 0.0)]],
    "U": [
        [(0.1, 1.0), (0.1, 0.25), (0.28, 0.02), (0.72, 0.02), (0.9, 0.25), (0.9, 1.0)]
    ],
    "V": [[(0.05, 1.0), (0.5, 0.0), (0.95, 1.0)]],
    "W": [[(0.05, 1.0), (0.25, 0.0), (0.5, 0.62), (0.75, 0.0), (0.95, 1.0)]],
    "X": [[(0.08, 1.0), (0.92, 0.0)], [(0.92, 1.0), (0.08, 0.0)]],
    "Y": [[(0.05, 1.0), (0.5, 0.52), (0.95, 1.0)], [(0.5, 0.52), (0.5, 0.0)]],
    "Z": [[(0.08, 1.0), (0.92, 1.0), (0.08, 0.0), (0.92, 0.0)]],
    "0": [
        [
            (0.5, 1.0),
            (0.85, 0.85),
            (0.95, 0.5),
            (0.85, 0.15),
            (0.5, 0.0),
            (0.15, 0.15),
            (0.05, 0.5),
            (0.15, 0.85),
            (0.5, 1.0),
        ]
    ],
    "1": [[(0.35, 0.8), (0.5, 1.0), (0.5, 0.0)], [(0.3, 0.0), (0.72, 0.0)]],
    "2": [
        [(0.12, 0.75), (0.35, 1.0), (0.78, 0.95), (0.9, 0.7), (0.08, 0.0), (0.9, 0.0)]
    ],
    "3": [
        [
            (0.12, 0.88),
            (0.78, 1.0),
            (0.9, 0.7),
            (0.58, 0.5),
            (0.9, 0.3),
            (0.78, 0.0),
            (0.12, 0.12),
        ]
    ],
    "4": [[(0.78, 0.0), (0.78, 1.0), (0.1, 0.35), (0.95, 0.35)]],
    "5": [
        [
            (0.88, 1.0),
            (0.18, 1.0),
            (0.1, 0.55),
            (0.68, 0.55),
            (0.9, 0.32),
            (0.75, 0.05),
            (0.15, 0.0),
        ]
    ],
    "6": [
        [
            (0.85, 0.85),
            (0.62, 1.0),
            (0.22, 0.85),
            (0.08, 0.45),
            (0.28, 0.05),
            (0.72, 0.05),
            (0.9, 0.28),
            (0.7, 0.52),
            (0.12, 0.5),
        ]
    ],
    "7": [[(0.08, 1.0), (0.92, 1.0), (0.38, 0.0)]],
    "8": [
        [
            (0.5, 0.52),
            (0.22, 0.62),
            (0.12, 0.85),
            (0.35, 1.0),
            (0.68, 0.95),
            (0.88, 0.72),
            (0.5, 0.52),
            (0.15, 0.3),
            (0.3, 0.05),
            (0.7, 0.02),
            (0.9, 0.25),
            (0.5, 0.52),
        ]
    ],
    "9": [
        [
            (0.85, 0.5),
            (0.28, 0.48),
            (0.1, 0.72),
            (0.3, 0.95),
            (0.72, 0.95),
            (0.9, 0.55),
            (0.78, 0.15),
            (0.55, 0.0),
        ]
    ],
}

GLYPH_WIDTHS = {" ": 0.55, ".": 0.3, "-": 0.6}


def build_single_line_text_strokes(text_input, glyph_spacing=0.35):
    """Return centerline strokes for a simple single-line plotting font."""
    strokes = []
    cursor_x = 0.0

    for char in text_input.upper():
        if char == " ":
            cursor_x += GLYPH_WIDTHS[" "] + glyph_spacing
            continue

        glyph = STROKE_FONT.get(char)
        if glyph is None:
            print(f"[!] Skipping unsupported single-line character: {char!r}")
            cursor_x += 1.0 + glyph_spacing
            continue

        for stroke in glyph:
            strokes.append([(cursor_x + x, y) for x, y in stroke])
        cursor_x += GLYPH_WIDTHS.get(char, 1.0) + glyph_spacing

    return strokes


def strokes_to_waypoints(strokes, travel_samples=12):
    """Convert strokes to waypoints, including pen-up transit between strokes."""
    raw_points = []
    last_point = None

    for stroke in strokes:
        if len(stroke) == 0:
            continue

        start = stroke[0]
        if last_point is None:
            raw_points.append((start[0], start[1], 0))
        else:
            raw_points.append((last_point[0], last_point[1], 0))
            for alpha in np.linspace(0.0, 1.0, travel_samples + 1)[1:]:
                x = last_point[0] + alpha * (start[0] - last_point[0])
                y = last_point[1] + alpha * (start[1] - last_point[1])
                raw_points.append((x, y, 0))

        raw_points.append((start[0], start[1], 1))
        for x, y in stroke[1:]:
            raw_points.append((x, y, 1))
        last_point = stroke[-1]

    return raw_points


def generate_robot_art(text_input, y_min, y_max, velocity=10.0, stroke_width=0.5):
    """
    Generates robot trajectory waypoints from text, scales them to workspace boundaries,
    and outputs both a tracking CSV and a 3D projection mesh (OBJ/MTL).
    """
    output_dir = "csv_files"
    os.makedirs(output_dir, exist_ok=True)

    # ---------------------------------------------------------
    # Step 1: Extract Single-Line Stroke Geometry from Text
    # ---------------------------------------------------------
    # Filled font outlines produce hollow letters. This stroke font defines each
    # character as one or more centerline paths that a plotting robot can follow.
    strokes = build_single_line_text_strokes(text_input)
    raw_points = strokes_to_waypoints(strokes)

    if not raw_points:
        raise ValueError(
            "No single-line path could be generated from the provided text."
        )

    # ---------------------------------------------------------
    # Step 2: Enforce Workspace Constraints & Handle Scaling
    # ---------------------------------------------------------
    all_x = [p[0] for p in raw_points]
    all_y = [p[1] for p in raw_points]

    min_x, max_x = min(all_x), max(all_x)
    min_y, max_y = min(all_y), max(all_y)

    source_y_range = max_y - min_y
    target_y_range = y_max - y_min
    scale_factor = target_y_range / (source_y_range if source_y_range != 0 else 1.0)

    # Transform coordinates: map y safely, scale x identically to maintain aspect ratio
    scaled_points = []
    for x, y, pd in raw_points:
        sx = (x - min_x) * scale_factor  # Starts x smoothly at 0
        sy = y_min + (y - min_y) * scale_factor
        scaled_points.append((sx, sy, pd))

    # ---------------------------------------------------------
    # Step 3: Compute Time Vectors (t) based on Linear Velocity
    # ---------------------------------------------------------
    trajectory = []
    t = 0.0
    # Establish baseline index
    trajectory.append(
        (t, scaled_points[0][0], scaled_points[0][1], scaled_points[0][2])
    )

    for i in range(1, len(scaled_points)):
        x0, y0, _ = scaled_points[i - 1]
        x1, y1, pd1 = scaled_points[i]

        distance = np.hypot(x1 - x0, y1 - y0)
        if distance > 1e-5:
            dt = distance / velocity
            t += dt
        trajectory.append((t, x1, y1, pd1))

    # ---------------------------------------------------------
    # Step 4: Export to CSV
    # ---------------------------------------------------------
    csv_path = os.path.join(output_dir, "robot_trajectory.csv")
    with open(csv_path, mode="w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["t", "x", "y", "penDown"])
        for row in trajectory:
            writer.writerow(
                [f"{row[0]:.4f}", f"{row[1]:.4f}", f"{row[2]:.4f}", int(row[3])]
            )

    print(f"[✔] Trajectory CSV written to: {csv_path}")

    # ---------------------------------------------------------
    # Step 5: Export OBJ & MTL Files (Flat Ribbon along exact paths)
    # ---------------------------------------------------------
    # Group points into active drawing strokes to build 3D mesh strips.
    # Pen-up transit stays in the CSV but is not rendered as ink in the OBJ.
    mesh_strokes = []
    current_stroke = []
    for pt in scaled_points:
        if pt[2] == 1:
            current_stroke.append((pt[0], pt[1]))
        else:
            if current_stroke:
                mesh_strokes.append(current_stroke)
                current_stroke = []
    if current_stroke:
        mesh_strokes.append(current_stroke)

    obj_vertices = []
    obj_faces = []
    v_idx = 1  # OBJ files are 1-indexed

    for stroke in mesh_strokes:
        n_pts = len(stroke)
        if n_pts < 2:
            continue

        # Calculate normals along the 2D path to extrude its physical width
        normals = []
        for i in range(n_pts):
            if i == 0:
                dx, dy = stroke[1][0] - stroke[0][0], stroke[1][1] - stroke[0][1]
            elif i == n_pts - 1:
                dx, dy = (
                    stroke[n_pts - 1][0] - stroke[n_pts - 2][0],
                    stroke[n_pts - 1][1] - stroke[n_pts - 2][1],
                )
            else:
                dx, dy = (
                    stroke[i + 1][0] - stroke[i - 1][0],
                    stroke[i + 1][1] - stroke[i - 1][1],
                )

            mag = np.hypot(dx, dy)
            nx, ny = (-dy / mag, dx / mag) if mag > 1e-8 else (1.0, 0.0)
            normals.append((nx, ny))

        stroke_v_start = v_idx
        for i in range(n_pts):
            x, y = stroke[i]
            nx, ny = normals[i]

            # Left and Right edges defining structural width at z=0 for sharp projection mapping
            obj_vertices.append(
                (x + nx * (stroke_width / 2.0), y + ny * (stroke_width / 2.0), 0.0)
            )
            obj_vertices.append(
                (x - nx * (stroke_width / 2.0), y - ny * (stroke_width / 2.0), 0.0)
            )
            v_idx += 2

        # Connect the generated edges into solid quad surfaces
        for i in range(n_pts - 1):
            l_i = stroke_v_start + 2 * i
            r_i = stroke_v_start + 2 * i + 1
            l_next = stroke_v_start + 2 * (i + 1)
            r_next = stroke_v_start + 2 * (i + 1) + 1

            obj_faces.append((r_i, r_next, l_next))
            obj_faces.append((r_i, l_next, l_i))

    obj_path = os.path.join(output_dir, "text_mesh.obj")
    mtl_path = os.path.join(output_dir, "text_material.mtl")

    # Opening with "w" intentionally overwrites old OBJ/MTL exports.
    with open(mtl_path, "w") as f:
        f.write("# Material definitions for text background overlay\n")
        f.write("newmtl NeonProjectionColor\n")
        f.write("Ka 0.0 0.5 1.0\n")  # Ambient cyan-blue highlight
        f.write("Kd 0.0 0.6 1.0\n")  # Diffuse
        f.write("Illum 1\n")

    with open(obj_path, "w") as f:
        f.write(f"mtllib text_material.mtl\n")
        for v in obj_vertices:
            f.write(f"v {v[0]:.4f} {v[1]:.4f} {v[2]:.4f}\n")
        f.write("usemtl NeonProjectionColor\n")
        for face in obj_faces:
            f.write(f"f {face[0]} {face[1]} {face[2]}\n")

    print(f"[✔] 3D Mesh OBJ written to: {obj_path}")

    # ---------------------------------------------------------
    # Step 6: Animated Real-Time Simulation Plotting
    # ---------------------------------------------------------
    fig, ax = plt.subplots(figsize=(12, 5))
    max_x_bound = max([p[0] for p in scaled_points])
    ax.set_xlim(-2, max_x_bound + 2)
    ax.set_ylim(y_min - 2, y_max + 2)
    ax.set_aspect("equal")
    ax.axhline(y_min, color="r", linestyle="--", alpha=0.5, label="yMin Constraint")
    ax.axhline(y_max, color="r", linestyle="--", alpha=0.5, label="yMax Constraint")

    # Process visual timeline arrays including NaN dividers to omit drawing lines when pen is raised
    vis_x, vis_y = [], []
    for i in range(len(trajectory)):
        _, x_val, y_val, pd_val = trajectory[i]
        if i > 0 and trajectory[i - 1][3] == 0 and pd_val == 1:
            vis_x.append(np.nan)
            vis_y.append(np.nan)

        if pd_val == 1:
            vis_x.append(x_val)
            vis_y.append(y_val)
        else:
            vis_x.append(np.nan)
            vis_y.append(np.nan)

    (line,) = ax.plot([], [], "b-", lw=2.5, label="Drawn Text Path")
    (pen_dot,) = ax.plot([], [], "ro", markersize=8, label="Robot Tool Head")
    ax.legend(loc="upper right")
    ax.set_xlabel("X Workspace (Unconstrained)")
    ax.set_ylabel("Y Workspace (Constrained)")

    # Downsample frame indices slightly to secure snappy playback rates for long text blocks
    step = max(1, len(trajectory) // 250)
    frame_indices = list(range(0, len(trajectory), step))
    if frame_indices[-1] != len(trajectory) - 1:
        frame_indices.append(len(trajectory) - 1)

    def update_frame(frame_idx):
        line.set_data(vis_x[: frame_idx + 1], vis_y[: frame_idx + 1])
        t_val, cur_x, cur_y, pd_val = trajectory[frame_idx]
        pen_dot.set_data([cur_x], [cur_y])
        pen_dot.set_color("green" if pd_val == 1 else "red")
        ax.set_title(
            f"Robot Drawing Tracking Simulation | Text: '{text_input}'\n"
            f"Time: {t_val:.2f}s | Pen Status: {'DOWN (Writing)' if pd_val == 1 else 'UP (Transit)'}"
        )
        return line, pen_dot

    ani = animation.FuncAnimation(
        fig, update_frame, frames=frame_indices, interval=25, blit=True, repeat=False
    )
    # plt.show()


if __name__ == "__main__":
    # --- Configurable Variables ---
    INPUT_STRING = "ME331B"
    Y_MIN_LIMIT = 0.4
    Y_MAX_LIMIT = 1.0
    FEED_RATE = 1  # Units per second velocity
    STROKE_WIDTH = 0.1  # Visual rendering width inside the OBJ file

    generate_robot_art(
        text_input=INPUT_STRING,
        y_min=Y_MIN_LIMIT,
        y_max=Y_MAX_LIMIT,
        velocity=FEED_RATE,
        stroke_width=STROKE_WIDTH,
    )
