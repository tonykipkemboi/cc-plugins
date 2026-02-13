---
name: Insights Video
description: >
  This skill should be used when the user asks to "generate an insights video",
  "make a video of my insights", "create an insights video", "insights video",
  "visualize my Claude Code stats", or wants to turn their /insights data into
  a shareable animated video. Generates a polished 30-second Remotion video with
  Claude branding, animated stats, project areas chart, friction analysis, and
  background music.
version: 1.0.0
---

# Insights Video

Generate a polished 30-second animated video showcasing Claude Code usage insights. Features Claude branding, animated stats, project areas chart, friction analysis, and background music.

## Pipeline

Execute the entire pipeline automatically with no user interaction needed (except for choosing the project location). Complete all steps in order:

### Step 1: Read and Parse Insights Data

Read the HTML report from `~/.claude/usage-data/report.html` and parse it to extract:
- Total sessions count (from subtitle line like "X messages across Y sessions")
- Total messages count
- Date range (from the date subtitle)
- Project areas with session counts (from `.project-area` divs)
- Top 3 friction categories (from `.friction-category` divs)
- Interaction style narrative (from narrative sections)

Also read ALL JSON files from `~/.claude/usage-data/facets/*.json` and aggregate:
- Total friction_counts across all sessions
- User satisfaction counts (sum likely_satisfied and dissatisfied)
- Outcome distribution

Calculate:
- `satisfaction_rate = likely_satisfied / (likely_satisfied + dissatisfied) * 100`
- `total_hours = (total sessions * median_response_time_seconds) / 3600` (approximate from report data)

If `~/.claude/usage-data/` does not exist, display a message that `/insights` must be run first and stop execution.

### Step 2: Ask Where to Create the Project

Use a simple inline question (not a blocking dialog) to ask where to create the Remotion project:
- Desktop (recommended)
- Home directory
- Custom path

Wait for the user's response, then proceed.

### Step 3: Scaffold Remotion Project

Create directory structure at the chosen location: `claude-insights-video/`

Write `package.json` with these exact dependencies:

```json
{
  "name": "claude-insights-video",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "start": "remotion studio",
    "build": "remotion render InsightsVideo out/insights.mp4",
    "render": "remotion render InsightsVideo out/insights.mp4"
  },
  "dependencies": {
    "@remotion/cli": "4.0.419",
    "@remotion/google-fonts": "4.0.419",
    "@remotion/media": "4.0.419",
    "@remotion/paths": "4.0.419",
    "@remotion/transitions": "4.0.419",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "remotion": "4.0.419"
  },
  "devDependencies": {
    "@types/react": "^18.3.3",
    "typescript": "^5.5.3"
  }
}
```

Write `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2018",
    "module": "commonjs",
    "jsx": "react-jsx",
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node",
    "lib": ["ES2018", "DOM"]
  },
  "include": ["src"]
}
```

Write `remotion.config.ts`:

```ts
import { Config } from "@remotion/cli/config";
Config.setVideoImageFormat("jpeg");
Config.setOverwriteOutput(true);
```

### Step 4: Copy Background Music

Create the `public/` directory first, then copy the bundled background music:

```bash
cp ${CLAUDE_PLUGIN_ROOT}/skills/insights-video/assets/background-music.mp3 <project>/public/background-music.mp3
```

### Step 5: Generate Source Files

Create all source files under `src/` with the user's personalized data substituted in.

**IMPORTANT REMOTION RULES:**
- All animations MUST use `useCurrentFrame()` + `interpolate()` or `spring()`. CSS transitions/animations are FORBIDDEN.
- Always use `extrapolateRight: 'clamp'` on interpolations.
- Use `loadFont` from `@remotion/google-fonts/Inter` for typography.
- Use `TransitionSeries` with `fade()` and `slide()` transitions.
- Use `<Audio>` from `@remotion/media` with `staticFile()` for the music.

#### src/lib/constants.ts

This file contains all the personalized data. Substitute the user's actual values:

```ts
// Claude brand palette
export const COLORS = {
  claude: "#D97757",
  claudeLight: "#E8956F",
  claudeDark: "#C45E3E",
  bg: "#1a1107",
  bgMid: "#1f1610",
  bgLight: "#2a1f15",
  bgCard: "rgba(217, 119, 87, 0.08)",
  bgCardBorder: "rgba(217, 119, 87, 0.2)",
  text: "#faf5f0",
  textSecondary: "#d4bfb0",
  textMuted: "#9a8578",
  green: "#5cb88a",
  greenGlow: "#3ddc84",
  amber: "#e6a23c",
  red: "#e06c5a",
  purple: "#b39ddb",
  blue: "#7eb8da",
  cyan: "#6ec6c8",
  glowOrange: "rgba(217, 119, 87, 0.3)",
  glowGreen: "rgba(92, 184, 138, 0.3)",
  glowAmber: "rgba(230, 162, 60, 0.3)",
};

// PERSONALIZE THESE with user's actual data:
export const STATS = [
  { label: "Sessions", value: USER_SESSIONS, color: COLORS.claude, icon: "terminal" },
  { label: "Messages", value: USER_MESSAGES, color: COLORS.blue, icon: "message" },
  { label: "Hours", value: USER_HOURS, color: COLORS.cyan, icon: "clock" },
  { label: "Commits", value: USER_COMMITS, color: COLORS.green, icon: "git" },
];

// Use top 5 project areas from insights, assign colors rotating through: claude, blue, cyan, green, amber
export const PROJECT_AREAS = [
  { name: "AREA_NAME", sessions: AREA_COUNT, color: COLORS.claude },
  // ... up to 5 entries
];

// Use top 3 "What's Working" items from insights
export const WHATS_WORKING = [
  "WORKING_ITEM_1",
  "WORKING_ITEM_2",
  "WORKING_ITEM_3",
];

// Use top 3 friction categories from insights
export const FRICTION_POINTS = [
  { label: "FRICTION_LABEL", count: FRICTION_COUNT, color: COLORS.red },
  // ... up to 3 entries, first gets red, rest get amber
];

// The user's key interaction style quote and subtitle from insights
export const STYLE_QUOTE = "USER_STYLE_QUOTE"; // e.g. "Rapid iteration with tight oversight"
export const STYLE_SUBTITLE = "USER_STYLE_SUBTITLE"; // e.g. "Hands-on, correction-driven collaborator"

// Satisfaction rate percentage
export const SATISFACTION_RATE = USER_SATISFACTION_RATE; // e.g. 97

// Date range from insights
export const DATE_RANGE = "USER_DATE_RANGE"; // e.g. "Jan 6 — Feb 5, 2026"

// Total sessions for title scene
export const TOTAL_SESSIONS = USER_TOTAL_SESSIONS; // e.g. 666

export const FPS = 30;
export const WIDTH = 1080;
export const HEIGHT = 1080;

export const SCENE_DURATIONS = {
  title: 4 * FPS,
  stats: 5 * FPS,
  projects: 5 * FPS,
  working: 5 * FPS,
  friction: 5 * FPS,
  style: 5 * FPS,
  closing: 4 * FPS,
};
export const TRANSITION_DURATION = 15;
export const TOTAL_DURATION =
  Object.values(SCENE_DURATIONS).reduce((a, b) => a + b, 0) - 6 * TRANSITION_DURATION;
```

#### src/index.ts

```ts
import { registerRoot } from "remotion";
import { RemotionRoot } from "./Root";
registerRoot(RemotionRoot);
```

#### src/Root.tsx

```tsx
import { Composition } from "remotion";
import { InsightsVideo } from "./InsightsVideo";
import { WIDTH, HEIGHT, FPS, TOTAL_DURATION } from "./lib/constants";

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="InsightsVideo"
      component={InsightsVideo}
      durationInFrames={TOTAL_DURATION}
      fps={FPS}
      width={WIDTH}
      height={HEIGHT}
    />
  );
};
```

#### src/InsightsVideo.tsx

```tsx
import React from "react";
import { interpolate, staticFile, useVideoConfig } from "remotion";
import { Audio } from "@remotion/media";
import { TransitionSeries, linearTiming } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";
import { SCENE_DURATIONS, TRANSITION_DURATION, TOTAL_DURATION } from "./lib/constants";
import { TitleScene } from "./scenes/TitleScene";
import { StatsScene } from "./scenes/StatsScene";
import { ProjectsScene } from "./scenes/ProjectsScene";
import { WorkingScene } from "./scenes/WorkingScene";
import { FrictionScene } from "./scenes/FrictionScene";
import { StyleScene } from "./scenes/StyleScene";
import { ClosingScene } from "./scenes/ClosingScene";

export const InsightsVideo: React.FC = () => {
  const { fps } = useVideoConfig();
  return (
    <>
      <Audio
        src={staticFile("background-music.mp3")}
        volume={(f) => {
          const fadeInEnd = 2 * fps;
          const fadeOutStart = TOTAL_DURATION - 3 * fps;
          if (f < fadeInEnd) return interpolate(f, [0, fadeInEnd], [0, 0.6], { extrapolateRight: "clamp" });
          if (f > fadeOutStart) return interpolate(f, [fadeOutStart, TOTAL_DURATION], [0.6, 0], { extrapolateRight: "clamp" });
          return 0.6;
        }}
      />
      <TransitionSeries>
        <TransitionSeries.Sequence durationInFrames={SCENE_DURATIONS.title}><TitleScene /></TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={fade()} timing={linearTiming({ durationInFrames: TRANSITION_DURATION })} />
        <TransitionSeries.Sequence durationInFrames={SCENE_DURATIONS.stats}><StatsScene /></TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={slide({ direction: "from-left" })} timing={linearTiming({ durationInFrames: TRANSITION_DURATION })} />
        <TransitionSeries.Sequence durationInFrames={SCENE_DURATIONS.projects}><ProjectsScene /></TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={fade()} timing={linearTiming({ durationInFrames: TRANSITION_DURATION })} />
        <TransitionSeries.Sequence durationInFrames={SCENE_DURATIONS.working}><WorkingScene /></TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={slide({ direction: "from-right" })} timing={linearTiming({ durationInFrames: TRANSITION_DURATION })} />
        <TransitionSeries.Sequence durationInFrames={SCENE_DURATIONS.friction}><FrictionScene /></TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={fade()} timing={linearTiming({ durationInFrames: TRANSITION_DURATION })} />
        <TransitionSeries.Sequence durationInFrames={SCENE_DURATIONS.style}><StyleScene /></TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={fade()} timing={linearTiming({ durationInFrames: TRANSITION_DURATION })} />
        <TransitionSeries.Sequence durationInFrames={SCENE_DURATIONS.closing}><ClosingScene /></TransitionSeries.Sequence>
      </TransitionSeries>
    </>
  );
};
```

#### src/components/Background.tsx

```tsx
import React from "react";
import { AbsoluteFill, useCurrentFrame, useVideoConfig, interpolate } from "remotion";
import { COLORS } from "../lib/constants";

export const Background: React.FC<{ accentColor?: string; glowIntensity?: number }> = ({ accentColor, glowIntensity = 0.4 }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const accent = accentColor || COLORS.claude;
  const fadeIn = interpolate(frame, [0, fps * 0.5], [0, 1], { extrapolateRight: "clamp" });
  const glow1X = interpolate(frame, [0, 10 * fps], [20, 80], { extrapolateRight: "clamp" });
  const glow1Y = interpolate(frame, [0, 10 * fps], [15, 35], { extrapolateRight: "clamp" });
  const glow2X = interpolate(frame, [0, 10 * fps], [70, 30], { extrapolateRight: "clamp" });
  const glow2Y = interpolate(frame, [0, 10 * fps], [75, 60], { extrapolateRight: "clamp" });

  return (
    <AbsoluteFill>
      <AbsoluteFill style={{ background: `radial-gradient(ellipse at 50% 50%, ${COLORS.bgMid} 0%, ${COLORS.bg} 70%)` }} />
      <AbsoluteFill style={{ opacity: fadeIn * glowIntensity }}>
        <div style={{ position: "absolute", width: 600, height: 600, borderRadius: "50%", background: `radial-gradient(circle, ${accent}40 0%, transparent 70%)`, left: `${glow1X}%`, top: `${glow1Y}%`, transform: "translate(-50%, -50%)", filter: "blur(80px)" }} />
        <div style={{ position: "absolute", width: 500, height: 500, borderRadius: "50%", background: `radial-gradient(circle, ${COLORS.claude}25 0%, transparent 70%)`, left: `${glow2X}%`, top: `${glow2Y}%`, transform: "translate(-50%, -50%)", filter: "blur(100px)" }} />
      </AbsoluteFill>
      <AbsoluteFill style={{ opacity: fadeIn * 0.15, backgroundImage: `radial-gradient(${accent}30 1px, transparent 1px)`, backgroundSize: "32px 32px" }} />
      <div style={{ position: "absolute", top: 40, left: 40, width: interpolate(frame, [0, fps], [0, 60], { extrapolateRight: "clamp" }), height: 3, background: accent, borderRadius: 2, opacity: fadeIn * 0.6 }} />
      <div style={{ position: "absolute", top: 40, left: 40, width: 3, height: interpolate(frame, [0, fps], [0, 60], { extrapolateRight: "clamp" }), background: accent, borderRadius: 2, opacity: fadeIn * 0.6 }} />
      <div style={{ position: "absolute", bottom: 40, right: 40, width: interpolate(frame, [0, fps], [0, 60], { extrapolateRight: "clamp" }), height: 3, background: accent, borderRadius: 2, opacity: fadeIn * 0.6 }} />
      <div style={{ position: "absolute", bottom: 40, right: 40, width: 3, height: interpolate(frame, [0, fps], [0, 60], { extrapolateRight: "clamp" }), background: accent, borderRadius: 2, opacity: fadeIn * 0.6 }} />
    </AbsoluteFill>
  );
};
```

#### src/components/AnimatedNumber.tsx

```tsx
import React from "react";
import { useCurrentFrame, useVideoConfig, spring, interpolate } from "remotion";
import { COLORS } from "../lib/constants";

type Props = { value: number; color: string; label: string; delay: number; fontSize?: number };

export const AnimatedNumber: React.FC<Props> = ({ value, color, label, delay, fontSize = 68 }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const entrance = spring({ frame, fps, delay, config: { damping: 200 } });
  const scale = interpolate(entrance, [0, 1], [0.5, 1]);
  const translateY = interpolate(entrance, [0, 1], [30, 0]);
  const numberProgress = interpolate(frame, [delay, delay + 2 * fps], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const displayValue = Math.round(numberProgress * value);
  const formatted = displayValue >= 1000 ? displayValue.toLocaleString() : String(displayValue);

  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", opacity: entrance, transform: `scale(${scale}) translateY(${translateY}px)` }}>
      <span style={{ fontSize, fontWeight: 900, color, lineHeight: 1, fontVariantNumeric: "tabular-nums", textShadow: `0 0 40px ${color}60, 0 0 80px ${color}20` }}>{formatted}</span>
      <span style={{ fontSize: 20, color: COLORS.textMuted, marginTop: 10, fontWeight: 600, textTransform: "uppercase", letterSpacing: 3 }}>{label}</span>
    </div>
  );
};
```

#### src/components/BarChart.tsx

```tsx
import React from "react";
import { useCurrentFrame, useVideoConfig, spring, interpolate } from "remotion";
import { COLORS } from "../lib/constants";

type BarData = { name: string; sessions: number; color: string };
type Props = { data: BarData[]; maxValue?: number };

export const BarChart: React.FC<Props> = ({ data, maxValue }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const max = maxValue || Math.max(...data.map((d) => d.sessions));

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 22, width: "100%", padding: "0 40px" }}>
      {data.map((item, i) => {
        const barProgress = spring({ frame, fps, delay: i * 8 + 15, config: { damping: 200 } });
        const labelOpacity = interpolate(frame, [i * 8 + 10, i * 8 + 25], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
        const barWidth = interpolate(barProgress, [0, 1], [0, (item.sessions / max) * 100]);
        return (
          <div key={item.name} style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", opacity: labelOpacity }}>
              <span style={{ fontSize: 24, color: COLORS.text, fontWeight: 500 }}>{item.name}</span>
              <span style={{ fontSize: 28, color: item.color, fontWeight: 800, fontVariantNumeric: "tabular-nums", textShadow: `0 0 20px ${item.color}40` }}>{item.sessions}</span>
            </div>
            <div style={{ height: 14, borderRadius: 7, background: "rgba(255,255,255,0.05)", overflow: "hidden", border: "1px solid rgba(255,255,255,0.05)" }}>
              <div style={{ height: "100%", width: `${barWidth}%`, borderRadius: 7, background: `linear-gradient(90deg, ${item.color}cc, ${item.color})`, boxShadow: `0 0 16px ${item.color}50` }} />
            </div>
          </div>
        );
      })}
    </div>
  );
};
```

#### src/components/ClaudeLogo.tsx

```tsx
import React from "react";
import { useCurrentFrame, useVideoConfig, spring, interpolate } from "remotion";
import { COLORS } from "../lib/constants";

type Props = { size?: number; delay?: number };

export const ClaudeLogo: React.FC<Props> = ({ size = 80, delay = 0 }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const entrance = spring({ frame, fps, delay, config: { damping: 12, stiffness: 80 } });
  const scale = interpolate(entrance, [0, 1], [0.3, 1]);
  const glowPulse = interpolate(frame, [delay, delay + 2 * fps, delay + 4 * fps], [0.4, 0.8, 0.4], { extrapolateRight: "clamp", extrapolateLeft: "clamp" });

  return (
    <div style={{ width: size, height: size, opacity: entrance, transform: `scale(${scale})`, position: "relative", display: "flex", alignItems: "center", justifyContent: "center" }}>
      <div style={{ position: "absolute", inset: -20, borderRadius: "50%", background: `radial-gradient(circle, ${COLORS.claude}${Math.round(glowPulse * 60).toString(16).padStart(2, "0")} 0%, transparent 70%)`, filter: "blur(15px)" }} />
      <svg width={size} height={size} viewBox="0 0 100 100" fill="none">
        {[0, 60, 120, 180, 240, 300].map((angle) => (
          <line key={angle} x1="50" y1="50" x2={50 + 38 * Math.cos((angle * Math.PI) / 180)} y2={50 + 38 * Math.sin((angle * Math.PI) / 180)} stroke={COLORS.claude} strokeWidth="6" strokeLinecap="round" />
        ))}
        <circle cx="50" cy="50" r="8" fill={COLORS.claude} />
      </svg>
    </div>
  );
};
```

#### src/scenes/TitleScene.tsx

```tsx
import React from "react";
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  spring,
  interpolate,
  Easing,
} from "remotion";
import { loadFont } from "@remotion/google-fonts/Inter";
import { Background } from "../components/Background";
import { ClaudeLogo } from "../components/ClaudeLogo";
import { COLORS, DATE_RANGE, TOTAL_SESSIONS } from "../lib/constants";

const { fontFamily } = loadFont("normal", {
  weights: ["400", "700", "900"],
  subsets: ["latin"],
});

export const TitleScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const titleSpring = spring({
    frame,
    fps,
    delay: 10,
    config: { damping: 15, stiffness: 80 },
  });
  const titleScale = interpolate(titleSpring, [0, 1], [0.6, 1]);

  const subtitleOpacity = interpolate(frame, [fps * 1.5, fps * 2.5], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const subtitleY = interpolate(frame, [fps * 1.5, fps * 2.5], [15, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const lineWidth = interpolate(frame, [fps, fps * 2], [0, 300], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.quad),
  });

  // Floating particles
  const particles = Array.from({ length: 12 }, (_, i) => {
    const baseX = (i * 97 + 13) % 100;
    const baseY = (i * 71 + 29) % 100;
    const speed = 0.3 + (i % 4) * 0.15;
    const yOffset = interpolate(
      frame,
      [0, 10 * fps],
      [0, -40 * speed],
      { extrapolateRight: "clamp" }
    );
    const particleOpacity = interpolate(
      frame,
      [i * 3, i * 3 + fps],
      [0, 0.3 + (i % 3) * 0.15],
      { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
    );
    return { x: baseX, y: baseY, yOffset, opacity: particleOpacity, size: 3 + (i % 3) * 2 };
  });

  return (
    <AbsoluteFill style={{ fontFamily }}>
      <Background accentColor={COLORS.claude} glowIntensity={0.5} />

      {/* Floating particles */}
      {particles.map((p, i) => (
        <div
          key={i}
          style={{
            position: "absolute",
            left: `${p.x}%`,
            top: `${p.y}%`,
            width: p.size,
            height: p.size,
            borderRadius: "50%",
            background: COLORS.claude,
            opacity: p.opacity,
            transform: `translateY(${p.yOffset}px)`,
            boxShadow: `0 0 ${p.size * 3}px ${COLORS.claude}60`,
          }}
        />
      ))}

      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          flexDirection: "column",
          gap: 20,
        }}
      >
        <ClaudeLogo size={90} delay={0} />

        <div style={{ height: 20 }} />

        {/* Title */}
        <div
          style={{
            opacity: titleSpring,
            transform: `scale(${titleScale})`,
            textAlign: "center",
          }}
        >
          <div
            style={{
              fontSize: 76,
              fontWeight: 900,
              color: COLORS.text,
              lineHeight: 1.1,
              textShadow: `0 0 60px ${COLORS.claude}30`,
            }}
          >
            Claude Code
          </div>
          <div
            style={{
              fontSize: 76,
              fontWeight: 900,
              color: COLORS.claude,
              lineHeight: 1.1,
              textShadow: `0 0 60px ${COLORS.claude}50`,
            }}
          >
            Insights
          </div>
        </div>

        {/* Divider line */}
        <div
          style={{
            width: lineWidth,
            height: 2,
            background: `linear-gradient(90deg, transparent, ${COLORS.claude}, transparent)`,
            borderRadius: 2,
            marginTop: 8,
            boxShadow: `0 0 20px ${COLORS.claude}40`,
          }}
        />

        {/* Date range */}
        <div
          style={{
            fontSize: 24,
            color: COLORS.textMuted,
            opacity: subtitleOpacity,
            transform: `translateY(${subtitleY}px)`,
            letterSpacing: 4,
            textTransform: "uppercase",
            marginTop: 8,
          }}
        >
          {DATE_RANGE}
        </div>

        {/* Bottom badge */}
        <div
          style={{
            position: "absolute",
            bottom: 70,
            opacity: subtitleOpacity,
            display: "flex",
            alignItems: "center",
            gap: 8,
            padding: "10px 24px",
            borderRadius: 100,
            border: `1px solid ${COLORS.bgCardBorder}`,
            background: COLORS.bgCard,
          }}
        >
          <div
            style={{
              width: 8,
              height: 8,
              borderRadius: "50%",
              background: COLORS.claude,
              boxShadow: `0 0 8px ${COLORS.claude}`,
            }}
          />
          <span style={{ fontSize: 16, color: COLORS.textSecondary, fontWeight: 500 }}>
            {TOTAL_SESSIONS} sessions analyzed
          </span>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
```

#### src/scenes/StatsScene.tsx

```tsx
import React from "react";
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  spring,
  interpolate,
} from "remotion";
import { loadFont } from "@remotion/google-fonts/Inter";
import { Background } from "../components/Background";
import { AnimatedNumber } from "../components/AnimatedNumber";
import { COLORS, STATS } from "../lib/constants";

const { fontFamily } = loadFont("normal", {
  weights: ["400", "700", "900"],
  subsets: ["latin"],
});

const StatIcon: React.FC<{ type: string; color: string }> = ({ type, color }) => {
  const icons: Record<string, React.ReactNode> = {
    terminal: (
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <polyline points="4 17 10 11 4 5" />
        <line x1="12" y1="19" x2="20" y2="19" />
      </svg>
    ),
    message: (
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
      </svg>
    ),
    clock: (
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <circle cx="12" cy="12" r="10" />
        <polyline points="12 6 12 12 16 14" />
      </svg>
    ),
    git: (
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <circle cx="12" cy="18" r="3" />
        <circle cx="12" cy="6" r="3" />
        <line x1="12" y1="9" x2="12" y2="15" />
      </svg>
    ),
  };
  return <>{icons[type] || null}</>;
};

export const StatsScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const headerSpring = spring({ frame, fps, config: { damping: 200 } });

  return (
    <AbsoluteFill style={{ fontFamily }}>
      <Background accentColor={COLORS.claude} />
      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          flexDirection: "column",
          gap: 50,
          padding: 60,
        }}
      >
        {/* Header */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 14,
            opacity: headerSpring,
            transform: `translateY(${interpolate(headerSpring, [0, 1], [20, 0])}px)`,
          }}
        >
          <div style={{ width: 40, height: 2, background: COLORS.claude, borderRadius: 1 }} />
          <span
            style={{
              fontSize: 36,
              fontWeight: 700,
              color: COLORS.text,
              textTransform: "uppercase",
              letterSpacing: 6,
            }}
          >
            By the Numbers
          </span>
          <div style={{ width: 40, height: 2, background: COLORS.claude, borderRadius: 1 }} />
        </div>

        {/* Stats grid */}
        <div
          style={{
            display: "flex",
            flexWrap: "wrap",
            justifyContent: "center",
            gap: 30,
            width: "100%",
          }}
        >
          {STATS.map((stat, i) => {
            const cardSpring = spring({
              frame,
              fps,
              delay: i * 8 + 8,
              config: { damping: 200 },
            });

            return (
              <div
                key={stat.label}
                style={{
                  width: "44%",
                  display: "flex",
                  flexDirection: "column",
                  alignItems: "center",
                  justifyContent: "center",
                  padding: "32px 20px 28px",
                  background: COLORS.bgCard,
                  borderRadius: 20,
                  border: `1px solid ${COLORS.bgCardBorder}`,
                  opacity: cardSpring,
                  transform: `translateY(${interpolate(cardSpring, [0, 1], [20, 0])}px)`,
                  boxShadow: `0 4px 30px rgba(0,0,0,0.3), inset 0 1px 0 rgba(255,255,255,0.03)`,
                }}
              >
                <div style={{ marginBottom: 12, opacity: 0.7 }}>
                  <StatIcon type={stat.icon} color={stat.color} />
                </div>
                <AnimatedNumber
                  value={stat.value}
                  color={stat.color}
                  label={stat.label}
                  delay={i * 8 + 8}
                />
              </div>
            );
          })}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
```

#### src/scenes/ProjectsScene.tsx

```tsx
import React from "react";
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  spring,
  interpolate,
} from "remotion";
import { loadFont } from "@remotion/google-fonts/Inter";
import { Background } from "../components/Background";
import { BarChart } from "../components/BarChart";
import { COLORS, PROJECT_AREAS } from "../lib/constants";

const { fontFamily } = loadFont("normal", {
  weights: ["400", "700", "900"],
  subsets: ["latin"],
});

export const ProjectsScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const headerSpring = spring({ frame, fps, config: { damping: 200 } });

  return (
    <AbsoluteFill style={{ fontFamily }}>
      <Background accentColor={COLORS.cyan} />
      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          flexDirection: "column",
          gap: 50,
          padding: 60,
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 14,
            opacity: headerSpring,
            transform: `translateY(${interpolate(headerSpring, [0, 1], [20, 0])}px)`,
          }}
        >
          <div style={{ width: 40, height: 2, background: COLORS.cyan, borderRadius: 1 }} />
          <span
            style={{
              fontSize: 36,
              fontWeight: 700,
              color: COLORS.text,
              textTransform: "uppercase",
              letterSpacing: 6,
            }}
          >
            Project Areas
          </span>
          <div style={{ width: 40, height: 2, background: COLORS.cyan, borderRadius: 1 }} />
        </div>

        <div
          style={{
            width: "100%",
            background: COLORS.bgCard,
            borderRadius: 24,
            border: `1px solid ${COLORS.bgCardBorder}`,
            padding: "36px 20px",
            boxShadow: "0 4px 30px rgba(0,0,0,0.3)",
          }}
        >
          <BarChart data={PROJECT_AREAS} />
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
```

#### src/scenes/WorkingScene.tsx

```tsx
import React from "react";
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  spring,
  interpolate,
} from "remotion";
import { loadFont } from "@remotion/google-fonts/Inter";
import { Background } from "../components/Background";
import { COLORS, WHATS_WORKING } from "../lib/constants";

const { fontFamily } = loadFont("normal", {
  weights: ["400", "700", "900"],
  subsets: ["latin"],
});

const CheckCircle: React.FC<{ progress: number }> = ({ progress }) => {
  const dashOffset = interpolate(progress, [0, 1], [63, 0]);
  return (
    <svg width="36" height="36" viewBox="0 0 24 24" fill="none">
      <circle
        cx="12"
        cy="12"
        r="10"
        stroke={COLORS.green}
        strokeWidth="2"
        strokeDasharray="63"
        strokeDashoffset={dashOffset}
        opacity={0.3}
      />
      <circle cx="12" cy="12" r="10" fill={`${COLORS.green}15`} />
      <polyline
        points="8 12 11 15 16 9"
        stroke={COLORS.green}
        strokeWidth="2.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        opacity={progress}
      />
    </svg>
  );
};

export const WorkingScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const headerSpring = spring({ frame, fps, config: { damping: 200 } });

  return (
    <AbsoluteFill style={{ fontFamily }}>
      <Background accentColor={COLORS.green} />
      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          flexDirection: "column",
          gap: 44,
          padding: 80,
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 14,
            opacity: headerSpring,
            transform: `translateY(${interpolate(headerSpring, [0, 1], [20, 0])}px)`,
          }}
        >
          <div style={{ width: 40, height: 2, background: COLORS.green, borderRadius: 1 }} />
          <span
            style={{
              fontSize: 36,
              fontWeight: 700,
              color: COLORS.green,
              textTransform: "uppercase",
              letterSpacing: 6,
              textShadow: `0 0 30px ${COLORS.green}30`,
            }}
          >
            What's Working
          </span>
          <div style={{ width: 40, height: 2, background: COLORS.green, borderRadius: 1 }} />
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 24, width: "100%" }}>
          {WHATS_WORKING.map((item, i) => {
            const itemSpring = spring({
              frame,
              fps,
              delay: i * 12 + 15,
              config: { damping: 200 },
            });

            const translateX = interpolate(itemSpring, [0, 1], [-50, 0]);

            return (
              <div
                key={item}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 20,
                  opacity: itemSpring,
                  transform: `translateX(${translateX}px)`,
                  background: COLORS.bgCard,
                  borderRadius: 18,
                  padding: "26px 32px",
                  borderLeft: `3px solid ${COLORS.green}`,
                  border: `1px solid ${COLORS.bgCardBorder}`,
                  borderLeftColor: COLORS.green,
                  borderLeftWidth: 3,
                  boxShadow: `0 4px 20px rgba(0,0,0,0.2), inset 0 1px 0 rgba(255,255,255,0.03)`,
                }}
              >
                <CheckCircle progress={itemSpring} />
                <span style={{ fontSize: 26, color: COLORS.text, fontWeight: 500 }}>
                  {item}
                </span>
              </div>
            );
          })}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
```

#### src/scenes/FrictionScene.tsx

```tsx
import React from "react";
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  spring,
  interpolate,
} from "remotion";
import { loadFont } from "@remotion/google-fonts/Inter";
import { Background } from "../components/Background";
import { COLORS, FRICTION_POINTS } from "../lib/constants";

const { fontFamily } = loadFont("normal", {
  weights: ["400", "700", "900"],
  subsets: ["latin"],
});

const WarningTriangle: React.FC<{ color: string; progress: number }> = ({ color, progress }) => (
  <svg width="34" height="34" viewBox="0 0 24 24" fill="none">
    <path
      d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"
      fill={`${color}15`}
      stroke={color}
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
      opacity={progress}
    />
    <line x1="12" y1="9" x2="12" y2="13" stroke={color} strokeWidth="2" strokeLinecap="round" opacity={progress} />
    <circle cx="12" cy="17" r="1" fill={color} opacity={progress} />
  </svg>
);

export const FrictionScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const headerSpring = spring({ frame, fps, config: { damping: 200 } });

  return (
    <AbsoluteFill style={{ fontFamily }}>
      <Background accentColor={COLORS.amber} />
      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          flexDirection: "column",
          gap: 44,
          padding: 80,
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 14,
            opacity: headerSpring,
            transform: `translateY(${interpolate(headerSpring, [0, 1], [20, 0])}px)`,
          }}
        >
          <div style={{ width: 40, height: 2, background: COLORS.amber, borderRadius: 1 }} />
          <span
            style={{
              fontSize: 36,
              fontWeight: 700,
              color: COLORS.amber,
              textTransform: "uppercase",
              letterSpacing: 6,
              textShadow: `0 0 30px ${COLORS.amber}30`,
            }}
          >
            Friction Points
          </span>
          <div style={{ width: 40, height: 2, background: COLORS.amber, borderRadius: 1 }} />
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 24, width: "100%" }}>
          {FRICTION_POINTS.map((item, i) => {
            const itemSpring = spring({
              frame,
              fps,
              delay: i * 12 + 15,
              config: { damping: 200 },
            });

            const translateX = interpolate(itemSpring, [0, 1], [50, 0]);

            const countProgress = interpolate(
              frame,
              [i * 12 + 15, i * 12 + 15 + 1.5 * fps],
              [0, 1],
              { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
            );

            return (
              <div
                key={item.label}
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  opacity: itemSpring,
                  transform: `translateX(${translateX}px)`,
                  background: COLORS.bgCard,
                  borderRadius: 18,
                  padding: "26px 32px",
                  border: `1px solid ${COLORS.bgCardBorder}`,
                  borderLeftColor: item.color,
                  borderLeftWidth: 3,
                  boxShadow: `0 4px 20px rgba(0,0,0,0.2), inset 0 1px 0 rgba(255,255,255,0.03)`,
                }}
              >
                <div style={{ display: "flex", alignItems: "center", gap: 16 }}>
                  <WarningTriangle color={item.color} progress={itemSpring} />
                  <span style={{ fontSize: 26, color: COLORS.text, fontWeight: 500 }}>
                    {item.label}
                  </span>
                </div>
                <div
                  style={{
                    display: "flex",
                    alignItems: "baseline",
                    gap: 4,
                  }}
                >
                  <span
                    style={{
                      fontSize: 40,
                      fontWeight: 900,
                      color: item.color,
                      fontVariantNumeric: "tabular-nums",
                      textShadow: `0 0 20px ${item.color}40`,
                    }}
                  >
                    {Math.round(countProgress * item.count)}
                  </span>
                  <span style={{ fontSize: 16, color: COLORS.textMuted, fontWeight: 500 }}>
                    events
                  </span>
                </div>
              </div>
            );
          })}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
```

#### src/scenes/StyleScene.tsx

```tsx
import React from "react";
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  spring,
  interpolate,
} from "remotion";
import { loadFont } from "@remotion/google-fonts/Inter";
import { Background } from "../components/Background";
import { COLORS, STYLE_QUOTE, STYLE_SUBTITLE } from "../lib/constants";

const { fontFamily } = loadFont("normal", {
  weights: ["400", "700", "900"],
  subsets: ["latin"],
});

export const StyleScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const headerSpring = spring({ frame, fps, config: { damping: 200 } });

  const quote = STYLE_QUOTE;
  const words = quote.split(" ");

  const subtitleOpacity = interpolate(
    frame,
    [words.length * 6 + 40, words.length * 6 + 60],
    [0, 1],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
  );

  const subtitleY = interpolate(
    frame,
    [words.length * 6 + 40, words.length * 6 + 60],
    [15, 0],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
  );

  return (
    <AbsoluteFill style={{ fontFamily }}>
      <Background accentColor={COLORS.purple} />
      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          flexDirection: "column",
          gap: 44,
          padding: 80,
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 14,
            opacity: headerSpring,
            transform: `translateY(${interpolate(headerSpring, [0, 1], [20, 0])}px)`,
          }}
        >
          <div style={{ width: 40, height: 2, background: COLORS.purple, borderRadius: 1 }} />
          <span
            style={{
              fontSize: 36,
              fontWeight: 700,
              color: COLORS.purple,
              textTransform: "uppercase",
              letterSpacing: 6,
              textShadow: `0 0 30px ${COLORS.purple}30`,
            }}
          >
            Your Style
          </span>
          <div style={{ width: 40, height: 2, background: COLORS.purple, borderRadius: 1 }} />
        </div>

        {/* Quote card */}
        <div
          style={{
            position: "relative",
            padding: "50px 50px 44px",
            background: COLORS.bgCard,
            borderRadius: 24,
            border: `1px solid ${COLORS.bgCardBorder}`,
            boxShadow: `0 4px 30px rgba(0,0,0,0.3), inset 0 1px 0 rgba(255,255,255,0.03)`,
            width: "100%",
          }}
        >
          {/* Big quote mark */}
          <span
            style={{
              position: "absolute",
              top: 5,
              left: 24,
              fontSize: 120,
              color: COLORS.purple,
              fontWeight: 900,
              lineHeight: 1,
              opacity: 0.2,
            }}
          >
            &ldquo;
          </span>

          <div
            style={{
              fontSize: 46,
              fontWeight: 900,
              color: COLORS.text,
              lineHeight: 1.35,
              textAlign: "center",
              display: "flex",
              flexWrap: "wrap",
              justifyContent: "center",
              gap: 14,
              position: "relative",
              zIndex: 1,
            }}
          >
            {words.map((word, i) => {
              const wordSpring = spring({
                frame,
                fps,
                delay: i * 6 + 15,
                config: { damping: 200 },
              });

              const wordY = interpolate(wordSpring, [0, 1], [20, 0]);
              // Highlight the last two words of the quote for emphasis
              const isHighlighted = i >= words.length - 2;

              return (
                <span
                  key={`${word}-${i}`}
                  style={{
                    opacity: wordSpring,
                    transform: `translateY(${wordY}px)`,
                    display: "inline-block",
                    color: isHighlighted ? COLORS.purple : COLORS.text,
                    textShadow: isHighlighted ? `0 0 30px ${COLORS.purple}40` : "none",
                  }}
                >
                  {word}
                </span>
              );
            })}
          </div>
        </div>

        <div
          style={{
            fontSize: 24,
            color: COLORS.textSecondary,
            opacity: subtitleOpacity,
            transform: `translateY(${subtitleY}px)`,
            textAlign: "center",
            fontStyle: "italic",
          }}
        >
          {STYLE_SUBTITLE}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
```

#### src/scenes/ClosingScene.tsx

```tsx
import React from "react";
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  spring,
  interpolate,
} from "remotion";
import { loadFont } from "@remotion/google-fonts/Inter";
import { Background } from "../components/Background";
import { ClaudeLogo } from "../components/ClaudeLogo";
import { COLORS, SATISFACTION_RATE } from "../lib/constants";

const { fontFamily } = loadFont("normal", {
  weights: ["400", "700", "900"],
  subsets: ["latin"],
});

export const ClosingScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const numberSpring = spring({ frame, fps, config: { damping: 12, stiffness: 80 } });
  const numberScale = interpolate(numberSpring, [0, 1], [0.3, 1]);

  const countUp = interpolate(frame, [0, 1.5 * fps], [0, SATISFACTION_RATE], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const taglineOpacity = interpolate(frame, [2 * fps, 2.8 * fps], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const taglineY = interpolate(frame, [2 * fps, 2.8 * fps], [20, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const dividerWidth = interpolate(frame, [1.5 * fps, 2.2 * fps], [0, 200], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill style={{ fontFamily }}>
      <Background accentColor={COLORS.green} glowIntensity={0.5} />
      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          flexDirection: "column",
          gap: 20,
        }}
      >
        {/* Big satisfaction number */}
        <div
          style={{
            opacity: numberSpring,
            transform: `scale(${numberScale})`,
            display: "flex",
            alignItems: "baseline",
            gap: 4,
          }}
        >
          <span
            style={{
              fontSize: 150,
              fontWeight: 900,
              color: COLORS.green,
              lineHeight: 1,
              fontVariantNumeric: "tabular-nums",
              textShadow: `0 0 60px ${COLORS.green}50, 0 0 120px ${COLORS.green}20`,
            }}
          >
            {Math.round(countUp)}
          </span>
          <span
            style={{
              fontSize: 72,
              fontWeight: 900,
              color: COLORS.green,
              lineHeight: 1,
              textShadow: `0 0 40px ${COLORS.green}40`,
            }}
          >
            %
          </span>
        </div>

        <div
          style={{
            fontSize: 28,
            color: COLORS.textMuted,
            textTransform: "uppercase",
            letterSpacing: 8,
            opacity: numberSpring,
          }}
        >
          Satisfaction Rate
        </div>

        {/* Divider */}
        <div
          style={{
            width: dividerWidth,
            height: 2,
            background: `linear-gradient(90deg, transparent, ${COLORS.claude}, transparent)`,
            marginTop: 24,
            boxShadow: `0 0 16px ${COLORS.claude}40`,
          }}
        />

        {/* Powered by Claude Code */}
        <div
          style={{
            opacity: taglineOpacity,
            transform: `translateY(${taglineY}px)`,
            display: "flex",
            alignItems: "center",
            gap: 14,
            marginTop: 16,
            padding: "14px 28px",
            borderRadius: 100,
            border: `1px solid ${COLORS.bgCardBorder}`,
            background: COLORS.bgCard,
          }}
        >
          <ClaudeLogo size={28} delay={0} />
          <span
            style={{
              fontSize: 24,
              color: COLORS.textSecondary,
              fontWeight: 500,
            }}
          >
            Powered by{" "}
            <span style={{ color: COLORS.claude, fontWeight: 700 }}>
              Claude Code
            </span>
          </span>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
```

### Step 6: Install Dependencies

Run `npm install` in the project directory and wait for it to complete.

### Step 7: Render the Video

Run `npx remotion render InsightsVideo out/insights.mp4` to render the final video.

### Step 8: Open the Video

Run `open <project>/out/insights.mp4` (macOS) to open the rendered video.

---

## Final Notes

After successful completion, display a summary:

- Video rendered to `<project>/out/insights.mp4`
- Run `npm start` in the project directory to open Remotion Studio and preview/edit
- Run `npm run render` to re-render after making changes
- Format: 1080x1080 at 30fps, approximately 30 seconds long
- Content: personalized insights data, animated statistics, project areas chart, friction analysis, and background music
