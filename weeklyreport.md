# Weekly Progress Report

## Overview
This week focused on implementing advanced fire physics with 16x12 animated fire blocks, adding a complete UI overlay (bottom toolbar, mouse cursor, pause indicator), resolving critical merge conflicts after a system crash, and fixing three bugs in fire/spread logic and canvas boundary enforcement. All changes pushed to GitHub.

---

## Completed This Week

### 2.1 Merge Conflict Resolution and Repository Sync
- Recovered from system freeze: rebased local Codex commit (`opt: fix fire piling on fuel`) onto remote HEAD (`fix: static cells + per-pixel Minecraft-style flicker`)
- Resolved 3 merge conflicts in `verilog/DE1_SoC_Computer.v`, preserving all fire physics improvements while incorporating the remote's static fire foundation
- Re-established GitHub authentication via PAT and pushed all commits to `origin/master`

### 2.2 Bug Fixes (3 items)
- **Fire free-fall not triggering**: S_CHFIRE_BOT_EV was returning S_NEXT_PIXEL immediately on solid material, never entering DIAG/SIDE spread states. Fixed the entire fire physics chain: bot → diag1 → diag2 → side1 → side2, each properly issuing M10K reads and falling though WT→EV state pairs.
- **Fire coverage priority**: Ensured fire only writes to MAT_EMPTY/MAT_SMOKE targets in all spread states. All blocked paths now burn in place (write own cell) rather than overwriting other materials.
- **Canvas boundary enforcement**: Added CANVAS_ROWS=200 parameter. Changed 4 GRID_HEIGHT boundary checks so particles stop at y=199 instead of falling into toolbar area (y=200..239).

### 2.3 Fire Block Visualization (16x12 animated flame)
- Implemented shift-register tracking for up to 16 concurrent fire blocks (fire_root_x[15:0], fire_root_y[15:0], fire_root_active[15:0])
- Flame Shape ROM: 48-entry (4 frames × 12 rows × 16-bit) precomputed flame patterns with narrowing tips for flicker effect
- Registration triggers from CA state machine when fire falls and lands on sand/wall/canvas bottom surface
- 16px horizontal overlap guard prevents duplicate fire block registration
- Automatic deactivation when brush writes non-fire material to root cell
- 2-row ember base (warm orange/red slow animation) + 10-row flame body (animated flicker)

### 2.4 Bottom Toolbar UI
- Visible toolbar at grid y=200..239 covering full 320px width
- 5 equal-width material slots (64px each): Wall/Gray, Water/Blue, Sand/Yellow, Fire/Red, Smoke/Gray
- Selected slot highlighted with white border based on brush_mat signal
- Non-selected slots have darker borders, with decorative highlight stripes

### 2.5 Mouse Cursor
- 3x3 diamond shape at HPS brush position (grid_read_x/y == brush_x/y)
- Bright center pixel with green cross-shaped ring (up/down/left/right neighbors)
- Rendered on top of all layers (fire blocks, toolbar, and grid)

### 2.6 Pause Indicator
- Two vertical white bars at grid ~(19-21, 14-25), controlled by hps_keys[0]
- Composit on top of everything when pause signal is active

### 2.7 Layered Rendering Pipeline
- Final color mapper with correct priority order: grid material → toolbar → fire blocks → cursor → pause indicator
- All implemented as combinatorial logic in VGA color mapper, no changes to vga_driver or scanout timing

---

## Potential Issues (to address next week)

1. **Fire block state machine complexity**: 16 blocks × 80000 cells/scan = ~1.28M comparison cycles per frame at 50 MHz. Fire block generate loop uses 16 iterations with $signed comparisons; synthesis may produce heavy fanout. Need to verify timing closure in Quartus.

2. **Flame shape ROM size**: 48 × 16-bit = 768 bits of pure combinational logic (individual assign statements). Each frame uses ~16 LUTs. With 48 total entries, this is ~768 LUT inputs which could be significant on Cyclone V. Consider using a registered ROM (M9K block) instead.

3. **Fire block registration timing**: fire_register_trigger is set in S_CHECK_FIRE_SIDE2_EV (combinational path through many state transitions). If the trigger doesn't reach the sequential register in same clock cycle, new fire blocks may not register correctly. Need simulation to.

4. **Begin/end count mismatch**: Pre-existing issue (210 begin vs 211 end). Not a syntax error (case/endcase balanced), but worth cleaning up to eliminate false positives in static checks.

5. **State register at 5-bit max**: State values are 5'd0 through 5'd31. No room for additional states if future features (new materials, more complex physics) need more state machine steps.

6. **Toolbar rendering overwrites grid**: The toolbar compositing replaces ALL grid pixels in y=200..239. This means if fire physics naturally spreads into that region (e.g., smoke rising into toolbar), it won't be visible. Intentional design but worth noting.

7. **Brush overlap check latency**: Fire block deactivation check runs on every brush_we_edge event with a 16-iteration loop inside sequential logic. If brush writes fast (HPS mouse painting), this could create timing path issues.

---

## File Changes Summary

| File | Lines Changed | Description |
|------|--------------|-------------|
| `verilog/DE1_SoC_Computer.v` | 1532 → 1859 (+327) | Fire physics, fire blocks, UI, cursor |
| Total new features | 4 | Fire blocks, toolbar, cursor, pause |
| Total bug fixes | 3 | Fire spread, boundaries, coverage |
