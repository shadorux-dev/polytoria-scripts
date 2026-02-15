local Lighting = game["Lighting"]
local Environment = game["Environment"]

local DAY_SECONDS = 12 * 60
local NIGHT_SECONDS = 9 * 60
local FADE_SECONDS = 1.0
local STEP_SECONDS = 0.05

local DAY_BRIGHTNESS = 1.00
local NIGHT_BRIGHTNESS = 0.75

local DAY_SUN_COLOR = Color.New(1.00, 1.00, 0.97, 1.00)
local NIGHT_SUN_COLOR = Color.New(0.72, 0.78, 0.90, 1.00)

local DAY_AMBIENT_COLOR = Color.New(0.70, 0.70, 0.72, 1.00)
local NIGHT_AMBIENT_COLOR = Color.New(0.40, 0.42, 0.48, 1.00)

local ENABLE_FOG = true

local DAY_FOG_COLOR = Color.New(0.80, 0.86, 0.95, 1.00)
local NIGHT_FOG_COLOR = Color.New(0.16, 0.18, 0.22, 1.00)

local DAY_FOG_START, DAY_FOG_END = 260, 1200
local NIGHT_FOG_START, NIGHT_FOG_END = 260, 1200

Lighting.AmbientSource = AmbientSource.AmbientColor
Lighting.Shadows = true

local DAY_SKYBOX = SkyboxPreset.Day1
local NIGHT_SKYBOX = SkyboxPreset.Night5

local function clamp01(x)
	if x < 0 then return 0 end
	if x > 1 then return 1 end
	return x
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function applyLighting(sunColor, ambientColor, sunBrightness)
	Lighting.SunColor = sunColor
	Lighting.AmbientColor = ambientColor
	Lighting.SunBrightness = sunBrightness
end

local function applyFog(color, startDist, endDist)
	if not (ENABLE_FOG and Environment) then return end
	Environment.FogEnabled = true
	Environment.FogColor = color
	Environment.FogStartDistance = startDist
	Environment.FogEndDistance = endDist
end

local function setSkybox(preset)
	if not Environment then return end
	Environment.Skybox = preset
end

local function fade(
	fromSun, toSun,
	fromAmbient, toAmbient,
	fromBright, toBright,
	fromFog, toFog,
	fromFogStart, toFogStart,
	fromFogEnd, toFogEnd
)
	local step = math.max(STEP_SECONDS, 0.02)
	local duration = math.max(FADE_SECONDS, 0.01)

	local t = 0
	while t < duration do
		local a = clamp01(t / duration)

		applyLighting(
			Color.Lerp(fromSun, toSun, a),
			Color.Lerp(fromAmbient, toAmbient, a),
			lerp(fromBright, toBright, a)
		)

		applyFog(
			Color.Lerp(fromFog, toFog, a),
			lerp(fromFogStart, toFogStart, a),
			lerp(fromFogEnd, toFogEnd, a)
		)

		wait(step)
		t = t + step
	end

	applyLighting(toSun, toAmbient, toBright)
	applyFog(toFog, toFogStart, toFogEnd)
end

while true do
	setSkybox(DAY_SKYBOX)
	applyLighting(DAY_SUN_COLOR, DAY_AMBIENT_COLOR, DAY_BRIGHTNESS)
	applyFog(DAY_FOG_COLOR, DAY_FOG_START, DAY_FOG_END)
	wait(DAY_SECONDS)

	setSkybox(NIGHT_SKYBOX)
	fade(
		DAY_SUN_COLOR, NIGHT_SUN_COLOR,
		DAY_AMBIENT_COLOR, NIGHT_AMBIENT_COLOR,
		DAY_BRIGHTNESS, NIGHT_BRIGHTNESS,
		DAY_FOG_COLOR, NIGHT_FOG_COLOR,
		DAY_FOG_START, NIGHT_FOG_START,
		DAY_FOG_END, NIGHT_FOG_END
	)
	wait(NIGHT_SECONDS)

	setSkybox(DAY_SKYBOX)
	fade(
		NIGHT_SUN_COLOR, DAY_SUN_COLOR,
		NIGHT_AMBIENT_COLOR, DAY_AMBIENT_COLOR,
		NIGHT_BRIGHTNESS, DAY_BRIGHTNESS,
		NIGHT_FOG_COLOR, DAY_FOG_COLOR,
		NIGHT_FOG_START, DAY_FOG_START,
		NIGHT_FOG_END, DAY_FOG_END
	)
end
